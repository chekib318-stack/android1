import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/exercise_view.dart';
import 'lesson_complete_screen.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _index = 0;
  int _correctCount = 0;

  void _onExerciseComplete(bool correct) {
    if (correct) _correctCount++;
    final isLast = _index == widget.lesson.exercises.length - 1;
    if (isLast) {
      context
          .read<ProgressProvider>()
          .completeLesson(widget.lesson.id, widget.lesson.xpReward);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LessonCompleteScreen(
            lesson: widget.lesson,
            correctCount: _correctCount,
          ),
        ),
      );
    } else {
      setState(() => _index++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.lesson.exercises.length;
    final progress = (_index) / total;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.lesson.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: AppColors.jasmineDim,
                  valueColor: const AlwaysStoppedAnimation(AppColors.zellige),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                // مفتاح فريد لكل تمرين لضمان إعادة بناء الحالة الداخلية عند الانتقال
                child: ExerciseView(
                  key: ValueKey(widget.lesson.exercises[_index].id),
                  exercise: widget.lesson.exercises[_index],
                  onComplete: _onExerciseComplete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
