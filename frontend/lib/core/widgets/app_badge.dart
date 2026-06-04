import 'package:flutter/material.dart';

import '../../app/theme.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    super.key,
    this.icon,
    this.color = AppColors.neon,
    this.compact = false,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 11,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: compact ? 15 : 17),
            SizedBox(width: compact ? 6 : 7),
          ],
          Text(label, style: AppTypography.badge.copyWith(color: color)),
        ],
      ),
    );
  }
}
