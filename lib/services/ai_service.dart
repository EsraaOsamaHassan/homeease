import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../l10n.dart';
String? lastAiError;

Future<String?> generateTextWithDots(
  String prompt, {
  String? systemPrompt,
  Uint8List? imageBytes,
  String? model,
}) async {
  try {

    final Object userContent = imageBytes == null
        ? prompt
        : [
            {'type': 'text', 'text': prompt},
            {
              'type': 'image_url',
              'image_url': {
                'url':
                    'data:${_mimeOf(imageBytes)};base64,${base64Encode(imageBytes)}',
              },
            },
          ];

    final response = await http
        .post(
          Uri.parse(AppConfig.apiUrl),
          headers: {
            'Authorization': 'Bearer ${AppConfig.openRouterApiKey}',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://homeease.app',
            'X-Title': 'HomeEase',
          },
          body: jsonEncode({
            'model': model ?? AppConfig.model,
            'messages': [
              if (systemPrompt != null)
                {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userContent},
            ],
          }),
        )
        .timeout(Duration(seconds: imageBytes == null ? 45 : 70));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['choices']?[0]?['message']?['content'];
      if (content is String && content.trim().isNotEmpty) {
        lastAiError = null;
        return content;
      }
      final raw = utf8.decode(response.bodyBytes, allowMalformed: true);
      lastAiError = 'Empty reply (${model ?? AppConfig.model}): '
          '${raw.length > 160 ? raw.substring(0, 160) : raw}';
      return null;
    } else {
      final body = utf8.decode(response.bodyBytes, allowMalformed: true);
      lastAiError =
          'HTTP ${response.statusCode} (${model ?? AppConfig.model}): ${body.length > 200 ? body.substring(0, 200) : body}';
      debugPrint(lastAiError);
      return null;
    }
  } catch (e) {
    lastAiError = 'Exception (${model ?? AppConfig.model}): $e';
    debugPrint(lastAiError);
    return null;
  }
}

String _mimeOf(Uint8List b) {
  if (b.length > 3 && b[0] == 0x89 && b[1] == 0x50) return 'image/png';
  if (b.length > 11 && b[8] == 0x57 && b[9] == 0x45) return 'image/webp';
  return 'image/jpeg';
}

/// نتيجة تحليل المساعد
class AiAnswer {
  final String severity; // low | medium | high
  final String? category; // plumber, electrician, ... أو null
  final String problem; // عنوان قصير للمشكلة
  final String summary;
  final List<String> steps;
  final String warning;
  final bool fromFallback;
  final String? error;

  const AiAnswer({
    required this.severity,
    required this.category,
    this.problem = '',
    required this.summary,
    required this.steps,
    required this.warning,
    this.fromFallback = false,
    this.error,
  });
}

class AiService {
  static const _categories = [
    'plumber', 'electrician', 'carpenter', 'ac', 'painter', 'cleaning',
    'laundry', 'ironing', 'cooking', 'babysitting', 'petcare',
  ];

  static const _systemPrompt = '''
You are "HomeEase AI", an assistant inside a home-services app in Egypt.
The user describes a home problem. Give a SAFE first look, not a final diagnosis.
Reply in the same language the user wrote in (Arabic if they wrote Arabic).
Use EXACTLY this format, plain text only, no markdown:
PROBLEM: short title of the problem (3-6 words)
SEVERITY: low|medium|high
CATEGORY: plumber|electrician|carpenter|ac|painter|cleaning|laundry|ironing|cooking|babysitting|petcare|none
SUMMARY: one or two short sentences
STEPS:
1. first safe step
2. second safe step
3. third safe step
WARNING: one short safety sentence
If the user attached a photo, look at it carefully, identify what the problem is from the photo, and mention what you see in SUMMARY.
Only say the photo is unclear if it is truly black or blurry. Otherwise describe what you actually see, and if it is not a home problem say what it shows and use CATEGORY: none.
Rules: severity is high for gas smell, sparks, burning smell, flooding or exposed wires.
Never tell the user to open electrical parts or touch wires. Keep every step simple and safe.
''';

