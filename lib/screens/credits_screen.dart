import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/official_badge.dart';
import 'welcome_name_screen.dart';

/// شاشة تعريفية بمطوّر التطبيق وحقوق النشر، تُعرض مرة واحدة بعد شاشة
/// الترحيب الرسمية وقبل الدخول لسؤال الاسم. تنتقل تلقائيا بعد 7 ثوانٍ،
/// أو فورا عند الضغط على زر "متابعة".
class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 7), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeNameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.sidiBlueDeep, AppColors.sidiBlue],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const OfficialBadge(light: true, compact: true),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset('assets/images/prepedu_logo.png', height: 60),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.jasmine.withOpacity(0.1),
                            border: Border.all(color: AppColors.ochre, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.ochre.withOpacity(0.35),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.code_rounded, color: AppColors.jasmine, size: 40),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.jasmine.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.jasmine.withOpacity(0.2)),
                          ),
                          child: Text(
                            'تم تطوير هذا التطبيق في وزارة التربية التونسية سنة 2026.\n'
                            'جميع الحقوق محفوظة لوزارة التربية التونسية، ولا يجوز '
                            'بيع هذا التطبيق أو المتاجرة فيه بأي شكل من الأشكال.\n'
                            'صُمِّم خصيصا لأبناء الجالية التونسية بالخارج.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.jasmine.withOpacity(0.85),
                              fontSize: 13,
                              height: 1.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // معلومات المطوّر: كتلة صغيرة أسفل الفقرة الرئيسية
                        Text(
                          'مطوّر التطبيقة: شكيب الوسلاتي',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.jasmine.withOpacity(0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'ديوان وزير التربية',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.jasmine.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.jasmine.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.jasmine.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.email_outlined, color: AppColors.jasmine, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'chekib318@gmail.com',
                                style: TextStyle(
                                  color: AppColors.jasmine.withOpacity(0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Image.asset('assets/images/flag_tunisia.png', height: 54),
                const SizedBox(height: 8),
                Text(
                  'الجمهورية التونسية',
                  style: TextStyle(
                    color: AppColors.jasmine.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 18),
                // زر جديد للمواصلة يدويا بعد القراءة، بدل انتظار المؤقت فقط
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goNext,
                    child: const Text('متابعة'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
