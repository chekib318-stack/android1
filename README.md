# Arabia Edu – العربية معي (نسخة البداية / MVP)

نموذج أولي فعلي (وليس مجرد mockup) لتطبيق تعليم اللغة العربية، مبني بـ Flutter.
يشتغل بمحتوى تجريبي محليًا بالكامل (بدون خادم بعد)، ليكون أساسًا تُبنى عليه
المراحل القادمة تدريجيًا.

## التشغيل

```bash
flutter pub get
flutter run
```

يحتاج جهازك تثبيت Flutter SDK (قناة stable). يعمل على محاكي Android أو جهاز حقيقي.

## ما هو مُنجز في هذه النسخة

- **الهوية البصرية**: ألوان مستوحاة من تونس (أزرق سيدي بوسعيد، ياسمين، أوكر
  الصحراء، أخضر الزليج) بدل ألوان Duolingo القياسية — انظر
  `lib/theme/app_theme.dart`.
- **العنصر المميز (Signature)**: عقدة الدرس على شكل قوس تونسي (`lib/widgets/lesson_node.dart`)
  بدل الدوائر التقليدية، مع نبض بصري للدرس الحالي.
- **التهيئة الأولى**: تحديد الفئة العمرية واللغة الأم (`lib/screens/onboarding_screen.dart`).
- **مسار تعليمي واحد**: "الكلمات الأولى" (3 دروس، 14 عنصر كلمة/جملة) —
  `lib/data/sample_content.dart`. **هذا محتوى تجريبي (placeholder)**، يُستبدل
  لاحقًا بمحتوى تربوي حقيقي.
- **5 أنواع تمارين تشتغل فعليًا**: اختيار صورة، مطابقة، ترتيب كلمات، استماع
  واختيار (محاكاة صوتية مؤقتة)، إكمال الفراغ — `lib/widgets/exercise_view.dart`.
- **تحفيز**: XP، سلسلة يومية (streak) بمنطق حقيقي (يحسب الأيام المتتالية
  فعليًا)، محفوظ محليًا عبر `shared_preferences` — `lib/providers/progress_provider.dart`.
- **قفل/فتح الدروس تدريجيًا** حسب إتمام الدرس السابق.

## ما هو مؤجل عمدًا (لتفادي تعقيد لا داعي له في MVP)

- الذكاء الاصطناعي (مساعد، تصحيح، تعلم تكيفي حقيقي)
- التعرف الفعلي على النطق (الزر الحالي محاكاة بصرية فقط)
- لوحة الأولياء ولوحة المعلم
- تعدد لغات الواجهة (البنية جاهزة لإضافتها عبر `intl`، لكن غير مفعّلة)
- القصص التفاعلية وقسم "اكتشف تونس"
- الاتصال بخادم حقيقي — كل التقدم محفوظ محليًا على الجهاز فقط حاليًا

## خارطة الطريق المقترحة للمرحلة القادمة (Backend PHP/MySQL)

بما إنك تفضل نفس أسلوب CompEdu وGestiTemps (PHP 7.4 native + MySQL على WAMP)،
الخطوة التالية المنطقية:

1. **قاعدة بيانات**: جداول `users`, `units`, `lessons`, `exercises`,
   `user_progress`, `user_answers` — نفس منطق الترحيل الآمن (migrate_all_safe.sql)
   المعتمد في مشاريعك السابقة.
2. **REST API بسيط** (PHP native، بدون framework): endpoints لجلب المحتوى
   (`GET /api/units`)، تسجيل الدخول، ورفع التقدم (`POST /api/progress`).
3. **استبدال `ProgressProvider` المحلي** باستدعاءات HTTP (package `http` في
   Flutter) مع الإبقاء على `shared_preferences` كطبقة cache للعمل دون انترنت.
4. بعدها فقط: لوحة الأولياء (تُبنى كموقع ويب PHP منفصل، تقرأ من نفس القاعدة —
   تمامًا كما فعلت في CompEdu).

## نشر عبر GitHub + Codemagic (بناء APK بدون Flutter SDK محليا)

### خطوة حاسمة أولا: إتمام هيكل المشروع

هذا المستودع يحتوي فقط على `lib/` و`pubspec.yaml` (منطق Dart). **ينقصه مجلد
`android/` (وgradle، والأيقونات، وAndroidManifest)** الذي يولّده Flutter تلقائيا.
لازم تنفذ هذا **مرة واحدة على جهازك** (يحتاج Flutter SDK مثبت محليا فقط لهذه
الخطوة، حتى لو البناء النهائي يصير على Codemagic):

