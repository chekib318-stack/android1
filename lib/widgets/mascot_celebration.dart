import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// شخصية "عمّي الياسمين" — رجل تونسي بمشموم (زهرة الياسمين التقليدية)
/// يظهر بحركة نابضة (bounce) عند دخوله، ثم يهتز بلطف باستمرار لإعطاء
/// إحساس بالحيوية والحياة.
///
/// ملاحظة: الشخصية ممثّلة حاليا برموز تعبيرية (شاشية + ياسمين) داخل بطاقة
/// متحركة، وليست رسمة توضيحية مخصصة. يمكن استبدال محتوى الأفاتار لاحقا
/// بصورة حقيقية (مثلا: Image.asset('assets/images/ami_yasmine.png')) إذا
/// تم تصميم شخصية رسومية مخصصة مستقبلا، بلا حاجة لتغيير باقي هذا الملف.
class MascotCelebration extends StatefulWidget {
  const MascotCelebration({super.key});

  @override
  State<MascotCelebration> createState() => _MascotCelebrationState();
}

class _MascotCelebrationState extends State<MascotCelebration>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _wiggle;

  @override
  void initState() {
    super.initState();
    // حركة دخول نابضة (bounce) عند ظهور الشخصية لأول مرة
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    // اهتزاز خفيف مستمر يعطي إحساس الحياة والحركة
    _wiggle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _wiggle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entrance, _wiggle]),
      builder: (context, child) {
        final entranceScale = Curves.elasticOut.transform(_entrance.value);
        final wiggleAngle = (_wiggle.value - 0.5) * 0.12; // اهتزاز خفيف جدا
        return Transform.scale(
          scale: entranceScale.clamp(0.0, 1.4),
          child: Transform.rotate(
            angle: wiggleAngle,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.zellige.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.zellige.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: AppColors.zellige,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('👳🏽‍♂️', style: TextStyle(fontSize: 26)),
                ),
                const Positioned(
                  top: -6,
                  right: -4,
                  child: Text('🌼', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عمّي الياسمين',
                    style: TextStyle(
                      color: AppColors.zellige,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const Text(
                    'إجابة صحيحة 🌼',
                    style: TextStyle(
                      color: AppColors.zellige,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
