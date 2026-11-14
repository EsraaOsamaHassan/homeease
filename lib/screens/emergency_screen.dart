import 'package:flutter/material.dart';

import '../data.dart';
import '../l10n.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'emergency_received_screen.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  int _sel = 0;

  @override
  Widget build(BuildContext context) {
    final type = kEmergencyTypes[_sel];
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
                    eyebrow: tr('دعم HomeEase', 'HOMEEASE SUPPORT'),
                    title: tr('مساعدة عاجلة بهدوء', 'Urgent help, calmly'),
                    onBack: () => Navigator.pop(context),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.terracotta,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tr('نحن هنا من أجل منزلك', "We're here for your home"),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 8),
                              Text(
                                tr('اختر المشكلة، سنعطي الأولوية للمختصين المعتمدين القريبين.',
                                    'Choose the problem and we will prioritise nearby certified pros.'),
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    height: 1.6),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.notifications_active_outlined,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < kEmergencyTypes.length; i++)
                    _typeTile(i),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('عدد المختصين المعتمدين المتاحين الآن: ${techs.length}',
                              '${techs.length} certified pros available now'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                              fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tr('الوصول المتوقع: $eta–${eta + 10} دقيقة',
                              'Estimated arrival: $eta–${eta + 10} min'),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.green),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tr('تظهر رسوم الاستعجال قبل الموافقة',
                              'Urgency fees are shown before you approve'),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () => showSnack(
                        context,
                        tr('الاتصال بالدعم غير مفعّل في النسخة التجريبية',
                            'Calling support is disabled in this demo')),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_in_talk_outlined,
                              size: 18, color: AppColors.terracotta),
                          const SizedBox(width: 8),
                          Text(
                            tr('اتصل بدعم HomeEase العاجل',
                                'Call HomeEase urgent support'),
                            style: const TextStyle(
                                color: AppColors.terracotta,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: PrimaryButton(
                label: tr('طلب ${service.ar} للطوارئ',
                    'Request emergency ${service.en}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EmergencyReceivedScreen(type: type)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeTile(int i) {
    final t = kEmergencyTypes[i];
    final selected = i == _sel;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? const Color(0xFFFFF6F0) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _sel = i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.terracotta : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color:
                          selected ? AppColors.terracotta : AppColors.border,
                      width: selected ? 6 : 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(t.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.navy)),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                      color: AppColors.peach, shape: BoxShape.circle),
                  child: Icon(t.icon, size: 17, color: AppColors.navy),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
