import 'package:flutter/material.dart';

import '../l10n.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// تأكيد إرسال الطلب + متابعة ردود الفنيين (محاكاة)
class RequestConfirmationScreen extends StatelessWidget {
  const RequestConfirmationScreen({super.key, required this.request});
  final ServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final d = request.draft;

    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<List<ServiceRequest>>(
          valueListenable: RequestStore.requests,
          builder: (context, _, __) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                    children: [
                      ScreenHeader(
                        eyebrow: '${tr('الطلب', 'REQUEST')} · ${request.id}',
                        title: d.emergency
                            ? tr('تم إرسال طلبك العاجل', 'Urgent request sent')
                            : tr('تم إرسال طلبك', 'Request sent'),
                        onBack: () => Navigator.pop(context),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.greenSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                  color: AppColors.green, shape: BoxShape.circle),
                              child: const Icon(Icons.check, color: Colors.white),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${d.service.name} · ${urgencyLabel(d.urgency)}',
                                    style: AppText.h2.copyWith(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${fmtDate(d.when)} · ${fmtTime(d.when)}',
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        tr('ردود الفنيين', 'Technician responses'),
                        style: AppText.h2.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      for (final t in request.technicians) _techRow(t),
                      const SizedBox(height: 4),
                      InfoBox(
                        text: tr(
                            'لم تتم الموافقة على أي عمل أو دفع بعد. ستوافق على التكلفة النهائية قبل بدء العمل.',
                            'No work or payment has been approved yet. You approve the final cost before work starts.'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SecondaryButton(
                        label: tr('العودة للرئيسية', 'Back to home'),
                        onTap: () {
                          shellTab.value = 0;
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        },
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        label: tr('متابعة طلباتي', 'Track my requests'),
                        onTap: () {
                          shellTab.value = 1;
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _techRow(Technician t) {
    final accepted = request.accepted.contains(t.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: accepted ? AppColors.green : AppColors.border,
            width: accepted ? 1.4 : 1),
      ),
      child: Row(
        children: [
          TechAvatar(t, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.navy)),
                const SizedBox(height: 4),
                accepted
                    ? Pill(
                        tr('قبل الطلب · يصل خلال ${t.etaMin} دقيقة',
                            'Accepted · arrives in ${t.etaMin} min'),
                        bg: AppColors.greenSoft,
                        fg: AppColors.green,
                        icon: Icons.check_circle_outline)
                    : Pill(tr('بانتظار الرد', 'Waiting for reply'),
                        bg: AppColors.yellowSoft,
                        fg: const Color(0xFF8A5A00),
                        icon: Icons.hourglass_top),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
              Text(t.rating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
