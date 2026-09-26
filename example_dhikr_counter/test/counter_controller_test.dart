import 'package:dhikr_counter/data/counter_store.dart';
import 'package:dhikr_counter/models/dhikr.dart';
import 'package:dhikr_counter/state/counter_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testAdhkar = [Dhikr(id: 'a', text: 'ذكر أ', target: 3)];

  group('CounterController', () {
    test('يبدأ من الصفر ويزيد بمقدار واحد', () async {
      final controller =
          CounterController(store: InMemoryCounterStore(), adhkar: testAdhkar);
      await controller.load();

      expect(controller.count, 0);
      await controller.increment();
      await controller.increment();
      expect(controller.count, 2);
      expect(controller.reachedTarget, isFalse);
    });

    test('يبلغ الهدف عند العدد المستهدف', () async {
      final controller =
          CounterController(store: InMemoryCounterStore(), adhkar: testAdhkar);
      await controller.load();
      for (var i = 0; i < 3; i++) {
        await controller.increment();
      }
      expect(controller.reachedTarget, isTrue);
    });

    test('يستعيد العدد المحفوظ عند إعادة الفتح', () async {
      final store = InMemoryCounterStore();
      final first = CounterController(store: store, adhkar: testAdhkar);
      await first.load();
      await first.increment();

      // "إعادة فتح التطبيق": متحكم جديد بنفس المخزن.
      final second = CounterController(store: store, adhkar: testAdhkar);
      await second.load();
      expect(second.count, 1);
    });

    test('التصفير يعيد العدد إلى الصفر ويحفظ', () async {
      final store = InMemoryCounterStore();
      final controller = CounterController(store: store, adhkar: testAdhkar);
      await controller.load();
      await controller.increment();
      await controller.reset();
      expect(controller.count, 0);
      expect(await store.loadCounts(), isEmpty);
    });
  });
}
