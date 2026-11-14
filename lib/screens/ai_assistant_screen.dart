import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'ai_result_screen.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _ctrl = TextEditingController();
  Uint8List? _image;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final bytes = await pickPhoto(context, source);
    if (bytes != null && mounted) setState(() => _image = bytes);
  }

  void _send([String? preset]) {
    final text = (preset ?? _ctrl.text).trim();
    final img = _image;
    if (text.isEmpty && img == null) {
      showSnack(context,
          tr('اكتب وصف المشكلة أو أرفق صورة', 'Describe the problem or attach a photo'));
      return;
    }
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiResultScreen(
          userText: text.isEmpty
              ? tr('صورة للمشكلة', 'Photo of the problem')
              : text,
          image: img,
        ),
      ),
    );
    _ctrl.clear();
    setState(() => _image = null);
  }

  @override
  Widget build(BuildContext context) {
    final chip1 = tr('تسريب مياه أسفل الحوض', 'Water leak under sink');
    final chip2 = tr('التكييف لا يبرّد', 'AC not cooling');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          children: [
            ScreenHeader(
              eyebrow: tr('خطوة أولى أكثر أماناً', 'A SAFER FIRST STEP'),
              title: 'HomeEase AI',
            ),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('HomeEase AI',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.navy)),
                      Text(
                        tr('نظرة أولية مفيدة، وليست تشخيصاً نهائياً',
                            'A helpful first look, not a final diagnosis'),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('ماذا يحدث في منزلك؟', "What's happening at home?"),
                      style: AppText.h1.copyWith(fontSize: 22)),
                  const SizedBox(height: 8),
                  Text(
                    tr('صف المشكلة أو أرسل صورة. يمكنني اقتراح خطوة آمنة ومساعدتك في العثور على مختص.',
                        'Describe the problem or send a photo. I can suggest a safe step and help you find a specialist.'),
                    style: const TextStyle(
                        fontSize: 12, height: 1.6, color: AppColors.textDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PhotoBox(bytes: _image, height: 190),
            const SizedBox(height: 16),
            Text(tr('ابدأ بمشكلة شائعة', 'Start with a common problem'),
                style: AppText.h2.copyWith(fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(chip1, dark: true),
                _chip(chip2),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _photoButton(
                      Icons.photo_camera_outlined,
                      tr('التقط صورة', 'Take photo'),
                      () => _pick(ImageSource.camera)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _photoButton(
                      Icons.add_photo_alternate_outlined,
                      tr('إرفاق صورة', 'Attach photo'),
                      () => _pick(ImageSource.gallery)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(tr('رسالتك', 'Your message'), style: AppText.label),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: fieldDecoration(
                hint: tr('كيف أساعدك؟', 'How can I help?'),
                suffix: IconButton(
                  icon: const Icon(Icons.send, color: AppColors.terracotta),
                  onPressed: _send,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, {bool dark = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _send(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: dark ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dark ? AppColors.navy : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: dark ? Colors.white : AppColors.navy)),
      ),
    );
  }

  Widget _photoButton(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: AppColors.beige,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 84,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.navy),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy)),
            ],
          ),
        ),
      ),
    );
  }
}
