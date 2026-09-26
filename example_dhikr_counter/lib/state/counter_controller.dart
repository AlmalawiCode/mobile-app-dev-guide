import 'package:flutter/foundation.dart';

import '../data/counter_store.dart';
import '../models/dhikr.dart';

/// "عقل" الشاشة: يحمل الحالة (الذكر الحالي وعدّه) ويبلّغ الواجهة عند تغيّرها.
/// لا يعرف شيئًا عن الـ Widgets، لذا يمكن اختباره دون تشغيل واجهة.
class CounterController extends ChangeNotifier {
  CounterController({required CounterStore store, List<Dhikr>? adhkar})
      : _store = store,
        adhkar = adhkar ?? defaultAdhkar;

  final CounterStore _store;
  final List<Dhikr> adhkar;

  Map<String, int> _counts = {};
  Dhikr? _current;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  Dhikr get current => _current ?? adhkar.first;
  int get count => _counts[current.id] ?? 0;
  bool get reachedTarget => count >= current.target;

  /// يُستدعى مرة واحدة عند فتح التطبيق لاستعادة ما حُفظ سابقًا.
  Future<void> load() async {
    _counts = await _store.loadCounts();
    _loaded = true;
    notifyListeners();
  }

  void selectDhikr(Dhikr dhikr) {
    _current = dhikr;
    notifyListeners();
  }

  /// يزيد العدّاد ويحفظ. نحفظ بعد كل نقرة لأن الكتابة صغيرة ورخيصة،
  /// ولأن المستخدم قد يغلق التطبيق في أي لحظة.
  Future<void> increment() async {
    _counts[current.id] = count + 1;
    notifyListeners();
    await _store.saveCounts(_counts);
  }

  Future<void> reset() async {
    _counts.remove(current.id);
    notifyListeners();
    await _store.saveCounts(_counts);
  }
}
