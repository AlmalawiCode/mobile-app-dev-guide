import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/counter_controller.dart';
import 'dhikr_list_screen.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key, required this.controller});

  final CounterController controller;

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفير العدّاد؟'),
        content: const Text('سيبدأ العدّ من الصفر لهذا الذكر.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تصفير'),
          ),
        ],
      ),
    );
    if (ok == true) await controller.reset();
  }

  Future<void> _onTap() async {
    final wasBelowTarget = !controller.reachedTarget;
    await controller.increment();
    // اهتزاز خفيف عند بلوغ الهدف (يعمل على الجهاز الحقيقي، لا على المحاكي غالبًا).
    if (wasBelowTarget && controller.reachedTarget) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.isLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final dhikr = controller.current;
        return Scaffold(
          appBar: AppBar(
            title: const Text('عدّاد الأذكار'),
            actions: [
              IconButton(
                tooltip: 'اختيار ذكر',
                icon: const Icon(Icons.list_alt),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => DhikrListScreen(controller: controller),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'تصفير',
                icon: const Icon(Icons.refresh),
                onPressed: () => _confirmReset(context),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    dhikr.text,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 24),
                Semantics(
                  // نص يقرؤه قارئ الشاشة (TalkBack / VoiceOver).
                  label: 'العدد الحالي ${controller.count} من ${dhikr.target}',
                  child: Text(
                    '${controller.count}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: controller.reachedTarget
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                ),
                Text('الهدف: ${dhikr.target}',
                    style: theme.textTheme.bodyLarge),
                const Spacer(),
                // زر كبير يملأ عرض الشاشة تقريبًا: هدف اللمس سهل حتى دون النظر.
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 160,
                    child: FilledButton(
                      onPressed: _onTap,
                      child: const Text('سَبِّح', style: TextStyle(fontSize: 32)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
