import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum LessonNodeState { locked, current, completed }

/// شكل القوس التونسي (مستوحى من نوافذ سيدي بوسعيد) — هذا هو العنصر
/// البصري المميز (Signature) للتطبيق بدل الدوائر القياسية في تطبيقات
/// التعلم المعروفة. كل درس في المسار يظهر كعقدة على شكل هذا القوس.
class _ArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.55)
      ..cubicTo(0, h * 0.12, w * 0.18, 0, w * 0.5, 0)
      ..cubicTo(w * 0.82, 0, w, h * 0.12, w, h * 0.55)
      ..lineTo(w, h)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class LessonNode extends StatefulWidget {
  final String icon;
  final String title;
  final LessonNodeState state;
  final VoidCallback? onTap;

  const LessonNode({
    super.key,
    required this.icon,
    required this.title,
    required this.state,
    this.onTap,
  });

  @override
  State<LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<LessonNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _bodyColor {
    switch (widget.state) {
      case LessonNodeState.locked:
        return AppColors.inkFaint.withOpacity(0.25);
      case LessonNodeState.current:
        return AppColors.ochre;
      case LessonNodeState.completed:
        return AppColors.zellige;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.state == LessonNodeState.locked;

    Widget node = Container(
      decoration: BoxDecoration(
        boxShadow: widget.state == LessonNodeState.locked
            ? []
            : [
                BoxShadow(
                  color: _bodyColor.withOpacity(0.45),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: ClipPath(
        clipper: _ArchClipper(),
        child: Container(
          width: 84,
          height: 84,
          color: _bodyColor,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            widget.state == LessonNodeState.completed ? '✓' : widget.icon,
            style: const TextStyle(fontSize: 30),
          ),
        ),
      ),
    );

    if (widget.state == LessonNodeState.current) {
      node = AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + (_pulseController.value * 0.06);
          return Transform.scale(scale: scale, child: child);
        },
        child: node,
      );
    }

    return GestureDetector(
      onTap: isLocked ? null : widget.onTap,
      child: Opacity(
        opacity: isLocked ? 0.55 : 1,
        child: Column(
          children: [
            node,
            const SizedBox(height: 6),
            SizedBox(
              width: 96,
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
