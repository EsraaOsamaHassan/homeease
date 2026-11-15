import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homeease/data.dart';

import '../../l10n.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
// import '../../data/services.dart';   // kServices

typedef _Doc = QueryDocumentSnapshot<Map<String, dynamic>>;

class ProviderOrdersScreen extends StatelessWidget {
  const ProviderOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final stream = FirebaseFirestore.instance
        .collectionGroup('applications')
        .where('providerId', isEqualTo: uid)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) debugPrint('ORDERS ERROR: ${snap.error}');

        final docs = (snap.data?.docs ?? <_Doc>[]).toList()
          ..sort((a, b) {
            final ta = (a.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
            final tb = (b.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
            return tb.compareTo(ta);
          });

        final pending = docs.where((d) => d.data()['status'] == 'pending').toList();
        final active = docs.where((d) => d.data()['status'] == 'accepted').toList();
        final history = docs
            .where((d) => !['pending', 'accepted'].contains(d.data()['status']))
            .toList();

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      children: [
                        RoundIconButton(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.pop(context)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tr('إدارة الطلبات', 'MANAGE JOBS'),
                                  style: AppText.eyebrow),
                              const SizedBox(height: 2),
                              Text(tr('طلباتي', 'My orders'), style: AppText.h1),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    labelColor: AppColors.terracotta,
                    unselectedLabelColor: AppColors.muted,
                    indicatorColor: AppColors.terracotta,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13),
                    tabs: [
                      Tab(text: '${tr('بانتظار الرد', 'Pending')} (${pending.length})'),
                      Tab(text: '${tr('نشطة', 'Active')} (${active.length})'),
                      Tab(text: tr('السجل', 'History')),
                    ],
                  ),
                  Expanded(
                    child: snap.hasError
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                tr('تعذر تحميل الطلبات', 'Could not load your orders'),
                                style: AppText.body,
                              ),
                            ),
                          )
                        : !snap.hasData
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.terracotta))
                            : TabBarView(
                                children: [
                                  _OrdersList(
                                      docs: pending,
                                      empty: tr('مفيش تقديمات بانتظار الرد.',
                                          'No applications waiting for a reply.')),
                                  _OrdersList(
                                      docs: active,
                                      empty: tr('مفيش خدمات نشطة دلوقتي.',
                                          'No active jobs right now.')),
                                  _OrdersList(
                                      docs: history,
                                      empty: tr('السجل فاضي.', 'Nothing in your history yet.')),
                                ],
                              ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.docs, required this.empty});
  final List<_Doc> docs;
  final String empty;

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(empty, textAlign: TextAlign.center, style: AppText.body),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _OrderCard(doc: docs[i]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.doc});
  final _Doc doc;

  static (String, Color, Color) _statusInfo(String? s) {
    switch (s) {
      case 'pending':
        return (tr('بانتظار الرد', 'Pending'), AppColors.yellowSoft, AppColors.star);
      case 'accepted':
        return (tr('تم قبولك', 'Accepted'), AppColors.blueSoft, AppColors.navy);
      case 'completed':
        return (tr('منجزة', 'Completed'), AppColors.greenSoft, AppColors.green);
      case 'rejected':
        return (tr('مرفوض', 'Rejected'), AppColors.redSoft, AppColors.red);
      case 'withdrawn':
        return (tr('تم سحبه', 'Withdrawn'), AppColors.beige, AppColors.muted);
      default:
        return ('—', AppColors.beige, AppColors.muted);
    }
  }

  String _date(Timestamp? t) {
    if (t == null) return '';
    final d = t.toDate();
    return '${d.day}/${d.month}/${d.year}';
  }

  Future<bool> _confirm(BuildContext context, String title, String body) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title, style: AppText.h2),
        content: Text(body, style: AppText.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('رجوع', 'Back'),
                style: const TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('تأكيد', 'Confirm'),
                style: const TextStyle(
                    color: AppColors.terracotta, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _setStatus(BuildContext context, String status) async {
    try {
      await doc.reference.update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('UPDATE ORDER ERROR: $e');
      if (context.mounted) {
        showSnack(context, tr('تعذر التحديث، حاول مرة أخرى', 'Could not update, try again'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = doc.data();
    final status = app['status'] as String?;
    final info = _statusInfo(status);
    final requestRef = doc.reference.parent.parent!;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: requestRef.snapshots(),
      builder: (context, reqSnap) {
        final req = reqSnap.data?.data();
        final service =
            kServices.where((s) => s.id == req?['serviceId']).firstOrNull;
        final missing = reqSnap.hasData && !(reqSnap.data!.exists);

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
                      missing
                          ? tr('الطلب لم يعد متاحاً', 'This request is no longer available')
                          : (req?['title'] as String?) ??
                              (service != null ? tr(service.ar, service.en) : '...'),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: info.$2, borderRadius: BorderRadius.circular(10)),
                    child: Text(info.$1,
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: info.$3)),
                  ),
                ],
              ),
              if ((req?['description'] as String?)?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(req!['description'], style: AppText.body),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.place_outlined,
                      size: 16, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text((req?['city'] as String?) ?? '',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.muted)),
                  ),
                  Text(
                    '${tr('قدّمت في', 'Applied')} ${_date(app['createdAt'] as Timestamp?)}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
                  ),
                ],
              ),
              if (status == 'pending') ...[
                const SizedBox(height: 10),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: OutlinedButton(
                    onPressed: () async {
                      final ok = await _confirm(
                        context,
                        tr('سحب التقديم؟', 'Withdraw application?'),
                        tr('هيتشال تقديمك من الطلب ده.',
                            'Your application will be removed from this request.'),
                      );
                      if (ok && context.mounted) _setStatus(context, 'withdrawn');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: const BorderSide(color: AppColors.red),
                    ),
                    child: Text(tr('سحب التقديم', 'Withdraw'),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
              if (status == 'accepted') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      final ok = await _confirm(
                        context,
                        tr('تأكيد إنجاز الخدمة؟', 'Mark as completed?'),
                        tr('اتأكد إنك خلّصت الخدمة فعلاً قبل ما تأكد.',
                            'Make sure the job is really finished before confirming.'),
                      );
                      if (ok && context.mounted) _setStatus(context, 'completed');
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.terracotta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(tr('تم إنجاز الخدمة', 'Mark as completed'),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}