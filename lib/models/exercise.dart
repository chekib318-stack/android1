/// أنواع التمارين المدعومة في نسخة البداية (MVP)
/// يمكن إضافة أنواع جديدة لاحقًا: تسجيل صوت، سحب وإفلات متقدم، تحدي زمني...
enum ExerciseType {
  chooseImage, // اختيار الصورة/الرمز المناسب للكلمة المنطوقة أو المكتوبة
  matchPairs, // مطابقة كلمة بمعناها أو رمزها
  arrangeWords, // ترتيب كلمات لتكوين جملة صحيحة
  listenChoose, // الاستماع (نص تمثيلي بدل صوت حقيقي حاليًا) ثم اختيار الإجابة
  fillBlank, // إكمال الفراغ في كلمة أو جملة
}

class Exercise {
  final String id;
  final ExerciseType type;
  final String prompt; // نص السؤال المعروض للمتعلم
  final String? targetWord; // الكلمة/الجملة الصحيحة (لأنواع الترتيب والفراغ)
  final String? emoji; // رمز تعبيري كبديل مؤقت عن صورة حقيقية
  final List<String> options; // الخيارات المعروضة (نصوص أو رموز)
  final String correctAnswer; // الإجابة الصحيحة من ضمن options أو targetWord
  final List<String>? scrambledWords; // للكلمات المبعثرة (ترتيب) أو الرموز المخلوطة (مطابقة)
  final List<String>? pairAnswers; // الرمز الصحيح المقابل لكل عنصر في options (لتمرين المطابقة فقط)

  const Exercise({
    required this.id,
    required this.type,
    required this.prompt,
    required this.correctAnswer,
    this.targetWord,
    this.emoji,
    this.options = const [],
    this.scrambledWords,
    this.pairAnswers,
  });
}
