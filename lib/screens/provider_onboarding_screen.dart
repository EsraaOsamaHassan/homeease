import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homeease/data.dart';

import '../../l10n.dart';
import '../../theme.dart';
import '../../widgets/common.dart';


List<String> providerMissing(Map<String, dynamic>? d) {
  final m = <String>[];
  if (((d?['services'] as List?) ?? const []).isEmpty) {
    m.add(tr('اختيار الخدمات', 'Choose services'));
  }
  if ((d?['experienceYears'] as String?) == null) {
    m.add(tr('سنوات الخبرة', 'Years of experience'));
  }
  if (((d?['phone'] as String?) ?? '').isEmpty) {
    m.add(tr('رقم الهاتف', 'Phone number'));
  }
  return m;
}

class ProviderOnboardingScreen extends StatefulWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  State<ProviderOnboardingScreen> createState() =>
      _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState extends State<ProviderOnboardingScreen> {
  static const _yearsOptions = {
    'lt1': ('أقل من سنة', 'Under 1 year'),
    '1-3': ('1 - 3 سنوات', '1 - 3 years'),
    '3-5': ('3 - 5 سنوات', '3 - 5 years'),
    '5-10': ('5 - 10 سنوات', '5 - 10 years'),
    '10+': ('أكثر من 10 سنوات', '10+ years'),
  };

  int _step = 0;
  final Set<String> _selected = {};
  final _phone = TextEditingController();
  final _name = TextEditingController();
  String? _years;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _save({required bool skipped}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'onboardingDone': true,
        if (_name.text.trim().isNotEmpty) 'name': _name.text.trim(),
        if (_selected.isNotEmpty) 'services': _selected.toList(),
        if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
        if (_years != null) 'experienceYears': _years,
      }, SetOptions(merge: true));
      // الـ AuthGate هيحوّله تلقائياً لشاشة المختص
      // ولو الصفحة اتفتحت من زرار "أكمل الآن" بنقفلها
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
    } catch (e) {
      debugPrint('ONBOARDING SAVE ERROR: $e');
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = tr('حدث خطأ، حاول مرة أخرى', 'Something went wrong, try again');
      });
    }
  }

  Future<void> _skip() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(tr('تخطّي الآن؟', 'Skip for now?'), style: AppText.h2),
        content: Text(
          tr('تقدر تتصفح التطبيق، لكن مش هتقدر تقدّم على أي وظيفة قبل ما تختار خدماتك، '
              'وتكتب سنين خبرتك ورقم هاتفك.',
              'You can browse the app, but you won’t be able to apply for any job until '
              'you pick your services and add your experience and phone number.'),
          style: AppText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('أكمل الآن', 'Complete now'),
                style: const TextStyle(color: AppColors.terracotta)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('تخطّي', 'Skip'),
                style: const TextStyle(color: AppColors.muted)),
          ),
        ],
      ),
    );
    if (ok == true) _save(skipped: true);
  }

  void _next() {
    if (_step == 0) {
      setState(() => _step = 1);
      return;
    }
    if (_name.text.trim().isEmpty) {
      setState(() => _error = tr('أدخل اسمك', 'Enter your name'));
      return;
    }
    final phone = _phone.text.trim();
    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(phone)) {
      setState(() => _error =
          tr('أدخل رقم هاتف صحيح', 'Enter a valid phone number'));
      return;
    }
    if (_years == null) {
      setState(() => _error =
          tr('اختر سنوات خبرتك', 'Choose your years of experience'));
      return;
    }
    _save(skipped: false);
  }

  // ───────────── الخطوة 1: الخدمات ─────────────
  Widget _servicesStep() {
    return GridView.builder(
      itemCount: kServices.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (_, i) {
        final s = kServices[i];
        final on = _selected.contains(s.id);
        return GestureDetector(
          onTap: () => setState(() {
            on ? _selected.remove(s.id) : _selected.add(s.id);
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: on ? AppColors.peach : AppColors.tile,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: on ? AppColors.terracotta : AppColors.border,
                  width: on ? 2 : 1),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(s.icon, height: 38, width: 38),
                      const SizedBox(height: 8),
                      Text(
                        tr(s.ar, s.en),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy),
                      ),
                    ],
                  ),
                ),
                if (on)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(Icons.check_circle,
                        size: 18, color: AppColors.terracotta),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────── الخطوة 2: البيانات والتوثيق ─────────────
  Widget _detailsStep() {
    return ListView(
      children: [
        Text(tr('الاسم', 'Name'), style: AppText.label),
        const SizedBox(height: 8),
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: fieldDecoration(
            hint: tr('اسمك الذي سيظهر للعملاء', 'Your name as customers will see it'),
            suffix: const Icon(Icons.person_outline,
                size: 20, color: AppColors.navy),
          ),
        ),
        const SizedBox(height: 18),
        Text(tr('رقم الهاتف', 'Phone number'), style: AppText.label),
        const SizedBox(height: 8),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: fieldDecoration(
            hint: '+20 10XXXXXXXX',
            suffix: const Icon(Icons.phone_outlined,
                size: 20, color: AppColors.navy),
          ),
        ),
        const SizedBox(height: 18),
        Text(tr('سنوات الخبرة', 'Years of experience'), style: AppText.label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _yearsOptions.entries.map((e) {
            final on = _years == e.key;
            return ChoiceChip(
              label: Text(tr(e.value.$1, e.value.$2)),
              selected: on,
              onSelected: (_) => setState(() => _years = e.key),
              selectedColor: AppColors.terracotta,
              backgroundColor: Colors.white,
              side: BorderSide(
                  color: on ? AppColors.terracotta : AppColors.border),
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: on ? Colors.white : AppColors.navy),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final canNext = _step == 0 ? _selected.isNotEmpty : true;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_step == 1)
                    RoundIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => setState(() {
                              _step = 0;
                              _error = null;
                            })),
                  const Spacer(),
                  TextButton(
                    onPressed: _busy ? null : _skip,
                    child: Text(tr('تخطّي', 'Skip'),
                        style: const TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              Text(tr('الخطوة ${_step + 1} من 2', 'STEP ${_step + 1} OF 2'),
                  style: AppText.eyebrow),
              const SizedBox(height: 6),
              Text(
                _step == 0
                    ? tr('ما الخدمات التي تقدمها؟', 'What services do you offer?')
                    : tr('أكمل ملفك المهني', 'Complete your profile'),
                style: AppText.h1,
              ),
              const SizedBox(height: 6),
              Text(
                _step == 0
                    ? tr('اختر خدمة أو أكثر.', 'Pick one or more.')
                    : tr('هذه البيانات مطلوبة للتقديم على الوظائف.',
                        'These details are required to apply for jobs.'),
                style: AppText.body,
              ),
              const SizedBox(height: 16),
              Expanded(child: _step == 0 ? _servicesStep() : _detailsStep()),
              if (_error != null) ...[
                const SizedBox(height: 8),
                InfoBox(
                    text: _error!,
                    color: AppColors.redSoft,
                    icon: Icons.error_outline),
              ],
              const SizedBox(height: 12),
              PrimaryButton(
                label: _busy
                    ? tr('لحظة…', 'One moment…')
                    : _step == 0
                        ? tr('التالي', 'Next')
                        : tr('إنهاء', 'Finish'),
                onTap: (_busy || !canNext) ? null : _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
