/// نموذج (Model) يمثّل ذِكرًا واحدًا في القائمة.
/// النموذج "غبي" عمدًا: يحمل البيانات فقط ولا يعرف شيئًا عن الشاشات أو التخزين.
class Dhikr {
  const Dhikr({required this.id, required this.text, required this.target});

  /// معرّف ثابت لا يتغير حتى لو عدّلنا النص لاحقًا.
  final String id;

  /// نص الذكر كما يظهر للمستخدم.
  final String text;

  /// العدد المستهدف (مثل 33 أو 100).
  final int target;
}

/// قائمة مبدئية مضمّنة في التطبيق. في مرحلة لاحقة يمكن نقلها إلى ملف JSON
/// أو السماح للمستخدم بإضافة أذكاره الخاصة.
const List<Dhikr> defaultAdhkar = [
  Dhikr(id: 'subhanallah', text: 'سُبْحَانَ الله', target: 33),
  Dhikr(id: 'alhamdulillah', text: 'الْحَمْدُ لله', target: 33),
  Dhikr(id: 'allahuakbar', text: 'اللهُ أَكْبَر', target: 34),
  Dhikr(id: 'istighfar', text: 'أَسْتَغْفِرُ الله', target: 100),
  Dhikr(id: 'hawqala', text: 'لا حَوْلَ وَلا قُوَّةَ إِلَّا بِالله', target: 100),
];
