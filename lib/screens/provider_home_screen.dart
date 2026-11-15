import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homeease/data.dart';

import '../../l10n.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'provider_onboarding_screen.dart';
import 'provider_orders_screen.dart';

class ProviderHomeScreen extends StatelessWidget {
  const ProviderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (context, userSnap) {
            final me = userSnap.data?.data();
            final missing = providerMissing(me);
            final myServices =
                ((me?['services'] as List?) ?? const []).cast<String>();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr('أهلاً بك', 'WELCOME'), style: AppText.eyebrow),
                            const SizedBox(height: 4),
                            Text(tr('طلبات متاحة', 'Open requests'),
                                style: AppText.h1),
                          ],
                        ),
                      ),
                      RoundIconButton(
                        icon: Icons.assignment_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProviderOrdersScreen()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      RoundIconButton(
                        icon: Icons.logout,
                        onTap: () => FirebaseAuth.instance.signOut(),
                      ),
                    ],
                  ),
                ),
                if (missing.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoBox(
                          text: tr(
                              'أكمل بياناتك عشان تقدر تقدّم على الوظائف: ${missing.join('، ')}',
                              'Complete your profile to apply for jobs: ${missing.join(', ')}'),
                          color: AppColors.yellowSoft,
                          icon: Icons.info_outline,
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProviderOnboardingScreen()),
                          ),
                          child: Text(tr('أكمل الآن', 'Complete now'),
                              style: const TextStyle(
                                  color: AppColors.terracotta,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: _RequestsList(
                    uid: uid,
                    myServices: myServices,
                    missing: missing,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RequestsList extends StatelessWidget {
  const _RequestsList({
    required this.uid,
    required this.myServices,
    required this.missing,
  });
  final String uid;
  final List<String> myServices;
  final List<String> missing;

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('requests')
        .where('status', isEqualTo: 'open')
        .limit(100)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) {
          debugPrint('REQUESTS ERROR: ${snap.error}');
          return Center(
              child: Text(tr('تعذر تحميل الطلبات', 'Could not load requests'),
                  style: AppText.body));
        }
        if (!snap.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.terracotta));
        }

        var docs = snap.data!.docs.toList();
        if (myServices.isNotEmpty) {
          docs = docs
              .where((d) => myServices.contains(d.data()['serviceId']))
              .toList();
        }
        docs.sort((a, b) {
          final ta = (a.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          final tb = (b.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
          return tb.compareTo(ta);
        });

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                tr('مفيش طلبات متاحة دلوقتي. هتظهر هنا أول ما حد يطلب خدمتك.',
                    'No open requests right now. They will show up here as soon as someone requests your service.'),
                textAlign: TextAlign.center,
                style: AppText.body,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) =>
              _RequestCard(doc: docs[i], uid: uid, missing: missing),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard(
      {required this.doc, required this.uid, required this.missing});
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final String uid;
  final List<String> missing;

  Future<void> _apply(BuildContext context) async {
    if (missing.isNotEmpty) {
      showSnack(
          context,
          tr('أكمل بياناتك أولاً: ${missing.join('، ')}',
              'Complete your profile first: ${missing.join(', ')}'));
      return;
    }
    try {
      await doc.reference.collection('applications').doc(uid).set({
        'providerId': uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        showSnack(context, tr('تم إرسال تقديمك', 'Application sent'));
      }
    } catch (e) {
      debugPrint('APPLY ERROR: $e');
      if (context.mounted) {
        showSnack(context,
            tr('تعذر التقديم، حاول مرة أخرى', 'Could not apply, try again'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = doc.data();
    final service = kServices.where((s) => s.id == d['serviceId']).firstOrNull;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (service != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.tile,
                      borderRadius: BorderRadius.circular(12)),
                  child: Image.asset(service.icon, height: 26, width: 26),
                ),
              if (service != null) const SizedBox(width: 10),
              Expanded(
                child: Text(
                  (d['title'] as String?) ??
                      (service != null ? tr(service.ar, service.en) : ''),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy),
                ),
              ),
            ],
          ),
          if ((d['description'] as String?)?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Text(d['description'], style: AppText.body),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.place_outlined,
                  size: 16, color: AppColors.muted),
              const SizedBox(width: 4),
              Expanded(
                child: Text((d['city'] as String?) ?? '',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted)),
              ),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: doc.reference
                    .collection('applications')
                    .doc(uid)
                    .snapshots(),
                builder: (context, appSnap) {
                  final applied = appSnap.data?.exists ?? false;
                  return applied
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                              color: AppColors.greenSoft,
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(tr('تم التقديم', 'Applied'),
                              style: const TextStyle(
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12)),
                        )
                      : TextButton(
                          onPressed: () => _apply(context),
                          style: TextButton.styleFrom(
                            backgroundColor: missing.isEmpty
                                ? AppColors.terracotta
                                : AppColors.disabled,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text(tr('قدّم', 'Apply'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800)),
                        );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}