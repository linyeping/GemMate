import 'package:shared_preferences/shared_preferences.dart';

/// Tracks the user's daily study streak and total study days.
/// Call [recordStudy] once per study session to keep it up-to-date.
class StreakService {
  static final StreakService _instance = StreakService._();
  factory StreakService() => _instance;
  StreakService._();

  static const _streakKey = 'study_streak';
  static const _lastStudyKey = 'last_study_date';
  static const _totalDaysKey = 'total_study_days';
  static const _pomodorosKey = 'pomodoros_today';
  static const _pomodoroDateKey = 'pomodoro_date';

  // ── streak ───────────────────────────────────────────────────────────────

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await _decayIfNeeded(prefs);
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<int> getTotalDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalDaysKey) ?? 0;
  }

  /// Call this when the user sends a message or completes a pomodoro.
  /// Safe to call multiple times per day — only counts once.
  Future<void> recordStudy() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final last = prefs.getString(_lastStudyKey);

    if (last == today) return; // already counted today

    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    final current = prefs.getInt(_streakKey) ?? 0;
    final newStreak = (last == yesterday) ? current + 1 : 1;
    final total = (prefs.getInt(_totalDaysKey) ?? 0) + 1;

    await prefs.setString(_lastStudyKey, today);
    await prefs.setInt(_streakKey, newStreak);
    await prefs.setInt(_totalDaysKey, total);
  }

  /// If the user hasn't studied since before yesterday, reset streak to 0.
  Future<void> _decayIfNeeded(SharedPreferences prefs) async {
    final last = prefs.getString(_lastStudyKey);
    if (last == null) return;
    final today = _dateKey(DateTime.now());
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    if (last != today && last != yesterday) {
      await prefs.setInt(_streakKey, 0);
    }
  }

  // ── pomodoro session counter ─────────────────────────────────────────────

  Future<int> getPomodorosToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final recorded = prefs.getString(_pomodoroDateKey);
    if (recorded != today) {
      await prefs.setInt(_pomodorosKey, 0);
      await prefs.setString(_pomodoroDateKey, today);
      return 0;
    }
    return prefs.getInt(_pomodorosKey) ?? 0;
  }

  Future<int> recordPomodoro() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final recorded = prefs.getString(_pomodoroDateKey);
    int count = (recorded == today) ? (prefs.getInt(_pomodorosKey) ?? 0) : 0;
    count++;
    await prefs.setInt(_pomodorosKey, count);
    await prefs.setString(_pomodoroDateKey, today);
    await recordStudy(); // a completed pomodoro counts as studying
    return count;
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
