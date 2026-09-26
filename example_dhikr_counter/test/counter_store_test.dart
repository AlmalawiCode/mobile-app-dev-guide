import 'package:dhikr_counter/data/counter_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    // نستبدل التخزين الحقيقي بنسخة في الذاكرة داخل الاختبار.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('يحفظ ويسترجع الأعداد', () async {
    final store = SharedPrefsCounterStore(SharedPreferencesAsync());
    await store.saveCounts({'a': 5, 'b': 0});
    expect(await store.loadCounts(), {'a': 5, 'b': 0});
  });

  test('يتجاهل البيانات التالفة بدل الانهيار', () async {
    final prefs = SharedPreferencesAsync();
    await prefs.setString('dhikr_counts_v1', '{ليس json');
    final store = SharedPrefsCounterStore(prefs);
    expect(await store.loadCounts(), isEmpty);
  });
}
