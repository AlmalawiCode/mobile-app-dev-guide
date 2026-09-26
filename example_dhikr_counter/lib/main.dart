import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/counter_store.dart';
import 'screens/counter_screen.dart';
import 'state/counter_controller.dart';

void main() {
  // نُنشئ التبعيات في مكان واحد (نقطة الدخول) ونمرّرها للأسفل.
  final controller = CounterController(store: SharedPrefsCounterStore());
  controller.load();
  runApp(DhikrApp(controller: controller));
}

class DhikrApp extends StatelessWidget {
  const DhikrApp({super.key, required this.controller});

  final CounterController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'عدّاد الأذكار',
      debugShowCheckedModeBanner: false,
      // اللغة العربية افتراضيًا: يضبط اتجاه العرض RTL ونصوص عناصر Material الجاهزة.
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF315B45),
        useMaterial3: true,
      ),
      home: CounterScreen(controller: controller),
    );
  }
}
