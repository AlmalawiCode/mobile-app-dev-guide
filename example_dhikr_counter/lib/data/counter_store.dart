import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// عقد (واجهة مجرّدة) يصف ما نحتاجه من "مخزن العدّادات" دون تحديد كيفية التخزين.
/// فائدة العقد: يمكن استبدال التخزين الحقيقي بنسخة في الذاكرة أثناء الاختبار.
abstract class CounterStore {
  /// يُرجع خريطة: معرّف الذكر -> العدد المحفوظ.
  Future<Map<String, int>> loadCounts();

  /// يحفظ الخريطة كاملة. الحجم صغير جدًا فلا حاجة لقاعدة بيانات هنا.
  Future<void> saveCounts(Map<String, int> counts);
}

/// تنفيذ حقيقي يعتمد على حزمة shared_preferences.
/// نخزّن الخريطة كنص JSON واحد تحت مفتاح واحد.
class SharedPrefsCounterStore implements CounterStore {
  SharedPrefsCounterStore([SharedPreferencesAsync? prefs])
      : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;
  static const _key = 'dhikr_counts_v1';

  @override
  Future<Map<String, int>> loadCounts() async {
    final raw = await _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      // نتحقق من نوع كل قيمة: أي قيمة تالفة تُهمل بدل أن تُسقط التطبيق.
      return {
        for (final entry in decoded.entries)
          if (entry.value is int && (entry.value as int) >= 0)
            entry.key.toString(): entry.value as int,
      };
    } on FormatException {
      // بيانات تالفة (مثلًا من إصدار قديم): نبدأ من الصفر بدل الانهيار.
      return {};
    }
  }

  @override
  Future<void> saveCounts(Map<String, int> counts) {
    return _prefs.setString(_key, jsonEncode(counts));
  }
}

/// تنفيذ في الذاكرة فقط، للاختبارات وللتجربة السريعة.
class InMemoryCounterStore implements CounterStore {
  final Map<String, int> _data = {};

  @override
  Future<Map<String, int>> loadCounts() async => Map.of(_data);

  @override
  Future<void> saveCounts(Map<String, int> counts) async {
    _data
      ..clear()
      ..addAll(counts);
  }
}
