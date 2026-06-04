import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../features/dota_stats/domain/dota_heroes.dart';

class DotaHeroesPage extends StatelessWidget {
  const DotaHeroesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final heroes = dotaHeroes.values.take(12).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Hero Statistics',
          subtitle:
              'A focused place for best heroes, weak heroes and future meta analytics.',
          trailing: TextButton.icon(
            onPressed: () => context.go('/dota'),
            icon: const Icon(Icons.query_stats_rounded),
            label: const Text('Analyze player'),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 1050
                ? 4
                : constraints.maxWidth > 700
                ? 3
                : constraints.maxWidth > 480
                ? 2
                : 1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 1 ? 2.8 : 1.35,
              children: [
                for (final hero in heroes)
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    borderColor: AppColors.dotaAccent.withValues(alpha: 0.3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            hero.nameRu,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.trending_up_rounded,
                          color: AppColors.dotaAccent,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
