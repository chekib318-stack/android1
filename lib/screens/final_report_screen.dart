import 'package:flutter/material.dart';
import '../providers/progress_provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/official_badge.dart';
import 'home_screen.dart';

/// شاشة تُعرض بعد إتمام كل الدروس العشرين: تلخّص الأداء الكلي عبر كل
/// الدروس (مجموع الإجابات الصحيحة من مجموع كل الأسئلة)، مع صورة الأستاذ نجيب
/// ضاحكا أو غاضبا حسب النسبة الإجمالية.
class FinalReportScreen extends StatefulWidget {
  final ProgressProvider progress;

  const FinalReportScreen({super.key, required this.progress});

  @override
  State<FinalReportScreen> createState() => _FinalReportScreenState();
}

class _FinalReportScreenState extends State<FinalReportScreen> {
  late final int _correct = widget.progress.totalCorrect;
  late final int _possible = widget.progress.totalPossible;
  late final int _percent =
      _possible == 0 ? 0 : ((_correct / _possible) * 100).round();
  // نفس عتبة نجاح الدرس الواحد (5 من 7 ≈ 71%): نعتبرها هنا كنسبة نجاح إجمالية
  late final bool _isHappy = _possible == 0 ? true : (_correct / _possible) >= (5 / 7);

  @override
  void initState() {
    super.initState();
    final message = _isHappy
        ? 'مبروك! أنهيت كل الدروس بنتيجة ممتازة'
        : 'أنهيت كل الدروس، حاول المراجعة لتحسين نتيجتك';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.instance.speak(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const OfficialBadge(compact: true),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  _isHappy
                      ? 'assets/images/teacher_happy.png'
                      : 'assets/images/teacher_angry.png',
                  width: 160,
                  height: 190,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.0, -0.5),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'لقد أنهيت كل الدروس! 🎓',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 26,
                      color: _isHappy ? AppColors.sidiBlue : AppColors.harissa,
                    ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statCard(
                    '✅',
                    '$_correct / $_possible',
                    'إجمالي الإجابات الصحيحة',
                    _isHappy ? AppColors.zellige : AppColors.harissa,
                  ),
                  const SizedBox(width: 16),
                  _statCard('🎯', '$_percent%', 'النسبة الإجمالية', AppColors.ochre),
                ],
              ),
              const SizedBox(height: 16),
              _statCard('⭐', '${widget.progress.xp}', 'مجموع نقاط الخبرة', AppColors.sidiBlue),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                ),
                child: const Text('العودة للصفحة الرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String icon, String value, String label, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