  static Future<AiAnswer> analyze(String userText, {Uint8List? image}) async {
    final prompt = image == null
        ? userText
        : '$userText\n\n(The user attached a photo of the problem. Analyze the photo.)';

    final modelsToTry =
    image == null ? AppConfig.models : AppConfig.visionModels;

    String? raw;
    String? firstError;
    String used = '';
    for (final m in modelsToTry) {
      raw = await generateTextWithDots(
        prompt,
        systemPrompt: _systemPrompt,
        imageBytes: image,
        model: m,
      );
      if (raw != null) {
        used = m;
        break;
      }
      firstError ??= lastAiError;
      if (lastAiError != null &&
          (lastAiError!.startsWith('HTTP 401') ||
              lastAiError!.startsWith('HTTP 403'))) {
        break;
      }
    }

    if (raw != null) {
      final p = _parse(raw, userText);
      if (p != null) {
        return AiAnswer(
          severity: p.severity,
          category: p.category,
          problem: p.problem,
          summary: p.summary,
          steps: p.steps,
          warning: p.warning,
        );
      }
    }
    final f = fallback(userText);
    return AiAnswer(
      severity: f.severity,
      category: f.category,
      summary: f.summary,
      steps: f.steps,
      warning: f.warning,
      fromFallback: true,
      error: firstError ?? lastAiError,
    );
  }
  static AiAnswer? _parse(String input, String userText) {
    final raw = input.replaceAll('*', '').replaceAll('`', '').trim();
    if (raw.isEmpty) return null;

    String? field(String name) {
      final m = RegExp('$name\\s*[:：]\\s*(.+)', caseSensitive: false)
          .firstMatch(raw);
      return m?.group(1)?.trim();
    }

    final sevRaw = (field('SEVERITY') ?? 'medium').toLowerCase();
    final severity = sevRaw.contains('low')
        ? 'low'
        : sevRaw.contains('high')
            ? 'high'
            : 'medium';

    final catRaw = (field('CATEGORY') ?? '').toLowerCase();
    String? category;
    for (final c in _categories) {
      if (catRaw.contains(c)) {
        category = c;
        break;
      }
    }
    final saidNone = catRaw.contains('none');
    if (!saidNone) category ??= guessCategory(userText);

    final steps = RegExp(r'^\s*\d+\s*[.)\-]\s*(.+)$', multiLine: true)
        .allMatches(raw)
        .map((m) => m.group(1)!.trim())
        .take(3)
        .toList();

    final problem = field('PROBLEM') ?? '';
    var summary = field('SUMMARY');
    final warning = field('WARNING') ?? '';

    if (summary == null && steps.isEmpty) {
      // الموديل ما التزمش بالشكل — اعرض النص كما هو
      summary = raw.length > 400 ? '${raw.substring(0, 400)}…' : raw;
    }

    return AiAnswer(
      severity: severity,
      category: category,
      problem: problem,
      summary: summary ?? '',
      steps: steps,
      warning: warning.isNotEmpty
          ? warning
          : tr('هذا ليس تشخيصاً مؤكداً. عند أي خطر ابتعد واتصل بمختص.',
              'This is not a confirmed diagnosis. If anything feels unsafe, step away and call a professional.'),
    );
  }

  /// تخمين نوع الخدمة من الكلمات
  static String? guessCategory(String text) {
    final t = text.toLowerCase();
    bool any(List<Pattern> k) => k.any((p) => t.contains(p));

    if (any(['كهرب', 'شرر', 'فيشة', 'فيشه', 'قاطع', 'نور', 'electric', 'spark', 'socket', 'wire', 'breaker'])) {
      return 'electrician';
    }
    if (any(['تكييف', 'تبريد', 'يبرد', 'تبرد', 'فريون', RegExp(r'\bac\b'), 'air con', 'cooling'])) {
      return 'ac';
    }
    if (any(['مياه', 'ميه', 'تسريب', 'سباك', 'حوض', 'مواسير', 'ماسورة', 'حنفية', 'صنبور', 'مرحاض', 'leak', 'water', 'pipe', 'sink', 'drain', 'faucet', 'toilet'])) {
      return 'plumber';
    }
    if (any(['باب', 'نجار', 'دولاب', 'خشب', 'door', 'wood', 'wardrobe', 'cabinet'])) {
      return 'carpenter';
    }
    if (any(['دهان', 'نقاش', 'حيطة', 'جدار', 'paint', 'wall'])) return 'painter';
    if (any(['تنظيف', 'نضافة', 'clean'])) return 'cleaning';
    return null;
  }

