import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme.dart';

class AppCard extends StatefulWidget {
  const AppCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(22),
    this.gradient,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? borderColor;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.borderColor ??
        (_hovered ? GameMentorColors.blue : GameMentorColors.border);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: _hovered && widget.onTap != null ? 1.015 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: widget.padding,
            decoration: BoxDecoration(
              color: GameMentorColors.surface.withValues(alpha: 0.76),
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: GameMentorColors.purple.withValues(
                    alpha: _hovered ? 0.18 : 0.08,
                  ),
                  blurRadius: _hovered ? 32 : 18,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
