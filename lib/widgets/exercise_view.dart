import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'mascot_celebration.dart';
import 'wrong_answer_screen.dart';

/// عارض تمرين واحد. يدير الاختيار الداخلي ثم يعرض تغذية راجعة فورية
/// (صحيح/خطأ) قبل استدعاء [onComplete] للانتقال إلى التمرين التالي.
class ExerciseView extends StatefulWidget {
  final Exercise exercise;
  final void Function(bool correct) onComplete;

  const ExerciseView({
    super.key,
    required this.exercise,
    required this.onComplete,
  });

  @override
  State<ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<ExerciseView> {
  String? _selectedOption; // chooseImage / listenChoose / fillBlank
  final List<String> _builtSentence = []; // arrangeWords
  final Set<int> _usedWordIndexes = {};
  int? _selectedWordIndex; // matchPairs: كلمة مختارة بانتظار المطابقة
  final Map<int, bool> _matchedPairs = {}; // matchPairs: index -> صحيح/خطأ نهائي
  bool _revealedAudio = false; // listenChoose: هل ضغط على زر الاستماع
  bool? _isCorrect; // null = لم يتحقق بعد
  bool _checked = false;
  late final List<String> _shuffledOptions; // خيارات مخلوطة عشوائيا (تُحسب مرة واحدة فقط)

  @override
  void initState() {
    super.initState();
    // نخلط ترتيب الخيارات مرة واحدة عند فتح التمرين حتى لا تكون الإجابة
    // الصحيحة دائما في نفس الموضع (كانت دائما أول خيار في البيانات الأصلية).
    _shuffledOptions = List<String>.from(widget.exercise.options)..shuffle();
    // قراءة السؤال صوتيا تلقائيا عند ظهور أي تمرين (كل الأنواع، وليس فقط
    // "استماع واختر")، مع إمكانية إعادة الاستماع لاحقا عبر زر 🔊 أو
    // بالضغط على زر الميكروفون حسب نوع التمرين.
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakPrompt());
  }

  Future<void> _speakPrompt() async {
    final fallbackText = switch (widget.exercise.type) {
      ExerciseType.listenChoose ||
      ExerciseType.chooseImage =>
        widget.exercise.targetWord ?? widget.exercise.prompt,
      ExerciseType.fillBlank ||
      ExerciseType.arrangeWords ||
      ExerciseType.matchPairs =>
        widget.exercise.prompt,
    };
    await AudioService.instance.speakForExercise(widget.exercise.id, fallbackText);
  }

  bool get _canCheck {
    switch (widget.exercise.type) {
      case ExerciseType.chooseImage:
      case ExerciseType.listenChoose:
      case ExerciseType.fillBlank:
        return _selectedOption != null;
      case ExerciseType.arrangeWords:
        return _builtSentence.isNotEmpty;
      case ExerciseType.matchPairs:
        return _matchedPairs.length == (widget.exercise.options.length);
    }
  }

