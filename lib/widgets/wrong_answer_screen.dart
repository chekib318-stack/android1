import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../theme/app_theme.dart';

/// تُعرض على كامل الشاشة عند إجابة خاطئة (فوق شريط التطبيق أيضًا)، لتثبيت
/// الإجابة الصحيحة في ذهن المتعلم قبل المتابعة للتمرين التالي.
class WrongAnswerScreen extends StatelessWidget {
  final Exercise exercise;

  const WrongAnswerScreen({super.key, required this.exercise});

  String? get _displayAnswer {
    if (exercise.type == ExerciseType.matchPairs) return null;
    if (exercise.correctAnswer.isNotEmpty) return exercise.correctAnswer;
    return exercise.targetWord;
  }

  @override
  Widget build(BuildContext context) {
    final answer = _displayAnswer;

    return Scaffold(
      backgroundColor: AppColors.harissa,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text('💡', textAlign: TextAlign.center, style: TextStyle(fontSize: 72)),
              const SizedBox(height: 20),
              const Text(
                'ليست إجابة صحيحة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 32),
              if (answer != null) ...[
                const Text(
                  'الإجابة الصحيحة هي',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 17),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    answer,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.harissa,
                    ),
                  ),
                ),
              ] else
                const Text(
                  'راجع العناصر الملوّنة وحاول مجددًا في المرة القادمة',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.harissa,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('متابعة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
