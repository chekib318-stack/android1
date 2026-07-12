import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'lesson_screen.dart';

/// شاشة انتقالية رسمية تُعرض تلقائيا بعد الدرس التمهيدي وقبل بداية
/// التمارين: شعار وزارة التربية والعلم بحجم كبير، مع عبارة "التمارين
/// الخاصة بدرس ..." تُقرأ صوتيا تلقائيا. الانتقال الفعلي للتمارين يدوي
/// فقط عبر زر "متابعة" (بلا انتقال تلقائي بعد النطق).
class ExercisesTransitionScreen extends StatefulWidget {
  final Lesson lesson;
  final String? ordinal;

  const ExercisesTransitionScreen({super.key, required this.lesson, this.ordinal});

  @override
  State<ExercisesTransitionScreen> createState() => _ExercisesTransitionScreenState();
}

class _ExercisesTransitionScreenState extends State<ExercisesTransitionScreen> {
  @override
  void initState() {
    super.initState();
    _announce();
  }

  Future<void> _announce() async {
    await AudioService.instance.speak('التمارين الخاصة بدرس ${widget.lesson.title}');
  }

  void _skip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LessonScreen(lesson: widget.lesson, ordinal: widget.ordinal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jasmine,
      body: SafeArea(
        child: GestureDetector(
          onTap: _skip,
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo_ministere.png', height: 130),
                const SizedBox(height: 14),
                Image.asset('assets/images/prepedu_logo.png', height: 56),
                const SizedBox(height: 36),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.zellige.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.zellige.withOpacity(0.3)),
                  ),
                  child: Text(
                    'التمارين الخاصة بدرس ${widget.lesson.title}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 24,
                          color: AppColors.zellige,
                        ),
                  ),
                ),
                const SizedBox(height: 36),
                Image.asset('assets/images/flag_tunisia.png', height: 80),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _skip,
                    child: const Text('متابعة'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
