import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';

class DotaAICoachPage extends StatelessWidget {
  const DotaAICoachPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Dota AI Coach',
          subtitle:
              'The coach block turns analytics into a practical ranked improvement plan.',
          trailing: const AppBadge(
            icon: Icons.workspace_premium_rounded,
            label: 'Pro',
            color: AppColors.warningPro,
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          borderColor: AppColors.dotaAccent.withValues(alpha: 0.45),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final copy = const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBadge(
                    icon: Icons.psychology_alt_rounded,
                    label: 'Snapshot ready',
                    color: AppColors.dotaAccent,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Find the pattern that stops your MMR climb.',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Main mistake example: you do not pressure objectives after won fights, so the advantage disappears before the next timing.',
                    style: AppTypography.bodyMuted,
                  ),
                ],
              );
              final checklist = const _CoachChecklist();
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [copy, SizedBox(height: 18), checklist],
                );
              }
              return Row(
                children: [
                  Expanded(flex: 6, child: copy),
                  SizedBox(width: 24),
                  Expanded(flex: 5, child: checklist),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Connect a player profile first, then generate the AI report from the Dota dashboard.',
                  style: AppTypography.bodyMuted,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => context.go('/dota'),
                icon: const Icon(Icons.query_stats_rounded),
                label: const Text('Open dashboard'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoachChecklist extends StatelessWidget {
  const _CoachChecklist();

  @override
  Widget build(BuildContext context) {
    const items = [
      'Strengths and weaknesses',
      'Main mistakes',
      'Hero focus list',
      'Training plan',
      'Next ranked steps',
    ];
    return Column(
      children: [
        for (final item in items)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.dotaAccent,
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item)),
              ],
            ),
          ),
      ],
    );
  }
}
