import 'package:flutter/material.dart';

import '../data.dart';
import '../l10n.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'technicians_screen.dart';

class EmergencyReceivedScreen extends StatefulWidget {
  const EmergencyReceivedScreen({super.key, required this.type});
  final EmergencyType type;

  @override
  State<EmergencyReceivedScreen> createState() =>
      _EmergencyReceivedScreenState();
}

class _EmergencyReceivedScreenState extends State<EmergencyReceivedScreen> {
  late final String _id = RequestStore.nextId();

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final service = serviceById(type.serviceId);
    final techs =
        techniciansFor(service.id).where((t) => t.available).toList();
    final eta = techs.isEmpty
        ? 30
        : techs.map((t) => t.etaMin).reduce((a, b) => a < b ? a : b);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                children: [
                  ScreenHeader(
                    eyebrow: tr('الطوارئ · $_id#', 'EMERGENCY · $_id#'),
                    title: tr('تم استلام طلبك العاجل', 'Your urgent request was received'),
                    onBack: () => Navigator.pop(context),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.peach,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_active_outlined,
                              color: AppColors.terracotta),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          tr('نبحث عن مساعدة قريبة الآن', 'Looking for nearby help now'),
                          style: AppText.h1.copyWith(fontSize: 26),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${type.name} · ${tr('المعادي', 'Maadi')}',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.navy),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(tr('الوصول المتوقع', 'Expected arrival'),
                                style: AppText.body),
                            const Spacer(),
                            Text(
                              tr('$eta–${eta + 10} دقيقة', '$eta–${eta + 10} min'),
                              style: AppText.h2,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Pill(tr('بحث ذو أولوية', 'Priority search')),
                        const SizedBox(height: 10),
                        Text(
                          tr('سنتلقى فور تأكيد مختص معتمد. وقت الوصول تقديري وليس مضموناً.',
                              'We will notify you as soon as a certified pro confirms. Arrival time is an estimate, not a guarantee.'),
                          style: AppText.body,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  InfoBox(
                      text: type.tip,
                      color: AppColors.yellowSoft,
                      icon: Icons.info_outline),
                  const SizedBox(height: 10),
                  InfoBox(
                    text: tr(
                        'لم تتم الموافقة على أي عمل أو دفع بعد. سنوافق على التكلفة النهائية أولاً.',
                        'No work or payment has been approved yet. You will approve the final cost first.'),
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
                    label: tr('الاتصال بدعم HomeEase', 'Call HomeEase support'),
                    onTap: () => showSnack(
                        context,
                        tr('الاتصال بالدعم غير مفعّل في النسخة التجريبية',
                            'Calling support is disabled in this demo')),
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: tr('عرض المختصين المتاحين', 'View available specialists'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TechniciansScreen(
                          draft: RequestDraft(
                            id: _id,
                            service: service,
                            description: type.name,
                            location: kDefaultAddress,
                            urgency: Urgency.urgent,
                            when: DateTime.now(),
                            emergency: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
