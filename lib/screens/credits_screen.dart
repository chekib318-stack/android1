import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'welcome_name_screen.dart';

/// شاشة تعريفية قصيرة بمطوّر التطبيق، تُعرض مرة واحدة بعد شاشة الترحيب
/// الرسمية وقبل الدخول لتحديد الفئة العمرية.
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
      backgroundColor: AppColors.sidiBlue,
      body: SafeArea(
        child: GestureDetector(
          onTap: _goNext,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.code_rounded, color: AppColors.jasmine, size: 56),
                const SizedBox(height: 24),
                Text(
                  'تطوير التطبيق',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.jasmine.withOpacity(0.8),
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'المهندس شكيب الوسلاتي',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 30,
                        color: AppColors.jasmine,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ديوان وزير التربية',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.jasmine.withOpacity(0.9),
                      ),
                ),
                const SizedBox(height: 28),
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
                      const Icon(Icons.email_outlined, color: AppColors.jasmine, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'chekib318@gmail.com',
                        style: TextStyle(
                          color: AppColors.jasmine.withOpacity(0.95),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
