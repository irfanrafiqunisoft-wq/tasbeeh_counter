import 'dart:convert';

/// Single Tasbeeh (Zikr) item — har custom tasbeeh ka data structure.
///
/// dailyHistory: date string ("yyyy-MM-dd") -> us din ka completed count.
/// Isse history page aur "today's count" dono nikal sakte hain.
class Tasbeeh {
  String id;
  String name; // e.g. "SubhanAllah", "Durood", "Astaghfirullah"
  int totalTarget; // e.g. 1000
  int totalDays; // e.g. 7 (1 din ho to 1)
  DateTime startDate;
  Map<String, int> dailyHistory; // "yyyy-MM-dd" -> count
  bool reminderEnabled;
  int reminderHour; // 24-hour format
  int reminderMinute;

  Tasbeeh({
    required this.id,
    required this.name,
    required this.totalTarget,
    required this.totalDays,
    required this.startDate,
    Map<String, int>? dailyHistory,
    this.reminderEnabled = false,
    this.reminderHour = 8,
    this.reminderMinute = 0,
  }) : dailyHistory = dailyHistory ?? {};

  /// Daily target automatically calculate hota hai total/days se.
  /// Kam az kam 1 hota hai taake divide-by-zero issues na ho.
  int get dailyTarget {
    if (totalDays <= 0) return totalTarget;
    final result = (totalTarget / totalDays).ceil();
    return result < 1 ? 1 : result;
  }

  static String dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  int countForDate(DateTime date) {
    return dailyHistory[dateKey(date)] ?? 0;
  }

  int get todayCount => countForDate(DateTime.now());

  /// Sare dailyHistory entries ka sum — total kitna ho chuka hai ab tak.
  int get totalCompleted {
    return dailyHistory.values.fold(0, (sum, val) => sum + val);
  }

  int get remainingTotal {
    final r = totalTarget - totalCompleted;
    return r < 0 ? 0 : r;
  }

  int get remainingToday {
    final r = dailyTarget - todayCount;
    return r < 0 ? 0 : r;
  }

  double get overallPercentage {
    if (totalTarget <= 0) return 0;
    final pct = (totalCompleted / totalTarget) * 100;
    return pct > 100 ? 100 : pct;
  }

  double get todayPercentage {
    if (dailyTarget <= 0) return 0;
    final pct = (todayCount / dailyTarget) * 100;
    return pct > 100 ? 100 : pct;
  }

  bool get isCompletedOverall => totalCompleted >= totalTarget;
  bool get isTodayTargetMet => todayCount >= dailyTarget;

  void addCount(int amount, {DateTime? date}) {
    final key = dateKey(date ?? DateTime.now());
    dailyHistory[key] = (dailyHistory[key] ?? 0) + amount;
  }

  void resetToday({DateTime? date}) {
    final key = dateKey(date ?? DateTime.now());
    dailyHistory[key] = 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'totalTarget': totalTarget,
        'totalDays': totalDays,
        'startDate': startDate.toIso8601String(),
        'dailyHistory': dailyHistory,
        'reminderEnabled': reminderEnabled,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
      };

  factory Tasbeeh.fromJson(Map<String, dynamic> json) {
    return Tasbeeh(
      id: json['id'] as String,
      name: json['name'] as String,
      totalTarget: json['totalTarget'] as int,
      totalDays: json['totalDays'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      dailyHistory: Map<String, int>.from(json['dailyHistory'] ?? {}),
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderHour: json['reminderHour'] as int? ?? 8,
      reminderMinute: json['reminderMinute'] as int? ?? 0,
    );
  }

  static String encodeList(List<Tasbeeh> list) {
    return jsonEncode(list.map((t) => t.toJson()).toList());
  }

  static List<Tasbeeh> decodeList(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(jsonStr);
    return decoded.map((item) => Tasbeeh.fromJson(item)).toList();
  }
}
