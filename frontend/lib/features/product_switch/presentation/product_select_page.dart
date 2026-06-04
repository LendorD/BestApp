import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/storage/product_preference.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_network_image.dart';

class ProductSelectPage extends StatelessWidget {
  const ProductSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SelectHeader(),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final cards = [
              _LabCard(
                product: ProductDirection.dota,
                title: 'Dota 2 Lab',
                subtitle:
                    'Player analytics, AI coach, hero pool, match form and training plan.',
                imageUrl: '/assets/gamementor/home/dota-card.jpg',
                accent: AppColors.dotaAccent,
                icon: Icons.query_stats_rounded,
                bullets: const [
                  'AI Coach',
                  'Match analysis',
                  'Profile statistics',
                  'Best heroes',
                  'Training plan',
                ],
              ),
              _LabCard(
                product: ProductDirection.cs2,
                title: 'CS2 Lab',
                subtitle:
                    'Grenades, maps, positions, utility sets and practice workflows.',
                imageUrl: '/assets/gamementor/home/cs2-card.jpg',
                accent: AppColors.cs2Accent,
                icon: Icons.radar_rounded,
                bullets: const [
                  'Grenades',
                  'Maps',
                  'Positions',
                  'Training',
                  'Utility sets',
                ],
              ),
            ];

            if (!isWide) {
              return Column(
                children: [
                  for (final card in cards)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: card,
                    ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 16),
                Expanded(child: cards[1]),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        const _SavedProductPanel(),
      ],
    );
  }
}

class _SelectHeader extends StatelessWidget {
  const _SelectHeader();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hoverLift: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppBadge(
                    icon: Icons.workspace_premium_rounded,
                    label: 'GameMentor',
                    color: AppColors.warningPro,
                  ),
                  AppBadge(
                    icon: Icons.hub_rounded,
                    label: 'Choose product',
                    color: AppColors.text,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Choose your Lab',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.02,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'GameMentor is split into two professional products. Pick the workflow you need now; you can switch later from the product switcher.',
                style: AppTypography.bodyMuted,
              ),
            ],
          );
          final metrics = const _SelectMetrics();

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 18), metrics],
            );
          }

          return Row(
            children: [
              Expanded(flex: 6, child: title),
              const SizedBox(width: 24),
              Expanded(flex: 4, child: metrics),
            ],
          );
        },
      ),
    );
  }
}

class _SelectMetrics extends StatelessWidget {
  const _SelectMetrics();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('500+', 'grenades'),
      ('20+', 'maps'),
      ('AI', 'coach'),
      ('2', 'labs'),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final item in items)
          Container(
            width: 122,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.$1,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(item.$2, style: AppTypography.label),
              ],
            ),
          ),
      ],
    );
  }
}

class _LabCard extends StatelessWidget {
  const _LabCard({
    required this.product,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.accent,
    required this.icon,
    required this.bullets,
  });

  final ProductDirection product;
  final String title;
  final String subtitle;
  final String imageUrl;
  final Color accent;
  final IconData icon;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => _select(context, product),
      padding: EdgeInsets.zero,
      borderColor: accent.withValues(alpha: 0.55),
      child: SizedBox(
        height: 460,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.black.withValues(alpha: 0.08),
                          AppColors.black.withValues(alpha: 0.62),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 18,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.72),
                        border: Border.all(color: accent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: accent),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMuted,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final bullet in bullets)
                        AppBadge(label: bullet, color: accent, compact: true),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _select(context, product),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text('Enter ${product.label}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedProductPanel extends StatelessWidget {
  const _SavedProductPanel();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductDirection?>(
      future: ProductPreference.load(),
      builder: (context, snapshot) {
        final product = snapshot.data;
        if (product == null) {
          return const SizedBox.shrink();
        }
        return AppCard(
          hoverLift: false,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.history_rounded, color: _accent(product)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Last selected product: ${product.label}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (product == ProductDirection.dota) ...[
                TextButton.icon(
                  onPressed: () => context.go(
                    '/dota?account_id=${AppConfig.defaultDotaAccountId}',
                  ),
                  icon: const Icon(Icons.person_search_rounded),
                  label: const Text('Мой профиль'),
                ),
                const SizedBox(width: 8),
              ],
              TextButton.icon(
                onPressed: () => context.go(product.path),
                icon: const Icon(Icons.login_rounded),
                label: const Text('Continue'),
              ),
            ],
          ),
        );
      },
    );
  }
}

void _select(BuildContext context, ProductDirection product) {
  ProductPreference.save(product);
  context.go(product.path);
}

Color _accent(ProductDirection product) {
  return switch (product) {
    ProductDirection.dota => AppColors.dotaAccent,
    ProductDirection.cs2 => AppColors.cs2Accent,
  };
}
