import 'package:flutter/material.dart';

import '../data.dart';
import '../l10n.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'emergency_screen.dart';
import 'request_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    bool match(ServiceItem s) =>
        q.isEmpty || s.ar.contains(q) || s.en.toLowerCase().contains(q);
    final maintenance =
        kServices.where((s) => s.maintenance && match(s)).toList();
    final household =
        kServices.where((s) => !s.maintenance && match(s)).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(tr('المنزل · المعادي، القاهرة', 'HOME · MAADI, CAIRO'),
                      style: AppText.eyebrow),
                ),
                RoundIconButton(icon: Icons.translate, onTap: Lang.toggle),
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
            const SizedBox(height: 22),
            Text(tr('محتاج مساعدة في إيه؟', 'What do you need help with?'),
                style: AppText.h1.copyWith(fontSize: 22)),
            const SizedBox(height: 6),
            Text(tr('دوّر على خدمتك', 'Find your next helping hand'),
                style: AppText.label.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: fieldDecoration(
                hint: tr('ابحث عن خدمة...', 'Search a service...'),
                suffix: const Icon(Icons.search, color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: tr('مساعدة طارئة', 'Emergency help'),
              icon: null,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EmergencyScreen())),
            ),
            if (maintenance.isNotEmpty) ...[
              const SizedBox(height: 22),
              Text(tr('صيانة المنزل', 'Home Maintenance'), style: AppText.h2),
              const SizedBox(height: 12),
              _grid(maintenance),
            ],
            if (household.isNotEmpty) ...[
              const SizedBox(height: 22),
              Text(tr('خدمات المنزل', 'Home Services'), style: AppText.h2),
              const SizedBox(height: 12),
              _grid(household),
            ],
            if (maintenance.isEmpty && household.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(tr('لا توجد خدمات مطابقة', 'No matching services'),
                      style: AppText.body),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _grid(List<ServiceItem> items) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.05,
      children: items.map((s) => _ServiceTile(service: s)).toList(),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service});
  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.tile,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RequestScreen(service: service)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                    color: AppColors.peach, shape: BoxShape.circle),
                child: Icon(service.icon, size: 18, color: AppColors.navy),
              ),
              const SizedBox(height: 8),
              Text(
                service.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
