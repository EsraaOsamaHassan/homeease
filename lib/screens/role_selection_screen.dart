import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _role; // 'customer' | 'provider'
  bool _busy = false;
  String? _error;

  Future<void> _continue() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_role == null || user == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'role': _role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // الـ AuthGate هيحوّل تلقائياً بعد ما الـ role يتخزن
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = tr('حدث خطأ، حاول مرة أخرى', 'Something went wrong, try again');
      });
    }
  }

  Widget _card({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _role == value;
    return GestureDetector(
      onTap: _busy ? null : () => setState(() => _role = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: selected ? AppColors.navy : AppColors.muted, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 34, color: selected ? Colors.white : AppColors.navy),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: selected ? Colors.white : AppColors.navy)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: selected ? Colors.white70 : AppColors.muted)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('كيف تريد استخدام HomeEase؟', 'How will you use HomeEase?'),
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy)),
              const SizedBox(height: 8),
              Text(tr('اختر نوع حسابك للمتابعة.', 'Choose your account type to continue.'),
                  style: const TextStyle(color: AppColors.muted, fontSize: 14)),
              const SizedBox(height: 24),
              _card(
                value: 'customer',
                icon: Icons.home_outlined,
                title: tr('عميل', 'Customer'),
                subtitle: tr('أطلب خدمات لمنزلي وأتابع طلباتي',
                    'Request home services and track my requests'),
              ),
              const SizedBox(height: 14),
              _card(
                value: 'provider',
                icon: Icons.handyman_outlined,
                title: tr('مختص', 'Professional'),
                subtitle: tr('أقدّم خدماتي وأستقبل الطلبات',
                    'Offer my services and receive requests'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                InfoBox(
                    text: _error!,
                    color: AppColors.redSoft,
                    icon: Icons.error_outline),
              ],
              const Spacer(),
              PrimaryButton(
                label: _busy ? tr('لحظة…', 'One moment…') : tr('متابعة', 'Continue'),
                onTap: (_busy || _role == null) ? null : _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}