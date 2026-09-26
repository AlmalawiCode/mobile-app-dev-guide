import 'package:flutter/material.dart';

import '../state/counter_controller.dart';

class DhikrListScreen extends StatelessWidget {
  const DhikrListScreen({super.key, required this.controller});

  final CounterController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختر ذكرًا')),
      body: ListView.separated(
        itemCount: controller.adhkar.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final dhikr = controller.adhkar[index];
          final selected = dhikr.id == controller.current.id;
          return ListTile(
            title: Text(dhikr.text),
            subtitle: Text('الهدف: ${dhikr.target}'),
            trailing: selected ? const Icon(Icons.check) : null,
            selected: selected,
            onTap: () {
              controller.selectDhikr(dhikr);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
