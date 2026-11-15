import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homeease/screens/createRequestInFirestore.dart';

import '../data.dart';
import '../l10n.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'request_confirmation_screen.dart' hide createRequestInFirestore;

class TechniciansScreen extends StatefulWidget {
  const TechniciansScreen({super.key, required this.draft});
  final RequestDraft draft;

  @override
  State<TechniciansScreen> createState() => _TechniciansScreenState();
}

class _TechniciansScreenState extends State<TechniciansScreen> {
  static const _maxSelected = 5;
  late int _sort = widget.draft.emergency ? 2 : 0;
  final Set<String> _selected = {};
  bool _sending = false;
  List<Technician> _real = []; // مختصين حقيقيين من Firestore

  @override
  void initState() {
    super.initState();
    _loadReal();
  }

  Future<void> _loadReal() async {
    try {
      final sid = widget.draft.service.id;
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'provider')
          .limit(100)
          .get();
      final list = snap.docs
          .where((d) => ((d.data()['services'] as List?) ?? const []).contains(sid))
          .map((d) => Technician.fromUser(d.id, d.data(), sid))
          .toList();
      if (mounted) setState(() => _real = list);
    } catch (e) {
      debugPrint('LOAD PROVIDERS ERROR: $e');
    }
  }

  List<Technician> get _pool =>
      [..._real, ...techniciansFor(widget.draft.service.id)];

  List<Technician> get _all {
    var list = techniciansFor(widget.draft.service.id);
    if (widget.draft.emergency) {
      list = list.where((t) => t.available).toList();
    }
    double score(Technician t) =>
        t.rating * 10 - t.distanceKm * 2 + (t.available ? 8 : 0);
    switch (_sort) {
      case 0:
        list.sort((a, b) => score(b).compareTo(score(a)));
        break;
      case 1:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 2:
        list.sort((a, b) => a.etaMin.compareTo(b.etaMin));
        break;
      case 3:
        list.sort((a, b) => a.priceFrom.compareTo(b.priceFrom));
        break;
    }
    return [..._real, ...list]; // المختصين الحقيقيين الأول
  }

  void _toggle(Technician t) {
    setState(() {
      if (_selected.contains(t.id)) {
        _selected.remove(t.id);
      } else if (_selected.length >= _maxSelected) {
        showSnack(
            context,
            tr('يمكنك اختيار 5 فنيين كحد أقصى',
                'You can select up to 5 technicians'));
      } else {
        _selected.add(t.id);
      }
    });
  }

  Future<void> _send() async {
    if (_sending) return;
    setState(() => _sending = true);

    final chosen = _pool.where((t) => _selected.contains(t.id)).toList();
    final r = ServiceRequest(
      id: widget.draft.id ?? RequestStore.nextId(),
      draft: widget.draft,
      technicians: chosen,
    );

    try {
      await createRequestInFirestore(widget.draft,
          code: r.id,
          invitedProviders:
              chosen.where((t) => t.isReal).map((t) => t.id).toList());
    } catch (e) {
      debugPrint('CREATE REQUEST ERROR: $e');
      if (!mounted) return;
      setState(() => _sending = false);
      showSnack(
          context,
          tr('تعذر إرسال الطلب، حاول مرة أخرى',
              'Could not send the request, try again'));
      return;
    }

    RequestStore.add(r); // لسه محاكاة لحد ما نربط الردود بـ Firestore
    if (!mounted) return;
    setState(() => _sending = false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RequestConfirmationScreen(request: r)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final list = _all;
    final sorts = [
      tr('الأنسب', 'Best match'),
      tr('الأعلى تقييماً', 'Top rated'),
      tr('الأسرع وصولاً', 'Fastest'),
      tr('الأقل سعراً', 'Lowest price'),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                children: [
                  ScreenHeader(
                    eyebrow: draft.emergency
                        ? tr('الطوارئ · المتاحون الآن', 'EMERGENCY · AVAILABLE NOW')
                        : tr('الفنيون المقترحون', 'SUGGESTED TECHNICIANS'),
                    title: tr('الأنسب لمهمتك', 'Best for your task'),
                    onBack: () => Navigator.pop(context),
                  ),
                  AppCard(
                    color: AppColors.blueSoft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(draft.service.icon, width: 18, height: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${draft.service.name} · ${urgencyLabel(draft.urgency)}',
                                style: AppText.label.copyWith(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          draft.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, height: 1.5, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(draft.location,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr('اختر من 1 إلى 5 فنيين لإرسال طلبك إليهم.',
                        'Pick 1 to 5 technicians to send your request to.'),
                    style: AppText.body,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: sorts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => ChoiceChip(
                        label: Text(sorts[i]),
                        selected: _sort == i,
                        selectedColor: AppColors.navy,
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _sort == i ? Colors.white : AppColors.navy,
                        ),
                        onSelected: (_) => setState(() => _sort = i),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (list.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Center(
                        child: Text(
                            tr('لا يوجد فنيون متاحون الآن', 'No technicians available right now'),
                            style: AppText.body),
                      ),
                    ),
                  for (final t in list) _card(t),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: PrimaryButton(
                label: _selected.isEmpty
                    ? tr('اختر فنياً واحداً على الأقل', 'Select at least one technician')
                    : tr('إرسال الطلب إلى (${_selected.length})',
                        'Send request to (${_selected.length})'),
                             onTap: (_selected.isEmpty || _sending) ? null : _send,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Technician t) {
    final selected = _selected.contains(t.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _toggle(t),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? AppColors.terracotta : AppColors.border,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TechAvatar(t),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(t.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: AppColors.navy)),
                              ),
                              if (!t.isReal) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified,
                                    size: 16, color: Color(0xFF3F86C7)),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(serviceById(t.serviceId).name,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                          const SizedBox(height: 4),
                          if (t.isReal)
                            Text(tr('مختص جديد', 'New provider'),
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600))
                          else
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 16, color: AppColors.star),
                              const SizedBox(width: 3),
                              Text(
                                '${t.rating.toStringAsFixed(1)} · ${t.jobs} ${tr('مهمة', 'jobs')}',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: selected ? AppColors.terracotta : AppColors.border,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (!t.isReal) ...[
                      _stat(Icons.place_outlined,
                          '${t.distanceKm.toStringAsFixed(1)} ${tr('كم', 'km')}'),
                      _stat(Icons.schedule, '${t.etaMin} ${tr('د', 'min')}'),
                      _stat(Icons.payments_outlined,
                          tr('من ${t.priceFrom} ج.م', 'From EGP ${t.priceFrom}')),
                    ],
                    t.available
                        ? Pill(tr('متاح الآن', 'Available now'),
                            bg: AppColors.greenSoft, fg: AppColors.green)
                        : Pill(tr('مشغول حالياً', 'Busy right now'),
                            bg: AppColors.beige, fg: AppColors.muted),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final tag in t.tags)
                            Pill(tag, bg: AppColors.tile, fg: AppColors.navy),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showDetails(t),
                      child: Text(tr('التفاصيل', 'Details'),
                          style: const TextStyle(
                              color: AppColors.terracotta,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.muted),
        const SizedBox(width: 3),
        Text(text,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textDark)),
      ],
    );
  }

  void _showDetails(Technician t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final selected = _selected.contains(t.id);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TechAvatar(t, size: 60),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, style: AppText.h2),
                        const SizedBox(height: 2),
                        Text(serviceById(t.serviceId).name,
                            style: AppText.body),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _box(t.rating.toStringAsFixed(1), tr('التقييم', 'Rating')),
                  const SizedBox(width: 8),
                  _box('${t.jobs}', tr('مهمة منجزة', 'Jobs done')),
                  const SizedBox(width: 8),
                  _box('${t.years}', tr('سنوات خبرة', 'Years exp.')),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in t.tags)
                    Pill(tag, bg: AppColors.peach, fg: AppColors.navy),
                ],
              ),
              const SizedBox(height: 14),
              InfoBox(
                text: tr(
                    'يبدأ السعر من ${t.priceFrom} ج.م. التكلفة النهائية تُعرض عليك للموافقة قبل بدء أي عمل. (بيانات تجريبية)',
                    'Prices start from EGP ${t.priceFrom}. The final cost is shown for your approval before any work starts. (Demo data)'),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                icon: null,
                label: selected
                    ? tr('إلغاء الاختيار', 'Remove from selection')
                    : tr('اختيار هذا الفني', 'Select this technician'),
                onTap: () {
                  Navigator.pop(ctx);
                  _toggle(t);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _box(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