  /// رد محلي لو الـ API مش متاح
  static AiAnswer fallback(String text) {
    final cat = guessCategory(text);
    switch (cat) {
      case 'ac':
        return AiAnswer(
          severity: 'low',
          category: 'ac',
          fromFallback: true,
          summary: tr(
              'قد يكون فلتر التكييف متّسخاً أو مسدوداً، وهذا يقلّل تدفّق الهواء البارد.',
              'The AC filter may be dirty or blocked, which reduces cold airflow.'),
          steps: [
            tr('أطفئ التكييف وافصل الكهرباء عنه بأمان.',
                'Turn the AC off and cut its power safely.'),
            tr('راجع دليل الجهاز وأزل الفلتر القابل للاستخدام فقط.',
                'Check the manual and remove only the user-removable filter.'),
            tr('نظّفه واتركه يجف تماماً ثم أعد تركيبه قبل التشغيل.',
                'Clean it, let it dry completely, then refit it before switching on.'),
          ],
          warning: tr(
              'توقف عند وجود شرر أو رائحة احتراق أو أجزاء كهربائية مكشوفة. اتصل بمختص.',
              'Stop if you see sparks, smell burning or find exposed electrical parts. Call a professional.'),
        );
      case 'plumber':
        return AiAnswer(
          severity: 'medium',
          category: 'plumber',
          fromFallback: true,
          summary: tr(
              'قد يكون هناك تسريب من وصلة أو خرطوم أسفل الحوض ويحتاج فحصاً مباشراً.',
              'There may be a leak from a joint or hose under the sink that needs an in-person check.'),
          steps: [
            tr('أغلق محبس المياه أسفل الحوض أو المحبس الرئيسي.',
                'Close the valve under the sink or the main water valve.'),
            tr('جفّف المكان وضع وعاءً أسفل التسريب.',
                'Dry the area and place a container under the leak.'),
            tr('صوّر مكان التسريب لمشاركته مع الفني.',
                'Take a photo of the leak to share with the technician.'),
          ],
          warning: tr(
              'ابتعد عن المقابس إن كان الماء قريباً من الكهرباء، واطلب مختصاً.',
              'Keep away from sockets if water is near electricity, and call a professional.'),
        );
      case 'electrician':
        return AiAnswer(
          severity: 'high',
          category: 'electrician',
          fromFallback: true,
          summary: tr(
              'الأعطال الكهربائية خطيرة ولا يُنصح بمحاولة إصلاحها بنفسك.',
              'Electrical faults are dangerous and should not be repaired by yourself.'),
          steps: [
            tr('أوقف القاطع الرئيسي إن كان الوصول إليه آمناً.',
                'Switch off the main breaker if it is safe to reach.'),
            tr('لا تلمس الأسلاك أو الأجهزة المبتلة.',
                'Do not touch wires or wet appliances.'),
            tr('ابتعد عن مكان الشرر وانتظر المختص.',
                'Stay away from the sparking area and wait for the specialist.'),
          ],
          warning: tr(
              'عند شمّ رائحة غاز، غادر المكان واتصل بالطوارئ المحلية.',
              'If you smell gas, leave the place and call local emergency services.'),
        );
      default:
        return AiAnswer(
          severity: 'medium',
          category: cat,
          fromFallback: true,
          summary: tr(
              'أحتاج تفاصيل أكثر، لكن الأفضل أن يفحص المشكلة مختص.',
              'I need more details, but it is best to have a specialist check this.'),
          steps: [
            tr('ابتعد عن أي خطر وأوقف الجهاز المتأثر إن أمكن.',
                'Stay clear of any danger and switch off the affected device if possible.'),
            tr('صوّر المشكلة وسجّل متى بدأت.',
                'Take photos and note when it started.'),
            tr('اطلب مختصاً ليفحصها.', 'Request a specialist to inspect it.'),
          ],
          warning: tr(
              'هذا ليس تشخيصاً مؤكداً. عند أي خطر ابتعد واتصل بمختص.',
              'This is not a confirmed diagnosis. If anything feels unsafe, step away and call a professional.'),
        );
    }
  }
}
