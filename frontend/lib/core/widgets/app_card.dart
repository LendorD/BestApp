import 'package:flutter/material.dart';

import '../../app/theme.dart';

class AppCard extends StatefulWidget {
  const AppCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(22),
    this.gradient,
    this.color,
    this.borderColor,
    this.radius = 8,
    this.hoverLift = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final bool hoverLift;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.borderColor ?? (_hovered ? AppColors.neon : AppColors.border);
    final shadowAlpha = _hovered && widget.onTap != null ? 0.5 : 0.38;
    final radius = BorderRadius.circular(widget.radius);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          scale: _hovered && widget.onTap != null && widget.hoverLift
              ? 1.006
              : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.color ?? widget.color ?? AppColors.surface,
              gradient: widget.gradient,
              borderRadius: radius,
              border: Border.all(color: borderColor.withValues(alpha: 0.92)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: shadowAlpha),
                  blurRadius: _hovered && widget.onTap != null ? 16 : 10,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius - 2),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  color: Colors.transparent,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
