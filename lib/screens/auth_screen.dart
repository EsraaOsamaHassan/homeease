import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// شاشة تسجيل الدخول + إنشاء حساب (نفس الشاشة بتتبدّل بين الوضعين)
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();

  bool _register = false;
  bool _hide = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _pass2.dispose();
    super.dispose();
  }

  void _switchMode() => setState(() {
    _register = !_register;
    _error = null;
  });

  String? _validate() {
    final email = _email.text.trim();

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return tr('أدخل بريداً إلكترونياً صحيحاً', 'Enter a valid email address');
    }
    if (_pass.text.length < 6) {
      return tr('كلمة المرور 6 أحرف على الأقل', 'Password must be at least 6 characters');
    }
    if (_register && _pass.text != _pass2.text) {
      return tr('كلمتا المرور غير متطابقتين', 'Passwords do not match');
    }
    return null;
  }

  Future<void> _submit() async {
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = _register
        ? await AuthService.register(_email.text, _pass.text)
        : await AuthService.signIn(_email.text, _pass.text);

    if (!mounted) return;
    // لو نجح، الـ AuthGate هيبدّل الشاشة تلقائياً
    setState(() {
      _busy = false;
      _error = err;
    });
  }

  Future<void> _google() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await AuthService.google();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
  }

  Future<void> _forgot() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error =
          tr('اكتب بريدك أولاً ثم اضغط "نسيت كلمة المرور"',
              'Enter your email first, then tap "Forgot password?"'));
      return;
    }
    final err = await AuthService.resetPassword(email);
    if (!mounted) return;
    if (err != null) {
      setState(() => _error = err);
    } else {
      setState(() => _error = null);
      showSnack(context,
          tr('أرسلنا رابط إعادة تعيين كلمة المرور إلى بريدك',
              'We sent a password reset link to your email'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _register
        ? tr('أنشئ حسابك', 'Create your account')
        : tr('أهلاً بعودتك', 'Welcome back');
    final subtitle = _register
        ? tr('سجّل لتطلب خدمات منزلك وتتابع طلباتك مع مختصين موثوقين.',
        'Sign up to request home services and track your requests with trusted professionals.')
        : tr('سجّل الدخول لترى طلباتك وسجل منزلك والمختصين الموثوقين.',
        'Sign in to see your requests, home history and trusted professionals.');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                children: [
                  ScreenHeader(
                    eyebrow: tr('منزلك في أيدٍ أمينة', 'YOUR HOME IS IN GOOD HANDS'),
                    title: title,
                    onBack: _register ? _switchMode : null,
                    trailing: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const RoundIconButton(
                              icon: Icons.translate, onTap: Lang.toggle),
                          const SizedBox(width: 8),
                          RoundIconButton(
                            icon: Icons.help_outline,
                            onTap: () => showSnack(
                                context,
                                tr('للمساعدة تواصل مع دعم HomeEase',
                                    'Need help? Contact HomeEase support')),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // صورة الغلاف: ضعي صورة في assets/images/login.jpg
                  // ولو مش موجودة بيظهر تدرّج دافئ بدلها
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 128,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/HomeEase_ Your Home, Our Care.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const PhotoBox(height: 128),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 14, height: 1.5, color: AppColors.muted)),
                  const SizedBox(height: 18),

                  _label(tr('البريد الإلكتروني', 'Email')),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: fieldDecoration(
                      hint: 'name@email.com',
                      suffix: const Icon(Icons.mail_outline,
                          size: 20, color: AppColors.navy),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _label(tr('كلمة المرور', 'Password')),
                  TextField(
                    controller: _pass,
                    obscureText: _hide,
                    textInputAction:
                    _register ? TextInputAction.next : TextInputAction.done,
                    onSubmitted: (_) => _register ? null : _submit(),
                    decoration: fieldDecoration(
                      hint: '••••••••',
                      suffix: IconButton(
                        icon: Icon(
                            _hide
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: AppColors.navy),
                        onPressed: () => setState(() => _hide = !_hide),
                      ),
                    ),
                  ),
                  if (_register) ...[
                    const SizedBox(height: 14),
                    _label(tr('تأكيد كلمة المرور', 'Confirm password')),
                    TextField(
                      controller: _pass2,
                      obscureText: _hide,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      decoration: fieldDecoration(hint: '••••••••'),
                    ),
                  ],
                  if (!_register) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: _forgot,
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 36)),
                        child: Text(tr('نسيت كلمة المرور؟', 'Forgot password?'),
                            style: const TextStyle(
                                color: AppColors.navy,
                                fontWeight: FontWeight.w800,
                                fontSize: 12)),
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    InfoBox(
                        text: _error!,
                        color: AppColors.redSoft,
                        icon: Icons.error_outline),
                  ],
                  const SizedBox(height: 14),
                  SecondaryButton(
                    label: tr('المتابعة بحساب Google', 'Continue with Google'),
                    onTap: _busy ? () {} : _google,
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: _busy ? null : _switchMode,
                      child: Text(
                        _register
                            ? tr('لديك حساب؟ سجّل الدخول', 'Already have an account? Log in')
                            : tr('جديد هنا؟ أنشئ حساباً', 'New here? Create an account'),
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  InfoBox(
                    text: tr(
                        'بياناتك تبقى خاصة. بالمتابعة فأنت توافق على الشروط وسياسة الخصوصية.',
                        'Your details stay private. By continuing, you agree to our Terms and Privacy Policy.'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: PrimaryButton(
                label: _busy
                    ? tr('لحظة…', 'One moment…')
                    : _register
                    ? tr('إنشاء الحساب', 'Create account')
                    : tr('تسجيل الدخول', 'Log In'),
                onTap: _busy ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) =>
      Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: AppText.label));
}