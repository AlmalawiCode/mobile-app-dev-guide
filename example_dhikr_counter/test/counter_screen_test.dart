import 'package:dhikr_counter/data/counter_store.dart';
import 'package:dhikr_counter/screens/counter_screen.dart';
import 'package:dhikr_counter/state/counter_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('النقر على الزر يزيد الرقم المعروض', (tester) async {
    final controller = CounterController(store: InMemoryCounterStore());
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(home: CounterScreen(controller: controller)),
    );

    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.text('سَبِّح'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });
}
