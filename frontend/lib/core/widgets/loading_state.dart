import 'package:flutter/material.dart';

import '../../app/theme.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.rows = 6});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < rows; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SkeletonBox(
              height: i.isEven ? 124 : 86,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
      ],
    );
  }
}

class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    required this.height,
    super.key,
    this.width,
    this.borderRadius,
  });

  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final slide = _controller.value * 2 - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment(-1 + slide, -0.2),
              end: Alignment(1 + slide, 0.2),
              colors: const [
                GameMentorColors.surface,
                GameMentorColors.surfaceAlt,
                GameMentorColors.surface,
              ],
            ),
            border: Border.all(color: GameMentorColors.border),
          ),
        );
      },
    );
  }
}
