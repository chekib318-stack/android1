import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'credits_screen.dart';

/// أول شاشة تظهر عند فتح التطبيق: هوية رسمية (الشعار، العلم، اسم التطبيق
/// ووزارة الإشراف)، تبقى بضع ثوانٍ ثم تنتقل تلقائيًا لشاشة المطوّر.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 7), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CreditsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.jasmine,
      body: Stack(
        children: [
          SafeArea(
            child: GestureDetector(
              // يسمح بتخطي الشاشة بالضغط في أي مكان لمن يريد الدخول أسرع
              onTap: _goNext,
              behavior: HitTestBehavior.opaque,
              child: SingleChildScrollView(
                // تمرير حر بدل Column ثابت، حتى لا يُقطع أي محتوى على
                // الشاشات الصغيرة (كان هذا سبب اختفاء علامة النسخة سابقا)
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo_ministere.png', height: 130),
                    const SizedBox(height: 22),
                    Text(
                      'وزارة التربية',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.sidiBlueDeep,
                          ),
                    ),
                    Text(
                      'الجمهورية التونسية',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 36),
                    Container(
                      height: 1,
                      width: 120,
                      color: AppColors.ochre.withOpacity(0.4),
                    ),
                    const SizedBox(height: 36),
                    Text(
                      'تعليم اللغة العربية لأبناء الجالية التونسية بالخارج',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 28,
                            color: AppColors.sidiBlue,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.zellige.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'القسم التحضيري — prepEdu',
                        style: TextStyle(
                          color: AppColors.zellige,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Image.asset('assets/images/flag_tunisia.png', height: 70),
                    const SizedBox(height: 24),
                    Image.asset('assets/images/prepedu_logo.png', height: 150),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          // علامة النسخة: ثابتة في الزاوية العلوية دائما، لا تعتمد على
          // طول المحتوى ولا يمكن أن تختفي بسبب overflow.
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'build v1.1.1+26',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
