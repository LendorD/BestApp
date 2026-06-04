import 'package:flutter/material.dart';

import '../../app/theme.dart';

class AppGlassPanel extends StatelessWidget {
  const AppGlassPanel({
    required this.child,
    required this.height,
    super.key,
    this.radius = 8,
    this.padding = const EdgeInsets.all(18),
    this.fallbackWidth = 420,
  });

  final Widget child;
  final double height;
  final double radius;
  final EdgeInsetsGeometry padding;
  final double fallbackWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : fallbackWidth;
        return Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.panel,
          ),
          child: child,
        );
      },
    );
  }
}
