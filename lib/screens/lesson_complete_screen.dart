import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LessonCompleteScreen extends StatelessWidget {
  final Lesson lesson;
  final int correctCount;

  const LessonCompleteScreen({
    super.key,
    required this.lesson,
    required this.correctCount,
  });

  @override
  Widget build(BuildContext context) {
    final total = lesson.exercises.length;
    final accuracy = total == 0 ? 0 : ((correctCount / total) * 100).round();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text(
                'أحسنت!',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.sidiBlue,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'أنهيت درس «${lesson.title}»',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _resultCard('⭐', '${lesson.xpReward}', 'نقطة خبرة', AppColors.zellige),
                  const SizedBox(width: 16),
                  _resultCard('🎯', '$accuracy%', 'نسبة الإتقان', AppColors.ochre),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                ),
                child: const Text('متابعة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultCard(String icon, String value, String label, Color color) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 13, color: color)),
        ],
      ),
    );
  }
}
