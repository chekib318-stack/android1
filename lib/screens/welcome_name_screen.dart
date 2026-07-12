import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../services/audio_service.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';
import '../widgets/official_badge.dart';
import 'home_screen.dart';

/// شاشة تُعرض مرة واحدة بعد شاشتي الترحيب الرسميتين: ترحيب بالقسم
/// التحضيري، ثم سؤال صوتي (TTS) عن اسم التلميذ يُجاب عنه صوتيا أيضا
/// (تعرف على الكلام)، ثم رد صوتي شخصي "مرحبا (الاسم)" قبل الانتقال
/// لصفحة الدروس.
class WelcomeNameScreen extends StatefulWidget {
  const WelcomeNameScreen({super.key});

  @override
  State<WelcomeNameScreen> createState() => _WelcomeNameScreenState();
}

enum _Stage { welcome, readyToListen, listening, confirm, noMic, greeting }

class _WelcomeNameScreenState extends State<WelcomeNameScreen> {
  _Stage _stage = _Stage.welcome;
  String _liveText = '';
  String _confirmedName = '';
  Timer? _autoSkipTimer;

  @override
  void initState() {
    super.initState();
    _runWelcomeSequence();
  }

  @override
  void dispose() {
    _autoSkipTimer?.cancel();
    super.dispose();
  }

  Future<void> _runWelcomeSequence() async {
    await AudioService.instance.speak(
      'مرحبا بك في القسم التحضيري. أنا الأستاذ محمد من وزارة التربية التونسية، '
      'سأكون معك في كل الدروس والتمارين',
    );
    if (!mounted) return;
    setState(() => _stage = _Stage.readyToListen);
    await AudioService.instance.speak('ما اسمك؟');
    await AudioService.instance.speak(
      'اضغط على الزر الأحمر وقل اسمك، أو انتظر 10 ثوان للمرور تلقائيا',
    );
    // إذا لم يُسجَّل الاسم خلال 10 ثوانٍ، يمر التطبيق تلقائيا للدروس
    _autoSkipTimer = Timer(const Duration(seconds: 10), _autoSkipToHome);
  }

  void _autoSkipToHome() {
    if (!mounted || _stage == _Stage.greeting) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _startListening() async {
    setState(() {
      _stage = _Stage.listening;
      _liveText = '';
    });
    final started = await SpeechService.instance.listen(
      onResult: (text, isFinal) {
        if (!mounted) return;
        setState(() => _liveText = text);
        if (isFinal && text.trim().isNotEmpty) {
          setState(() {
            _confirmedName = text.trim();
            _stage = _Stage.confirm;
          });
        }
      },
    );
    if (!started && mounted) {
      setState(() => _stage = _Stage.noMic);
    }
  }

  Future<void> _acceptName() async {
    _autoSkipTimer?.cancel();
    await context.read<ProgressProvider>().setStudentName(_confirmedName);
    if (!mounted) return;
    setState(() => _stage = _Stage.greeting);
    await AudioService.instance.speak('مرحبا $_confirmedName');
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _retryListening() {
    setState(() {
      _stage = _Stage.readyToListen;
      _liveText = '';
      _confirmedName = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jasmine,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const OfficialBadge(),
              Expanded(child: Center(child: _buildStage())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStage() {
    switch (_stage) {
      case _Stage.welcome:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/teacher_happy.png',
                width: 140,
                height: 168,
                fit: BoxFit.cover,
                alignment: const Alignment(0.0, -0.5),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'مرحبا بك في القسم التحضيري',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                    color: AppColors.sidiBlue,
                  ),
            ),
            const SizedBox(height: 14),
            Text(
              'أنا الأستاذ محمد من وزارة التربية التونسية\nسأكون معك في كل الدروس والتمارين',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        );

      case _Stage.readyToListen:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ما اسمك؟',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 30,
                    color: AppColors.sidiBlue,
                  ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => AudioService.instance.speak(
                'اضغط على الزر الأحمر وقل اسمك، أو انتظر 10 ثوان للمرور تلقائيا',
              ),
              icon: const Icon(Icons.volume_up_rounded, color: AppColors.sidiBlue),
              label: const Text('إعادة الاستماع للسؤال', style: TextStyle(color: AppColors.sidiBlue)),
            ),
            const SizedBox(height: 36),
            GestureDetector(
              onTap: _startListening,
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: AppColors.harissa,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.mic_rounded, color: Colors.white, size: 52),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'اضغط على الزر الأحمر وقل اسمك\nأو انتظر 10 ثوان للمرور تلقائيا',
              textAlign: TextAlign.center,
            ),
          ],
        );

      case _Stage.listening:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.harissa,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.harissa.withOpacity(0.35),
                    blurRadius: 24,
                    spreadRadius: 8,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 52),
            ),
            const SizedBox(height: 20),
            const Text('...أستمع إليك', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(
              _liveText.isEmpty ? '' : _liveText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        );

      case _Stage.confirm:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤔', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            const Text('هل هذا اسمك؟', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.jasmineDim,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                _confirmedName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 30,
                      color: AppColors.sidiBlue,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _retryListening,
                  child: const Text('أعد المحاولة'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _acceptName,
                  child: const Text('نعم، هذا اسمي'),
                ),
              ],
            ),
          ],
        );

      case _Stage.noMic:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic_off_rounded, color: AppColors.harissa, size: 56),
            const SizedBox(height: 16),
            const Text(
              'تعذّر الوصول إلى الميكروفون.\nتأكد من منح إذن الميكروفون للتطبيق من إعدادات الهاتف.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _retryListening,
              child: const Text('حاول مجددا'),
            ),
          ],
        );

      case _Stage.greeting:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 20),
            Text(
              'مرحبا $_confirmedName',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                    color: AppColors.zellige,
                  ),
            ),
          ],
        );
    }
  }
}
