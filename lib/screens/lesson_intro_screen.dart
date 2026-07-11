import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/official_badge.dart';
import 'lesson_screen.dart';

/// شاشة تمهيدية تُعرض قبل أسئلة كل درس: تقدّم مفردات الدرس واحدة تلو
/// الأخرى بالصوت والصورة (رمز تعبيري كبير)، بطريقة تفاعلية مبسطة مناسبة
/// للأطفال الصغار، قبل الانتقال للتمارين الفعلية.
class LessonIntroScreen extends StatefulWidget {
  final Lesson lesson;
  final String? ordinal;

  const LessonIntroScreen({super.key, required this.lesson, this.ordinal});

  @override
  State<LessonIntroScreen> createState() => _LessonIntroScreenState();
}

class _LessonIntroScreenState extends State<LessonIntroScreen>
    with SingleTickerProviderStateMixin {
  int _index = -1; // -1 = مرحلة إعلان اسم الدرس، قبل أول كلمة
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _announceLessonThenStart();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _announceLessonThenStart() async {
    final title = widget.lesson.title;
    final announcement =
        widget.ordinal != null ? 'الدرس ${widget.ordinal}: $title' : title;
    await AudioService.instance.speak(announcement);
    if (!mounted) return;
    _goToIndex(0);
  }

  Future<void> _goToIndex(int newIndex) async {
    setState(() => _index = newIndex);
    _entrance.forward(from: 0);
    if (newIndex >= 0 && newIndex < widget.lesson.introItems.length) {
      final item = widget.lesson.introItems[newIndex];
      await AudioService.instance.speak(item.word);
      await AudioService.instance.playSoundEffect(item.soundEffect);
    }
  }

  void _next() {
    final items = widget.lesson.introItems;
    if (_index + 1 < items.length) {
      _goToIndex(_index + 1);
    } else {
      _goToExercises();
    }
  }

  Future<void> _goToExercises() async {
    // انتهت كل المفردات التمهيدية → إعلان صوتي ثم الانتقال لتمارين الدرس
    await AudioService.instance.speak('سنمر الآن إلى التمارين');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LessonScreen(lesson: widget.lesson, ordinal: widget.ordinal),
      ),
    );
  }

  void _replay() {
    final items = widget.lesson.introItems;
    if (_index >= 0 && _index < items.length) {
      final item = items[_index];
      AudioService.instance.speak(item.word);
      AudioService.instance.playSoundEffect(item.soundEffect);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.lesson.introItems;
    final loading = _index < 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('تعرّف على: ${widget.lesson.title}'),
        bottom: const OfficialAppBarBottom(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(items.length, (i) {
                        final active = i == _index;
                        final done = i < _index;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: done || active
                                ? AppColors.zellige
                                : AppColors.jasmineDim,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_index + 1} / ${items.length}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _replay,
                        child: Center(
                          child: ScaleTransition(
                            scale: CurvedAnimation(
                              parent: _entrance,
                              curve: Curves.elasticOut,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(36),
                              decoration: BoxDecoration(
                                color: AppColors.jasmineDim,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.sidiBlue.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    items[_index].emoji,
                                    style: const TextStyle(fontSize: 110),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    items[_index].word,
                                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                          color: AppColors.sidiBlue,
                                          fontSize: 32,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Icon(Icons.volume_up_rounded, color: AppColors.ochre),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _next,
                      child: Text(
                        _index + 1 < items.length ? 'التالي' : 'ابدأ التمارين',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
