import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data.dart';
import '../l10n.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'technicians_screen.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({
    super.key,
    this.service,
    this.description = '',
    this.image,
  });

  final ServiceItem? service;
  final String description;
  final Uint8List? image;

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  late ServiceItem _service = widget.service ?? serviceById('plumber');
  late final TextEditingController _desc =
      TextEditingController(text: widget.description);
  late final TextEditingController _loc =
      TextEditingController(text: kDefaultAddress);
  late Uint8List? _image = widget.image;
  Urgency _urgency = Urgency.urgent;
  late DateTime _when = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    _desc.dispose();
    _loc.dispose();
    super.dispose();
  }

  void _setUrgency(Urgency u) {
    final now = DateTime.now();
    setState(() {
      _urgency = u;
      _when = switch (u) {
        Urgency.urgent => now.add(const Duration(hours: 1)),
        Urgency.today => now.add(const Duration(hours: 4)),
        Urgency.scheduled => DateTime(now.year, now.month, now.day + 1, 10),
      };
    });
  }

  Future<void> _pickWhen() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _when.isBefore(now) ? now : _when,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    if (t == null) return;
    setState(() {
      _when = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      if (_urgency == Urgency.urgent) _urgency = Urgency.scheduled;
    });
  }

  Future<void> _addPhoto() async {
    final bytes = await pickPhoto(context, ImageSource.gallery);
    if (bytes != null && mounted) setState(() => _image = bytes);
  }

  void _submit() {
    if (_desc.text.trim().isEmpty) {
      showSnack(context,
          tr('من فضلك صف المشكلة أولاً', 'Please describe the problem first'));
      return;
    }
    if (_loc.text.trim().isEmpty) {
      showSnack(context, tr('من فضلك أدخل الموقع', 'Please enter the location'));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TechniciansScreen(
          draft: RequestDraft(
            service: _service,
            description: _desc.text.trim(),
            location: _loc.text.trim(),
            urgency: _urgency,
            when: _when,
            image: _image,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                children: [
                  ScreenHeader(
                    eyebrow: tr('المساعد · طلب صيانة جاهز للمراجعة',
                        'ASSISTANT · SERVICE REQUEST READY TO REVIEW'),
                    title: tr('بدأنا إعداد طلبك', "We've started your request"),
                    onBack: () => Navigator.pop(context),
                  ),
                  InfoBox(
                    icon: Icons.auto_awesome,
                    text: tr('أُعدّ من محادثتك. راجع كل التفاصيل قبل الإرسال.',
                        'Prepared from your chat. Review all the details before sending.'),
                  ),
                  const SizedBox(height: 16),
                  _label(tr('الخدمة والمشكلة', 'Service & issue')),
                  DropdownButtonFormField<String>(
                    value: _service.id,
                    isExpanded: true,
                    decoration: fieldDecoration(
                        prefix: Icon(_service.icon,
                            size: 18, color: AppColors.navy)),
                    items: [
                      for (final s in kServices)
                        DropdownMenuItem(value: s.id, child: Text(s.name)),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _service = serviceById(v));
                    },
                  ),
                  const SizedBox(height: 14),
                  _label(tr('وصف المشكلة', 'Problem description')),
                  TextField(
                    controller: _desc,
                    minLines: 3,
                    maxLines: 5,
                    decoration: fieldDecoration(
                      hint: tr('اكتب ما يحدث بالتفصيل…', 'Describe what is happening…'),
                      prefix: const Padding(
                        padding: EdgeInsets.only(bottom: 44),
                        child: Icon(Icons.edit_outlined,
                            size: 18, color: AppColors.navy),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (_image != null)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(_image!,
                                width: 34, height: 34, fit: BoxFit.cover),
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsetsDirectional.only(end: 8),
                          child: Icon(Icons.image_outlined,
                              size: 18, color: AppColors.muted),
                        ),
                      Expanded(
                        child: Text(
                          _image != null
                              ? tr('تم إرفاق صورة للمشكلة', 'A photo of the problem is attached')
                              : tr('لا توجد صور مرفقة', 'No photos attached'),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.muted),
                        ),
                      ),
                      TextButton(
                        onPressed: _addPhoto,
                        child: Text(
                          _image != null
                              ? tr('تغيير', 'Change')
                              : tr('إضافة صورة', 'Add photo'),
                          style: const TextStyle(
                              color: AppColors.terracotta,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _label(tr('الموقع', 'Location')),
                  TextField(
                    controller: _loc,
                    decoration: fieldDecoration(
                      prefix: const Icon(Icons.location_on_outlined,
                          size: 18, color: AppColors.navy),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _label(tr('درجة الاستعجال والموعد', 'Urgency & time')),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final u in Urgency.values)
                        ChoiceChip(
                          label: Text(urgencyLabel(u)),
                          selected: _urgency == u,
                          selectedColor: AppColors.peach,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: _urgency == u
                                ? AppColors.terracotta
                                : AppColors.navy,
                          ),
                          onSelected: (_) => _setUrgency(u),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _pickWhen,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 18, color: AppColors.navy),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${urgencyLabel(_urgency)} · ${fmtDate(_when)} · ${fmtTime(_when)}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          const Icon(Icons.edit_calendar_outlined,
                              size: 16, color: AppColors.muted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  InfoBox(
                    text: tr(
                        'سيتم إرسال طلبك إلى ما بين 1 إلى 5 من مقدمي الخدمة الأنسب لك.',
                        'Your request will be sent to 1 to 5 of the best-matched providers.'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: PrimaryButton(
                label: tr('مراجعة الطلب وإرساله', 'Review & send request'),
                onTap: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppText.label),
      );
}
