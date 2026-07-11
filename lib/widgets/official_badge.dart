import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// شارة الهوية الرسمية (علم تونس + الجمهورية التونسية + وزارة التربية)،
/// تُستعمل في كل شاشات التطبيق لتعزيز الهوية الرسمية بشكل موحّد وأنيق.
///
/// [light] يُستعمل في الشاشات ذات الخلفية الداكنة (مثل شاشة الإجابة
/// الخاطئة) لعكس ألوان النص لتبقى مقروءة بوضوح.
class OfficialBadge extends StatelessWidget {
  final bool light;
  final bool compact;

  const OfficialBadge({super.key, this.light = false, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final textColor = light ? Colors.white : AppColors.sidiBlueDeep;
    final subColor = light ? Colors.white70 : AppColors.inkFaint;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Image.asset(
            'assets/images/flag_tunisia.png',
            height: compact ? 16 : 20,
          ),
        ),
        SizedBox(width: compact ? 6 : 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'الجمهورية التونسية',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: compact ? 10 : 12,
                height: 1.1,
              ),
            ),
            Text(
              'وزارة التربية',
              style: TextStyle(
                color: subColor,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 9 : 11,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// شريط رفيع يُضاف أسفل AppBar لعرض شارة الهوية الرسمية (لشاشات فيها
/// AppBar جاهز أصلا، بدل تكرار بناء شريط جديد في كل شاشة).
class OfficialAppBarBottom extends StatelessWidget implements PreferredSizeWidget {
  const OfficialAppBarBottom({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(30);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.inkFaint.withOpacity(0.15)),
        ),
      ),
      child: const OfficialBadge(compact: true),
    );
  }
}
