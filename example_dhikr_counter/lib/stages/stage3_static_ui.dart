import 'package:flutter/material.dart';

/// المرحلة 3: واجهة ثابتة بلا أي منطق. الهدف: رؤية الشكل على الشاشة أولًا.
class StaticCounterScreen extends StatelessWidget {
  const StaticCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عدّاد الأذكار')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('سُبْحَانَ الله', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 16),
          const Text('0', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {}, // لا يفعل شيئًا بعد
            child: const Text('سَبِّح'),
          ),
        ],
      ),
    );
  }
}
