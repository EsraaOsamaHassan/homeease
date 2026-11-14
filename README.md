# HomeEase – تطبيق خدمات منزلية (Flutter)

تطبيق بنفس تصميم الشاشات (عربي RTL + إنجليزي) مع مساعد ذكي وفنيين مقترحين (بيانات وهمية).

## التشغيل

```bash
cd homeease
flutter create .          # يولّد مجلدات android/ios/web (لن يمس lib/ ولا pubspec.yaml)
flutter pub get
flutter run
```

## صلاحيات لازمة بعد `flutter create`

**Android** – في `android/app/src/main/AndroidManifest.xml` أضف داخل `<manifest>` (قبل `<application>`):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

**iOS** – في `ios/Runner/Info.plist` أضف:

```xml
<key>NSCameraUsageDescription</key>
<string>Take a photo of the problem</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Attach a photo of the problem</string>
```

## هيكل المشروع

| الملف | الوظيفة |
|---|---|
| `lib/config.dart` | مفتاح ورابط وموديل OpenRouter |
| `lib/services/ai_service.dart` | دالة `generateTextWithDots` + تحليل رد المساعد + رد احتياطي |
| `lib/data.dart` | الخدمات، حالات الطوارئ، **الفنيين الوهميين** |
| `lib/screens/home_screen.dart` | الرئيسية (Hi, Habiba) |
| `lib/screens/emergency_screen.dart` | مساعدة عاجلة بهدوء |
| `lib/screens/emergency_received_screen.dart` | تم استلام طلبك العاجل |
| `lib/screens/ai_assistant_screen.dart` | HomeEase AI |
| `lib/screens/ai_result_screen.dart` | خطوة آمنة / لنستعن بمختص |
| `lib/screens/request_screen.dart` | بدأنا إعداد طلبك |
| `lib/screens/technicians_screen.dart` | **الفنيون المقترحون للمهمة** |
| `lib/screens/request_confirmation_screen.dart` | تأكيد الإرسال وردود الفنيين (محاكاة) |
| `lib/screens/other_tabs.dart` | طلباتي / منزلي / حسابي |

## ملاحظات

- تبديل اللغة من زر الترجمة في الرئيسية أو من تاب "حسابي".
- لو الـ API فشل (مفتاح/موديل/إنترنت) المساعد يرجع لنصائح جاهزة بدل ما يتعطل.
- اتصال الدعم مجرد رسالة تجريبية (مفيش `url_launcher`).
- المفتاح داخل الكود للتجربة فقط — غيّره/اسحبه من سيرفر قبل أي نشر.
