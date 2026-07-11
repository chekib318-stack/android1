import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/sample_content.dart';
import '../models/lesson.dart';
import '../providers/progress_provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/official_badge.dart';
import 'final_report_screen.dart';
import 'home_screen.dart';

class LessonCompleteScreen extends StatefulWidget {
  final Lesson lesson;
  final int correctCount;

  const LessonCompleteScreen({
    super.key,
    required this.lesson,
    required this.correctCount,
  });

  @override
  State<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen> {
  late final int _total = widget.lesson.exercises.length;
  // إن كانت النتيجة 5 من 7 فما فوق: صورة ضاحكة، وإلا صورة حزينة (بما فيها 4 وأقل)
  late final bool _isHappy = widget.correctCount >= 5;

  @override
  void initState() {
    super.initState();
    final message = _isHappy
        ? 'ممتاز! حصلت على ${widget.correctCount} من $_total'
        : 'حاول مرة أخرى، حصلت على ${widget.correctCount} من $_total';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.instance.speak(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = _total == 0 ? 0 : ((widget.correctCount / _total) * 100).round();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const OfficialBadge(compact: true),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  _isHappy
                      ? 'assets/images/teacher_happy.png'
                      : 'assets/images/teacher_angry.png',
                  width: 150,
                  height: 180,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.0, -0.5),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isHappy ? 'ممتاز!' : 'حاول مرة أخرى',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: _isHappy ? AppColors.sidiBlue : AppColors.harissa,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'أنهيت درس «${widget.lesson.title}»',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _resultCard(
                    '✅',
                    '${widget.correctCount} / $_total',
                    'الإجابات الصحيحة',
                    _isHappy ? AppColors.zellige : AppColors.harissa,
                  ),
                  const SizedBox(width: 16),
                  _resultCard('🎯', '$accuracy%', 'نسبة الإتقان', AppColors.ochre),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  final progress = context.read<ProgressProvider>();
                  final allLessonsCount =
                      kindergartenUnits.expand((u) => u.lessons).length;
                  final allDone = progress.completedLessonIds.length >= allLessonsCount;
                  if (allDone) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => FinalReportScreen(progress: progress),
                      ),
                      (route) => false,
                    );
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  }
                },
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
