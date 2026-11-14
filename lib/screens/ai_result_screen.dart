import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/ai_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'request_screen.dart';

class AiResultScreen extends StatefulWidget {
  const AiResultScreen({super.key, required this.userText, this.image});
  final String userText;
  final Uint8List? image;

  @override
  State<AiResultScreen> createState() => _AiResultScreenState();
}

class _AiResultScreenState extends State<AiResultScreen> {
  AiAnswer? _answer;
  String? _pickedCategory;

  String? get _cat => _pickedCategory ?? _answer?.category;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final a = await AiService.analyze(widget.userText, image: widget.image);
    if (!mounted) return;
    setState(() => _answer = a);
  }

  @override
  Widget build(BuildContext context) {
    final a = _answer;
    final low = a?.severity == 'low';

    final eyebrow = a == null
        ? tr('المساعد · جارٍ التحليل', 'ASSISTANT · ANALYZING')
        : low
            ? tr('المساعد · إرشادات ذاتية', 'ASSISTANT · SELF-GUIDANCE')
            : tr('المساعد · إحالة إلى مختص', 'ASSISTANT · SPECIALIST REFERRAL');
    final title = a == null
        ? tr('لحظة من فضلك…', 'One moment…')
        : low
            ? tr('خطوة آمنة يمكنك تجربتها', 'A safe step you can try')
            : tr('لنستعن بمختص', "Let's call a specialist");

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                children: [
                  ScreenHeader(
                    eyebrow: eyebrow,
                    title: title,
                    onBack: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child:
                            const Icon(Icons.auto_awesome, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('HomeEase AI',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppColors.navy)),
                            Text(
                              tr('نظرة أولية مفيدة، وليست تشخيصاً نهائياً',
                                  'A helpful first look, not a final diagnosis'),
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (widget.image != null) ...[
                    PhotoBox(bytes: widget.image, height: 160),
                    const SizedBox(height: 12),
                  ],
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.beige,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${tr('أنت', 'You')}: «${widget.userText}»',
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (a == null) _loading() else ..._answerWidgets(a, low),
                ],
              ),
            ),
            if (a != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: PrimaryButton(
                  label: _ctaLabel(a, low),
                  onTap: () {
                    final cat = _cat;
                    if (cat == null) {
                      showSnack(context,
                          tr('اختر نوع المختص أولاً', 'Pick a specialist type first'));
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RequestScreen(
                          service: serviceById(cat),
                          description: widget.userText,
                          image: widget.image,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _ctaLabel(AiAnswer a, bool low) {
    if (_cat == null) return tr('اختر نوع المختص', 'Pick a specialist type');
    final s = serviceById(_cat!);
    if (low) {
      return tr('لم تنجح الخطوة؟ ابحث عن فني', "Didn't work? Find a technician");
    }
    return tr('ابحث عن ${s.ar} الآن', 'Find a ${s.en} now');
  }

  Widget _loading() {
    return AppCard(
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.4, color: AppColors.terracotta),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              tr('المساعد يحلل وصفك بهدوء…', 'The assistant is looking at your description…'),
              style: AppText.body,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _answerWidgets(AiAnswer a, bool low) {
    final sev = switch (a.severity) {
      'low' => (
          tr('تقدير أولي · خطورة منخفضة', 'Initial estimate · low severity'),
          AppColors.greenSoft,
          AppColors.green
        ),
      'high' => (
          tr('تقدير أولي · خطورة عالية', 'Initial estimate · high severity'),
          AppColors.redSoft,
          AppColors.red
        ),
      _ => (
          tr('تقدير أولي · خطورة متوسطة', 'Initial estimate · medium severity'),
          AppColors.yellowSoft,
          const Color(0xFF8A5A00)
        ),
    };

    return [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: Pill(sev.$1, bg: sev.$2, fg: sev.$3),
      ),
      const SizedBox(height: 10),
      AppCard(
        padding: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              low
                  ? tr('يمكنك تجربة حل بسيط بنفسك', 'You can try a simple fix yourself')
                  : tr('تحتاج إلى مختص', 'You need a specialist'),
              style: AppText.h1.copyWith(fontSize: 21),
            ),
            if (a.problem.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('${tr('المشكلة', 'Problem')}: ${a.problem}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.terracotta)),
            ],
            if (a.summary.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(a.summary,
                  style: const TextStyle(
                      fontSize: 13, height: 1.6, color: AppColors.textDark)),
            ],
            if (a.steps.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (var i = 0; i < a.steps.length; i++) _step(i + 1, a.steps[i]),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
      _specialistCard(),
      const SizedBox(height: 12),
      InfoBox(text: a.warning, color: AppColors.yellowSoft),
      if (a.fromFallback) ...[
        const SizedBox(height: 8),
        InfoBox(
          color: AppColors.redSoft,
          icon: Icons.wifi_off,
          text: tr(
              'المساعد الذكي مش متصل، فده رد جاهز مش تحليل لرسالتك.\nالسبب: ${a.error ?? 'غير معروف'}',
              'The AI is not connected, so this is a canned reply, not an analysis of your message.\nReason: ${a.error ?? 'unknown'}'),
        ),
      ],
    ];
  }

  /// نوع المختص المطلوب + الفنيين المقترحين
  Widget _specialistCard() {
    final cat = _cat;
    if (cat == null) {
      return AppCard(
        padding: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('لم أستطع تحديد المختص من الوصف. اختر النوع المناسب:',
                  "I couldn't tell which specialist you need. Pick one:"),
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in kServices)
                  ActionChip(
                    avatar: Icon(s.icon, size: 16, color: AppColors.navy),
                    label: Text(s.name),
                    onPressed: () => setState(() => _pickedCategory = s.id),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    final s = serviceById(cat);
    final techs = techniciansFor(cat)
      ..sort((a, b) => (b.rating * 10 - b.distanceKm * 2)
          .compareTo(a.rating * 10 - a.distanceKm * 2));
    final top = techs.take(3).toList();

    return AppCard(
      padding: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: AppColors.peach,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(s.icon, color: AppColors.navy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr('المختص المطلوب', 'Specialist needed'),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.muted)),
                    Text(s.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy)),
                  ],
                ),
              ),
              if (_pickedCategory != null)
                TextButton(
                  onPressed: () => setState(() => _pickedCategory = null),
                  child: Text(tr('تغيير', 'Change')),
                ),
            ],
          ),
          if (top.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(tr('فنيون مقترحون', 'Suggested technicians'), style: AppText.label),
            const SizedBox(height: 8),
            for (final t in top)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    TechAvatar(t, size: 40),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.name,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                          Text(
                            '★ ${t.rating} · ${t.distanceKm} ${tr('كم', 'km')} · ${t.etaMin} ${tr('د', 'min')}',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    Text('${t.priceFrom} ${tr('ج', 'EGP')}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _step(int n, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.peach,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text('$n',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12.5, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
