import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// يدير تقدم المتعلم محليًا (XP، الشارات، السلسلة اليومية، الدروس المكتملة).
/// هذا تخزين محلي مؤقت لنسخة البداية؛ في مرحلة لاحقة تتم مزامنته
/// مع الخادم (PHP/MySQL) عبر REST API حين تتوفر بنية تحتية للحساب المركزي.
class ProgressProvider extends ChangeNotifier {
  int xp = 0;
  int streakDays = 0;
  DateTime? lastActivityDate;
  final Set<String> completedLessonIds = {};
  String studentName = '';
  int totalCorrect = 0; // مجموع الإجابات الصحيحة عبر كل الدروس المكتملة
  int totalPossible = 0; // مجموع كل الأسئلة عبر كل الدروس المكتملة

  static const _keyXp = 'xp';
  static const _keyStreak = 'streak';
  static const _keyLastActivity = 'last_activity';
  static const _keyCompleted = 'completed_lessons';
  static const _keyStudentName = 'student_name';
  static const _keyTotalCorrect = 'total_correct';
  static const _keyTotalPossible = 'total_possible';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    xp = prefs.getInt(_keyXp) ?? 0;
    streakDays = prefs.getInt(_keyStreak) ?? 0;
    studentName = prefs.getString(_keyStudentName) ?? '';
    totalCorrect = prefs.getInt(_keyTotalCorrect) ?? 0;
    totalPossible = prefs.getInt(_keyTotalPossible) ?? 0;
    final lastActivityStr = prefs.getString(_keyLastActivity);
    lastActivityDate =
        lastActivityStr != null ? DateTime.tryParse(lastActivityStr) : null;
    completedLessonIds
      ..clear()
      ..addAll(prefs.getStringList(_keyCompleted) ?? []);
    notifyListeners();
  }

  Future<void> setStudentName(String name) async {
    studentName = name.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStudentName, studentName);
    notifyListeners();
  }

  Future<void> completeLesson(
    String lessonId,
    int xpReward, {
    int correctCount = 0,
    int totalExercises = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastActivityDate != null) {
      final lastDay = DateTime(
        lastActivityDate!.year,
        lastActivityDate!.month,
        lastActivityDate!.day,
      );
      final diff = today.difference(lastDay).inDays;
      if (diff == 1) {
        streakDays += 1; // يوم متتالٍ جديد
      } else if (diff > 1) {
        streakDays = 1; // انقطعت السلسلة، تبدأ من جديد
      }
      // diff == 0: نفس اليوم، لا تغيير على السلسلة
    } else {
      streakDays = 1; // أول نشاط على الإطلاق
    }

    lastActivityDate = today;
    xp += xpReward;
    completedLessonIds.add(lessonId);
    totalCorrect += correctCount;
    totalPossible += totalExercises;

    await prefs.setInt(_keyXp, xp);
    await prefs.setInt(_keyStreak, streakDays);
    await prefs.setString(_keyLastActivity, today.toIso8601String());
    await prefs.setStringList(_keyCompleted, completedLessonIds.toList());
    await prefs.setInt(_keyTotalCorrect, totalCorrect);
    await prefs.setInt(_keyTotalPossible, totalPossible);

    notifyListeners();
  }

  bool isCompleted(String lessonId) => completedLessonIds.contains(lessonId);

  /// يصفّر كل تقدم الدروس (كأن التلميذ لم يقم بأي درس بعد): النقاط،
  /// الدروس المكتملة، ومجموع الإجابات. لا يمس اسم التلميذ ولا السلسلة
  /// اليومية (سجل النشاط العام يبقى كما هو).
  Future<void> resetLessonsProgress() async {
    xp = 0;
    completedLessonIds.clear();
    totalCorrect = 0;
    totalPossible = 0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyXp, xp);
    await prefs.setStringList(_keyCompleted, []);
    await prefs.setInt(_keyTotalCorrect, totalCorrect);
    await prefs.setInt(_keyTotalPossible, totalPossible);

    notifyListeners();
  }
}
