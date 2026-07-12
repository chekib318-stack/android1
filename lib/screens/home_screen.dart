import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/sample_content.dart';
import '../models/lesson.dart';
import '../providers/progress_provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/lesson_node.dart';
import '../widgets/stat_pill.dart';
import 'lesson_intro_screen.dart';
import 'voice_settings_screen.dart';
import '../widgets/official_badge.dart';

/// الأعداد الترتيبية العربية (الأول، الثاني...) لتسمية الدروس فى القائمة.
const List<String> arabicOrdinals = [
  'الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس',
  'السادس', 'السابع', 'الثامن', 'التاسع', 'العاشر',
  'الحادي عشر', 'الثاني عشر', 'الثالث عشر', 'الرابع عشر', 'الخامس عشر',
  'السادس عشر', 'السابع عشر', 'الثامن عشر', 'التاسع عشر', 'العشرون',
];

class HomeScreen extends StatefulWidget {
  final bool announceNext; // نطق "اختر الدرس الموالي" عند الرجوع من إنهاء درس

  const HomeScreen({super.key, this.announceNext = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final message = widget.announceNext
          ? 'الدرس الموالي'
          : 'اختر درسا من قائمة الدروس';
      AudioService.instance.speak(message);
    });
  }

  /// كل الدروس مرتبة (كل وحدة تحتوي درسا واحدا في هذه النسخة)، لحساب
  /// القفل/الفتح بشكل متسلسل: كل درس يفتح الدرس الذي يليه مباشرة.
  List<Lesson> get _allLessons =>
      kindergartenUnits.expand((unit) => unit.lessons).toList();

  LessonNodeState _stateFor(
    Lesson lesson,
    int globalIndex,
    ProgressProvider progress,
  ) {
    if (progress.isCompleted(lesson.id)) return LessonNodeState.completed;
    final lessons = _allLessons;
    final previousLesson = globalIndex == 0 ? null : lessons[globalIndex - 1];
    final unlocked = previousLesson == null || progress.isCompleted(previousLesson.id);
    return unlocked ? LessonNodeState.current : LessonNodeState.locked;
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إعادة تصفير التقدم'),
        content: const Text(
          'سيتم حذف كل الدروس المكتملة والنقاط، وتصبح القائمة كأنك لم تقم '
          'بأي درس بعد. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.harissa),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('نعم، صفّر التقدم'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ProgressProvider>().resetLessonsProgress();
    }
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('الاتصال بالدعم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المهندس شكيب الوسلاتي',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text('ديوان وزير التربية'),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.jasmineDim,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.email_outlined, size: 18, color: AppColors.sidiBlue),
                  SizedBox(width: 8),
                  Text('chekib318@gmail.com', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: 'chekib318@gmail.com'));
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('تم نسخ البريد الإلكتروني')),
                );
              }
            },
            child: const Text('نسخ البريد الإلكتروني'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final lessons = _allLessons;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/prepedu_logo.png', height: 34),
            const SizedBox(width: 8),
            const Flexible(
              child: Text('تعليم العربية — تحضيري', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        bottom: const OfficialAppBarBottom(),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                StatPill(icon: '🔥', value: '${progress.streakDays}', color: AppColors.ochre),
                const SizedBox(width: 8),
                StatPill(icon: '⭐', value: '${progress.xp}', color: AppColors.zellige),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // شريط أزرار واضح في جسم الصفحة (بدل AppBar) لضمان استجابة اللمس
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: _toolbarButton(
                      icon: Icons.restart_alt_rounded,
                      label: 'تصفير التقدم',
                      color: AppColors.harissa,
                      onTap: () => _confirmReset(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _toolbarButton(
                      icon: Icons.record_voice_over_outlined,
                      label: 'صوت القراءة',
                      color: AppColors.sidiBlue,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const VoiceSettingsScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _toolbarButton(
                      icon: Icons.support_agent_rounded,
                      label: 'الدعم',
                      color: AppColors.zellige,
                      onTap: () => _showSupportDialog(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          itemCount: lessons.length + (progress.studentName.isNotEmpty ? 1 : 0),
          itemBuilder: (context, index) {
            final hasGreeting = progress.studentName.isNotEmpty;
            if (hasGreeting && index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    const Text('🕊️', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Text(
                      'مرحبا ${progress.studentName}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.sidiBlue,
                          ),
                    ),
                  ],
                ),
              );
            }
            final i = hasGreeting ? index - 1 : index;
            final lesson = lessons[i];
            final state = _stateFor(lesson, i, progress);
            final ordinal = i < arabicOrdinals.length ? arabicOrdinals[i] : '${i + 1}';

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: state == LessonNodeState.locked
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LessonIntroScreen(lesson: lesson, ordinal: ordinal),
                          ),
                        );
                      },
                child: Opacity(
                  opacity: state == LessonNodeState.locked ? 0.5 : 1,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: state == LessonNodeState.completed
                          ? AppColors.zellige.withOpacity(0.1)
                          : AppColors.jasmineDim,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: state == LessonNodeState.completed
                            ? AppColors.zellige.withOpacity(0.4)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: FittedBox(
                            child: LessonNode(
                              icon: lesson.icon,
                              title: '',
                              state: state,
                              onTap: null,
                              showTitle: false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الدرس $ordinal',
                                style: TextStyle(
                                  color: AppColors.inkFaint,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lesson.title,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          state == LessonNodeState.completed
                              ? Icons.check_circle
                              : Icons.chevron_left,
                          color: state == LessonNodeState.completed
                              ? AppColors.zellige
                              : AppColors.inkFaint,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbarButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
