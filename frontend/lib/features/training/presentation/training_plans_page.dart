import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/section_header.dart';

class TrainingPlansPage extends StatelessWidget {
  const TrainingPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final plans = [
      _TrainingPlan(
        title: 'Mirage utility block',
        subtitle: '20 минут смоков для мида и A execute.',
        progress: 0.68,
        color: AppColors.cyan,
        icon: Icons.cloud_rounded,
        imageUrl: '/assets/gamementor/cs2/maps/mirage.jpg',
      ),
      _TrainingPlan(
        title: 'Inferno banana control',
        subtitle: 'Флеши, тайминги pop-flash и retake brackets.',
        progress: 0.42,
        color: AppColors.amber,
        icon: Icons.flash_on_rounded,
        imageUrl: '/assets/gamementor/cs2/maps/inferno.jpg',
      ),
      _TrainingPlan(
        title: 'Dota hero pool reset',
        subtitle: 'Сужаем пул и стабилизируем ranked-результаты.',
        progress: 0.31,
        color: AppColors.neon,
        icon: Icons.auto_graph_rounded,
        imageUrl: '/assets/gamementor/home/dota-card.jpg',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'План тренировок',
          subtitle:
              'Персональные рутины выглядят как подписочный workflow: прогресс, фокус и следующий шаг.',
          trailing: AppBadge(
            icon: Icons.bolt_rounded,
            label: 'Personal coaching',
          ),
        ),
        const SizedBox(height: 18),
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
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: columns == 1 ? 1.55 : 1.08,
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
      padding: EdgeInsets.zero,
      borderColor: plan.color.withValues(alpha: 0.34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(imageUrl: plan.imageUrl),
                Positioned(
                  left: 14,
                  top: 14,
                  child: AppBadge(
                    icon: plan.icon,
                    label: '${(plan.progress * 100).round()}%',
                    color: plan.color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  plan.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMuted,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: plan.progress,
                    minHeight: 9,
                    color: plan.color,
                    backgroundColor: AppColors.surfaceAlt,
                  ),
                ),
              ],
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
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final double progress;
  final Color color;
  final IconData icon;
  final String imageUrl;
}
