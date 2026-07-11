import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../theme/app_theme.dart';

/// تُعرض على كامل الشاشة عند إجابة خاطئة (فوق شريط التطبيق أيضًا)، لتثبيت
/// الإجابة الصحيحة في ذهن المتعلم قبل المتابعة للتمرين التالي. تظهر فيها
/// صورة "المدرس" غاضبا (assets/images/teacher_angry.png) بحركة اهتزاز
/// خفيفة تعبّر عن الاستياء اللطيف، بلا إحباط المتعلم الصغير.
class WrongAnswerScreen extends StatefulWidget {
  final Exercise exercise;

  const WrongAnswerScreen({super.key, required this.exercise});

  @override
  State<WrongAnswerScreen> createState() => _WrongAnswerScreenState();
}

class _WrongAnswerScreenState extends State<WrongAnswerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  String? get _displayAnswer {
    final exercise = widget.exercise;
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
              Center(child: _animatedTeacher()),
              const SizedBox(height: 10),
              const Text(
                'المدرس',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
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

  Widget _animatedTeacher() {
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        // اهتزاز جانبي جيبي يتلاشى تدريجيا (إحساس استياء لطيف بلا إخافة)
        final t = _shake.value;
        final decay = 1 - t;
        final dx = 8 * decay * math.sin(t * 6 * math.pi);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          'assets/images/teacher_angry.png',
          width: 140,
          height: 168,
          fit: BoxFit.cover,
          alignment: const Alignment(0.0, -0.5),
        ),
      ),
    );
  }
}
