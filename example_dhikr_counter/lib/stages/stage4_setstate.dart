import 'package:flutter/material.dart';

/// المرحلة 4: أول "حالة" حقيقية. StatefulWidget + setState.
class SimpleCounterScreen extends StatefulWidget {
  const SimpleCounterScreen({super.key});

  @override
  State<SimpleCounterScreen> createState() => _SimpleCounterScreenState();
}

class _SimpleCounterScreenState extends State<SimpleCounterScreen> {
  int _count = 0; // الحالة: قيمة تتغير مع الزمن وتؤثر في ما يُعرض

  void _increment() {
    // setState تخبر Flutter: "الحالة تغيّرت، أعد بناء هذه الشاشة".
    setState(() => _count++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عدّاد الأذكار')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$_count', style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 32),
          FilledButton(onPressed: _increment, child: const Text('سَبِّح')),
        ],
      ),
    );
  }
}
