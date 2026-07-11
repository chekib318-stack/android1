import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// شخصية "المدرس" — معلّم تونسي بمعطف أبيض وشارة العلم التونسي،
/// بصورة حقيقية (assets/images/teacher_happy.png). تدخل البطاقة بحركة
/// انزلاق وتلاشي، بينما تهتز صورة الشخصية بلطف باستمرار وتنبض بسرعة
/// أثناء نطق الجملة لتبدو وكأنها "تتكلم".
class MascotCelebration extends StatefulWidget {
  final String phrase;

  const MascotCelebration({super.key, required this.phrase});

  @override
  State<MascotCelebration> createState() => _MascotCelebrationState();
}

class _MascotCelebrationState extends State<MascotCelebration>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _talk;
  late final AnimationController _wiggle;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    // نبضة "كلام" سريعة تحاكي حركة الشخصية أثناء نطق الجملة (~1.4 ثانية)
    _talk = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _talk.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) _talk.stop();
    });

    // اهتزاز خفيف مستمر يعطي إحساس الحياة بعد انتهاء نبضة الكلام
    _wiggle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _talk.dispose();
    _wiggle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entrance,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutBack)),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.zellige.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.zellige.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              _animatedAvatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المدرس',
                      style: TextStyle(
                        color: AppColors.zellige,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.phrase} 🌼',
                      style: const TextStyle(
                        color: AppColors.zellige,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _animatedAvatar() {
    return AnimatedBuilder(
      animation: Listenable.merge([_talk, _wiggle]),
      builder: (context, child) {
        final talkPulse = _talk.isAnimating ? (_talk.value * 0.05) : 0.0;
        final wiggleAngle = (_wiggle.value - 0.5) * 0.06; // اهتزاز خفيف جدا
        return Transform.rotate(
          angle: wiggleAngle,
          child: Transform.scale(
            scale: 1.0 + talkPulse,
            child: child,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          'assets/images/teacher_happy.png',
          width: 92,
          height: 110,
          fit: BoxFit.cover,
          // نركّز على الوجه والكتفين بدل الصورة كاملة (السبورة والعلم)
          alignment: const Alignment(0.0, -0.55),
        ),
      ),
    );
  }
}
