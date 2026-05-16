import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_card.dart';

class TrainingPlansPage extends StatelessWidget {
  const TrainingPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final plans = [
      _TrainingPlan(
        title: 'Mirage Smoke Practice',
        subtitle: '20-minute utility loop for mid and A executes.',
        progress: 0.68,
        color: GameMentorColors.purple,
        icon: Icons.cloud_rounded,
      ),
      _TrainingPlan(
        title: 'Inferno Flash Routine',
        subtitle: 'Banana control, brackets retake, and pop-flash timings.',
        progress: 0.42,
        color: GameMentorColors.blue,
        icon: Icons.wb_sunny_rounded,
      ),
      _TrainingPlan(
        title: 'Dota Hero Pool Improvement',
        subtitle: 'Reduce variance with a compact ranked hero pool.',
        progress: 0.31,
        color: GameMentorColors.green,
        icon: Icons.auto_graph_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Training Plans',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'Mock routines today, personalized coaching paths tomorrow.',
          style: TextStyle(color: GameMentorColors.muted),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 1040
                ? 3
                : constraints.maxWidth > 700
                ? 2
                : 1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: columns == 1 ? 1.7 : 1.15,
              children: [for (final plan in plans) _TrainingCard(plan: plan)],
            );
          },
        ),
      ],
    );
  }
}

class _TrainingCard extends StatelessWidget {
  const _TrainingCard({required this.plan});

  final _TrainingPlan plan;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {},
      gradient: LinearGradient(
        colors: [
          plan.color.withValues(alpha: 0.18),
          GameMentorColors.surface.withValues(alpha: 0.78),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(plan.icon, color: plan.color, size: 38),
          const Spacer(),
          Text(
            plan.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            plan.subtitle,
            style: const TextStyle(color: GameMentorColors.muted, height: 1.4),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: plan.progress,
              minHeight: 9,
              color: plan.color,
              backgroundColor: GameMentorColors.surfaceAlt,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingPlan {
  const _TrainingPlan({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final double progress;
  final Color color;
  final IconData icon;
}