```bash
cd arabia_edu
flutter create . --platforms=android,ios --org tn.gov.education
flutter pub get
```

هذا يملأ `android/` بملفات gradle صحيحة وأيقونات launcher حقيقية (PNG فعلية
وليست وهمية) — وهذا بالضبط ما تسبب في مشكلة "الأيقونات المزيفة" التي واجهتها
سابقا في ExamGuard. بعدها راجع `android/app/src/main/AndroidManifest.xml`
وتأكد أن `<application>` يحتوي `android:label="العربية معي"` وربط الأيقونة
سليم قبل أي commit.

### رفع المشروع إلى GitHub

```bash
git init
git add .
git commit -m "Initial MVP: Arabia Edu Flutter app"
git branch -M main
git remote add origin https://github.com/<اسمك>/arabia-edu.git
git push -u origin main
```

### ربط Codemagic

1. سجل دخول على codemagic.io بحساب GitHub نفسه.
2. أضف التطبيق (Add application) واختر مستودع `arabia-edu`.
3. Codemagic سيكتشف `codemagic.yaml` تلقائيا في جذر المشروع (موجود هنا).
4. قبل أول build: تأكد من نوع `instance_type` المتاح في خطتك (Free/Pro) —
   هذا بالضبط ما تسبب سابقا في قيود الفوترة. اترك السطر معلقا (comment) في
   `codemagic.yaml` إذا لم تكن متأكدا، ودع Codemagic يختار تلقائيا.
5. اضغط Start new build على فرع `main`. الـ APK الناتج يظهر في تبويب
   Artifacts، ويصلك بالبريد أيضا حسب الإعداد في `codemagic.yaml`.

### قبل كل build تحقق من:

- عدم وجود placeholders في الأيقونات (`android/app/src/main/res/mipmap-*/ic_launcher.png`)
- سلامة `AndroidManifest.xml` (لا تحرير يدوي غير منتبه له، خاصة الترميز/encoding)
- أن `flutter analyze` لا يعطي أخطاء حرجة (السكريبت في `codemagic.yaml` لا يوقف
  البناء عند تحذيرات بسيطة، لكن راقبه في اللوق)


```
lib/
  theme/          الهوية البصرية (ألوان، خطوط)
  models/         نماذج البيانات (Lesson, Exercise, LearningUnit)
  data/           المحتوى التجريبي (يُستبدل بـ API لاحقًا)
  providers/      إدارة الحالة (تقدم المتعلم)
  screens/        الشاشات (onboarding, home, lesson, lesson_complete)
  widgets/        عناصر واجهة قابلة لإعادة الاستخدام
```

## تحديث: الصوت الحقيقي (TTS) والمستويات الدراسية

- **الصوت**: يستعمل التطبيق الآن محرك TTS المدمج بالهاتف (`lib/services/audio_service.dart`)
  لنطق أي كلمة عربية فوريا — في تمرين "استماع واختر" (تلقائيا عند الفتح + زر
  إعادة الاستماع) وزر 🔊 صغير في تمارين اختيار الصورة. **لا حاجة لأي ملف صوتي
  مرفوع** في هذه المرحلة.
- **الانتقال لاحقا لتسجيلات حقيقية على الخادم (PHP)**: حين تتوفر تسجيلات بصوت
  بشري، تُستبدل `AudioService.speak()` بمنطق: تحقق من وجود ملف صوتي حقيقي
  (محليا مخزن مؤقتا أو من رابط الخادم) ثم شغّله بحزمة `audioplayers`، وإن لم
  يوجد استعمل TTS كبديل احتياطي. هذا يسمح باستبدال تدريجي كلمة بكلمة بلا كسر شيء.
- **المستويات الدراسية**: أضيف حقل `gradeLevel` لنموذج `LearningUnit`
  (`lib/models/lesson.dart`). الوحدة الحالية موسومة "تحضيري". الخطوة القادمة:
  إنشاء وحدة/وحدات منفصلة لكل من سنة 1 إلى سنة 6 في `lib/data/sample_content.dart`
  (أو جلبها من الخادم لاحقا)، مع شاشة اختيار مستوى بسيطة في `home_screen.dart`.
