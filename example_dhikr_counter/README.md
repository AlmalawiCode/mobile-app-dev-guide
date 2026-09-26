# عدّاد الأذكار — المشروع النموذجي المرافق للدليل

هذا هو المشروع الذي يُبنى خطوة خطوة في الفصل التاسع من «من الفكرة إلى المتجر».
جُمِّع بـ Flutter 3.41 / Dart 3.11، واجتاز `flutter analyze` (بلا ملاحظات) و`flutter test` (7 اختبارات).

## التشغيل

المجلد يحتوي `lib/` و`test/` و`pubspec.yaml` فقط (بلا مجلدات المنصات لتصغير الحجم).
لتوليد مجلدات Android وiOS ثم التشغيل:

```bash
flutter create --project-name dhikr_counter --org sa.edu.kau.students --platforms android,ios .
flutter pub get
flutter analyze
flutter test
flutter run
```

## البنية

- `lib/models/dhikr.dart` — نموذج الذكر والقائمة الافتراضية.
- `lib/data/counter_store.dart` — عقد التخزين + تنفيذ shared_preferences + تنفيذ في الذاكرة للاختبار.
- `lib/state/counter_controller.dart` — نموذج العرض (ChangeNotifier).
- `lib/screens/` — شاشة العدّ وشاشة القائمة.
- `lib/stages/` — نسخ المرحلتين 3 و4 من الفصل التاسع (للمقارنة).
- `test/` — اختبارات الوحدة والـ widget والتخزين.

## قائمة «مؤجّل»

- إحصاءات (تحتاج حفظ تاريخ كل جلسة → ترحيل بيانات).
- تنبيهات محلية للصباح والمساء.
- العدّ بزر الصوت (platform channel).
- أذكار مخصصة، تصدير/استيراد.
