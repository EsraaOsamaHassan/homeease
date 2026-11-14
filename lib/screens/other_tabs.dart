import 'package:flutter/material.dart';

import '../data.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'request_confirmation_screen.dart';

/// تاب "طلباتي"
class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<List<ServiceRequest>>(
          valueListenable: RequestStore.requests,
          builder: (context, list, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              children: [
                ScreenHeader(
                  eyebrow: tr('متابعة', 'TRACKING'),
                  title: tr('طلباتي', 'My Requests'),
                ),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(
                      children: [
                        const Icon(Icons.receipt_long_outlined,
                            size: 56, color: AppColors.disabled),
                        const SizedBox(height: 12),
                        Text(tr('لا توجد طلبات بعد', 'No requests yet'),
                            style: AppText.body),
                      ],
                    ),
                  ),
                for (final r in list) _card(context, r),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _card(BuildContext context, ServiceRequest r) {
    final accepted = r.accepted.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => RequestConfirmationScreen(request: r)),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                      color: AppColors.peach, shape: BoxShape.circle),
                  child: Icon(r.draft.service.icon,
                      size: 20, color: AppColors.navy),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${r.draft.service.name} · ${r.id}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.navy)),
                      const SizedBox(height: 3),
                      Text(
                        r.draft.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.muted),
                      ),
                      const SizedBox(height: 6),
                      accepted > 0
                          ? Pill(
                              tr('$accepted من ${r.technicians.length} قبلوا الطلب',
                                  '$accepted of ${r.technicians.length} accepted'),
                              bg: AppColors.greenSoft,
                              fg: AppColors.green)
                          : Pill(tr('بانتظار الرد', 'Waiting for reply')),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// تاب "منزلي"
class MyHomeScreen extends StatelessWidget {
  const MyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          children: [
            ScreenHeader(
              eyebrow: tr('بيتك', 'YOUR PLACE'),
              title: tr('منزلي', 'My Home'),
            ),
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                        color: AppColors.peach, shape: BoxShape.circle),
                    child: const Icon(Icons.home_outlined,
                        color: AppColors.navy),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(kDefaultAddress,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InfoBox(
              text: tr('سجل الصيانة وأجهزة منزلك سيظهر هنا قريباً.',
                  'Your home maintenance history and appliances will appear here soon.'),
            ),
          ],
        ),
      ),
    );
  }
}


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = AuthService.user?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          children: [
            ScreenHeader(
              eyebrow: tr('حسابك', 'YOUR ACCOUNT'),
              title: tr('حسابي', 'Profile'),
            ),
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: AppColors.navy, shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      AuthService.user?.email ?? '',
                      style: AppText.h2.copyWith(fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.translate, color: AppColors.navy),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(tr('اللغة: العربية', 'Language: English'),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.terracotta),
                    onPressed: Lang.toggle,
                    child: Text(tr('English', 'العربية')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: tr('تسجيل الخروج', 'Log out'),
              onTap: () async {
                shellTab.value = 0; // عشان تفتح على الرئيسية في الدخول الجاي
                await AuthService.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// تاب "حسابي"
