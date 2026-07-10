import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// شارة صغيرة (رمز + قيمة) تستعمل لعرض السلسلة اليومية أو نقاط الخبرة
class StatPill extends StatelessWidget {
  final String icon;
  final String value;
  final Color color;

  const StatPill({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: color == AppColors.jasmine ? AppColors.ink : color,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
