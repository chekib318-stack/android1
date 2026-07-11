import 'exercise.dart';

/// عنصر تمهيدي واحد (كلمة + رمز تعبيري + تأثير صوتي اختياري) يُعرض في
/// الدرس التمهيدي قبل بداية الأسئلة، لتعليم المفردة بالصوت والصورة أولا.
class IntroItem {
  final String word;
  final String emoji;
  final String? soundEffect;

  const IntroItem({required this.word, required this.emoji, this.soundEffect});
}

/// الدرس: وحدة تعلم صغيرة مدتها 3-5 دقائق ضمن مسار أكبر (مثلاً: الحروف)
class Lesson {
  final String id;
  final String title;
  final String icon; // رمز تعبيري يمثل موضوع الدرس
  final List<Exercise> exercises;
  final List<IntroItem> introItems; // مفردات الدرس التمهيدي (قبل الأسئلة)
  final int xpReward;

  const Lesson({
    required this.id,
    required this.title,
    required this.icon,
    required this.exercises,
    this.introItems = const [],
    this.xpReward = 20,
  });
}

/// المسار التعليمي: تجميعة دروس متدرجة (الحروف، الحركات، الكلمات...)
class LearningUnit {
  final String id;
  final String title;
  final String description;
  final String gradeLevel; // مثال: 'تحضيري', 'سنة 1', ... 'سنة 6'
  final List<Lesson> lessons;

  const LearningUnit({
    required this.id,
    required this.title,
    required this.description,
    required this.lessons,
    this.gradeLevel = 'تحضيري',
  });
}