  void _check() {
    bool correct;
    switch (widget.exercise.type) {
      case ExerciseType.chooseImage:
      case ExerciseType.listenChoose:
      case ExerciseType.fillBlank:
        correct = _selectedOption == widget.exercise.correctAnswer;
        break;
      case ExerciseType.arrangeWords:
        correct = _builtSentence.join(' ') == widget.exercise.targetWord;
        break;
      case ExerciseType.matchPairs:
        correct = !_matchedPairs.values.contains(false);
        break;
    }
    setState(() {
      _isCorrect = correct;
      _checked = true;
    });

    if (correct) {
      AudioService.instance.speakCorrect();
    } else {
      AudioService.instance.speakWrong();
      // نعرض شاشة كاملة تثبّت الإجابة الصحيحة، وننتقل للتمرين التالي
      // فقط بعد ما يضغط المتعلم "متابعة" ويرجع منها.
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => WrongAnswerScreen(exercise: widget.exercise),
            ),
          )
          .then((_) => widget.onComplete(false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                widget.exercise.prompt,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            if (widget.exercise.targetWord != null &&
                widget.exercise.type != ExerciseType.listenChoose) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => AudioService.instance
                    .speakForExercise(widget.exercise.id, widget.exercise.targetWord!),
                icon: const Icon(Icons.volume_up_rounded, color: AppColors.sidiBlue),
              ),
            ],
          ],
        ),
        const SizedBox(height: 28),
        Expanded(child: _buildBody()),
        if (_checked) _buildFeedbackBanner(),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _checked
              ? () => widget.onComplete(_isCorrect ?? false)
              : (_canCheck ? _check : null),
          child: Text(_checked ? 'متابعة' : 'تحقق'),
        ),
      ],
    );
  }

  Widget _buildFeedbackBanner() {
    final correct = _isCorrect ?? false;
    if (correct) return const MascotCelebration();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.harissa.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _wrongAnswerMessage(),
              style: const TextStyle(
                color: AppColors.harissa,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _wrongAnswerMessage() {
    if (widget.exercise.type == ExerciseType.matchPairs) {
      return 'تحقق من العناصر الملوّنة بالأحمر وحاول مجددًا في المرة القادمة';
    }
    final answer = widget.exercise.correctAnswer.isNotEmpty
        ? widget.exercise.correctAnswer
        : (widget.exercise.targetWord ?? '');
    return 'الإجابة الصحيحة: $answer';
  }

  Widget _buildBody() {
    switch (widget.exercise.type) {
      case ExerciseType.chooseImage:
        return _optionsGrid(_shuffledOptions, fontSize: 34);
      case ExerciseType.listenChoose:
        return _listenChoose();
      case ExerciseType.fillBlank:
        return _optionsGrid(_shuffledOptions, fontSize: 18);
      case ExerciseType.arrangeWords:
        return _arrangeWords();
      case ExerciseType.matchPairs:
        return _matchPairs();
    }
  }

  Widget _optionsGrid(List<String> options, {required double fontSize}) {
    return Center(
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        alignment: WrapAlignment.center,
        children: options.map((opt) {
          final selected = _selectedOption == opt;
          return GestureDetector(
            onTap: _checked ? null : () => setState(() => _selectedOption = opt),
            child: Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.sidiBlue.withOpacity(0.12)
                    : AppColors.jasmineDim,
                border: Border.all(
                  color: selected ? AppColors.sidiBlue : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                opt,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _listenChoose() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() => _revealedAudio = true);
            AudioService.instance
                .speakForExercise(widget.exercise.id, widget.exercise.targetWord ?? '');
          },
          child: Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: AppColors.sidiBlue,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('🔊', style: TextStyle(fontSize: 34)),
          ),
        ),
        const SizedBox(height: 10),
        // ملاحظة: في النسخة النهائية يُستبدل هذا بتشغيل صوت حقيقي (TTS/تسجيل)
        Text(
          _revealedAudio ? widget.exercise.targetWord ?? '' : 'اضغط للاستماع',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _optionsGrid(_shuffledOptions, fontSize: 18),
      ],
    );
  }

  Widget _arrangeWords() {
    final remaining = <int>[];
    for (var i = 0; i < (widget.exercise.scrambledWords?.length ?? 0); i++) {
      if (!_usedWordIndexes.contains(i)) remaining.add(i);
    }
    return Column(
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.jasmineDim,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Wrap(
            spacing: 8,
            children: _builtSentence
                .asMap()
                .entries
                .map((e) => _wordChip(e.value, onTap: _checked
                    ? null
                    : () {
                        setState(() {
                          _usedWordIndexes.remove(
                            widget.exercise.scrambledWords!.indexOf(e.value),
                          );
                          _builtSentence.removeAt(e.key);
                        });
                      }))
                .toList(),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: remaining.map((i) {
            final word = widget.exercise.scrambledWords![i];
            return _wordChip(
              word,
              filled: true,
              onTap: _checked
                  ? null
                  : () => setState(() {
                        _usedWordIndexes.add(i);
                        _builtSentence.add(word);
                      }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _wordChip(String word, {VoidCallback? onTap, bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: filled ? AppColors.sidiBlue : AppColors.jasmine,
          border: Border.all(color: AppColors.sidiBlue, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          word,
          style: TextStyle(
            color: filled ? AppColors.jasmine : AppColors.sidiBlue,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _matchPairs() {
    final words = widget.exercise.options;
    final emojis = widget.exercise.scrambledWords ?? [];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: List.generate(words.length, (i) {
              final matched = _matchedPairs.containsKey(i);
              final ok = _matchedPairs[i];
              return _tile(
                words[i],
                selected: _selectedWordIndex == i,
                locked: matched,
                color: matched
                    ? (ok! ? AppColors.zellige : AppColors.harissa)
                    : null,
                onTap: matched || _checked
                    ? null
                    : () => setState(() => _selectedWordIndex = i),
              );
            }),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: List.generate(emojis.length, (i) {
              return _tile(
                emojis[i],
                fontSize: 26,
                onTap: (_selectedWordIndex == null || _checked)
                    ? null
                    : () {
                        final wordIdx = _selectedWordIndex!;
                        final isMatch =
                            widget.exercise.pairAnswers?[wordIdx] == emojis[i];
                        setState(() {
                          _matchedPairs[wordIdx] = isMatch;
                          _selectedWordIndex = null;
                        });
                      },
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _tile(
    String label, {
    bool selected = false,
    bool locked = false,
    Color? color,
    double fontSize = 17,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color?.withOpacity(0.15) ??
              (selected
                  ? AppColors.sidiBlue.withOpacity(0.12)
                  : AppColors.jasmineDim),
          border: Border.all(
            color: color ?? (selected ? AppColors.sidiBlue : Colors.transparent),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
