import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_glass_panel.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/section_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _accountController = TextEditingController(
    text: AppConfig.defaultDotaAccountId,
  );

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroConsole(accountController: _accountController),
        const SizedBox(height: AppSpacing.section),
        const _KpiGrid(),
        const SizedBox(height: AppSpacing.section),
        _ProductModules(accountController: _accountController),
        const SizedBox(height: AppSpacing.section),
        const _Cs2MapShowcase(),
        const SizedBox(height: AppSpacing.section),
        _DotaQuickPanel(accountController: _accountController),
      ],
    );
  }
}

class _HeroConsole extends StatelessWidget {
  const _HeroConsole({required this.accountController});

  final TextEditingController accountController;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      radius: 16,
      hoverLift: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                children: [
                  const Spacer(flex: 5),
                  Expanded(
                    flex: 6,
                    child: Opacity(
                      opacity: 0.55,
                      child: AppNetworkImage(
                        imageUrl: '/assets/gamementor/home/hero.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.black.withValues(alpha: 0.92),
                      AppColors.background.withValues(alpha: 0.72),
                      AppColors.black.withValues(alpha: 0.34),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 920;
                  final copy = _HeroCopy(accountController: accountController);
                  final preview = const _AnalyticsPreview();

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [copy, const SizedBox(height: 22), preview],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 6, child: copy),
                      const SizedBox(width: 28),
                      Expanded(flex: 5, child: preview),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.accountController});

  final TextEditingController accountController;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppBadge(
                icon: Icons.workspace_premium_rounded,
                label: 'Premium analytics',
              ),
              AppBadge(
                icon: Icons.track_changes_rounded,
                label: 'CS2 utility lab',
                color: AppColors.cyan,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Игровая аналитика без ощущения игрового лендинга',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.02,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'GameMentor объединяет CS2 раскидки, Dota 2 профиль, KPI формы и персональные тренировки в аккуратную SaaS-консоль для игроков.',
            style: TextStyle(
              color: AppColors.textSoft,
              fontSize: 17,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 22),
          _HeroActions(accountController: accountController),
        ],
      ),
    );
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions({required this.accountController});

  final TextEditingController accountController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final input = TextField(
          controller: accountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'OpenDota account ID',
            prefixIcon: Icon(Icons.tag_rounded),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
          onSubmitted: (value) => _openDota(context, value),
        );
        final button = ElevatedButton.icon(
          onPressed: () => _openDota(context, accountController.text),
          icon: const Icon(Icons.query_stats_rounded),
          label: const Text('Открыть анализ'),
        );
        final cs2Button = OutlinedButton.icon(
          onPressed: () => context.go('/cs2'),
          icon: const Icon(Icons.radar_rounded),
          label: const Text('CS2 база'),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              input,
              const SizedBox(height: 10),
              button,
              const SizedBox(height: 10),
              cs2Button,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: input),
            const SizedBox(width: 10),
            button,
            const SizedBox(width: 10),
            cs2Button,
          ],
        );
      },
    );
  }
}

class _AnalyticsPreview extends StatelessWidget {
  const _AnalyticsPreview();

  @override
  Widget build(BuildContext context) {
    return AppGlassPanel(
      height: 330,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Live player board',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              AppBadge(
                icon: Icons.auto_graph_rounded,
                label: 'AI',
                color: AppColors.amber,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _PreviewChart(),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(
                child: _PreviewMetric(
                  label: 'Winrate',
                  value: '64%',
                  color: AppColors.neon,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _PreviewMetric(
                  label: 'KDA',
                  value: '4.49',
                  color: AppColors.cyan,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _PreviewMetric(
                  label: 'GPM',
                  value: '612',
                  color: AppColors.amber,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              for (final hero in _previewHeroes)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AppNetworkImage(
                      imageUrl: hero,
                      fallbackImageUrl: '/assets/gamementor/home/dota-card.jpg',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  'Герои, матчи, графики и показатели в одном срезе',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.muted, height: 1.35),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewChart extends StatelessWidget {
  const _PreviewChart();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      width: double.infinity,
      child: CustomPaint(painter: _PreviewChartPainter()),
    );
  }
}

class _PreviewChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height / 3 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final fillPath = Path();
    final linePath = Path();
    final points = <Offset>[
      Offset(0, size.height * 0.72),
      Offset(size.width * 0.16, size.height * 0.48),
      Offset(size.width * 0.32, size.height * 0.58),
      Offset(size.width * 0.49, size.height * 0.28),
      Offset(size.width * 0.66, size.height * 0.36),
      Offset(size.width * 0.82, size.height * 0.18),
      Offset(size.width, size.height * 0.24),
    ];

    for (var i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
        fillPath.moveTo(points[i].dx, size.height);
        fillPath.lineTo(points[i].dx, points[i].dy);
      } else {
        linePath.lineTo(points[i].dx, points[i].dy);
        fillPath.lineTo(points[i].dx, points[i].dy);
      }
    }
    fillPath
      ..lineTo(size.width, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.neon.withValues(alpha: 0.26),
          AppColors.neon.withValues(alpha: 0.01),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = AppColors.neon
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3;
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PreviewMetric extends StatelessWidget {
  const _PreviewMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.label),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid();

  @override
  Widget build(BuildContext context) {
    final items = const [
      _KpiItem('500+', 'гранат', Icons.grain_rounded, AppColors.neon),
      _KpiItem('20+', 'карт и сценариев', Icons.map_rounded, AppColors.cyan),
      _KpiItem('AI', 'аналитика', Icons.psychology_rounded, AppColors.amber),
      _KpiItem(
        '1:1',
        'персональные тренировки',
        Icons.bolt_rounded,
        AppColors.neonSoft,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 980
            ? 4
            : constraints.maxWidth > 560
            ? 2
            : 1;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns == 1 ? 3.8 : 2.25,
          children: [for (final item in items) _KpiCard(item: item)],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.item});

  final _KpiItem item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: item.color.withValues(alpha: 0.34),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: item.color.withValues(alpha: 0.28)),
            ),
            child: Icon(item.icon, color: item.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.value,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w800,
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

class _ProductModules extends StatelessWidget {
  const _ProductModules({required this.accountController});

  final TextEditingController accountController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Рабочие модули',
          subtitle:
              'Каждый блок ведёт в продуктовую зону, а не в промо-страницу.',
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 900 ? 2 : 1;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: columns == 2 ? 1.8 : 1.62,
              children: [
                _ModuleCard(
                  title: 'CS2 Utility Database',
                  subtitle: 'Гранаты, карты, траектории и тактические позиции.',
                  imageUrl: '/assets/gamementor/home/cs2-card.jpg',
                  badges: const ['smokes', 'flashes', 'positions'],
                  icon: Icons.track_changes_rounded,
                  color: AppColors.cyan,
                  onTap: () => context.go('/cs2'),
                ),
                _ModuleCard(
                  title: 'Dota 2 Player Analytics',
                  subtitle:
                      'Матчи, графики, профиль, герои и показатели формы.',
                  imageUrl: '/assets/gamementor/home/dota-card.jpg',
                  badges: const ['winrate', 'KDA', 'hero pool'],
                  icon: Icons.query_stats_rounded,
                  color: AppColors.neon,
                  onTap: () => _openDota(context, accountController.text),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.badges,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final List<String> badges;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderColor: color.withValues(alpha: 0.34),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: AppNetworkImage(imageUrl: imageUrl)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.black.withValues(alpha: 0.74),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.58),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Icon(icon, color: color),
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final badge in badges)
                      AppBadge(label: badge, color: color, compact: true),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    height: 1.4,
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

class _Cs2MapShowcase extends StatelessWidget {
  const _Cs2MapShowcase();

  @override
  Widget build(BuildContext context) {
    const maps = [
      ('Mirage', '/assets/gamementor/cs2/maps/mirage.jpg', 'mid / A execute'),
      ('Inferno', '/assets/gamementor/cs2/maps/inferno.jpg', 'banana control'),
      ('Nuke', '/assets/gamementor/cs2/maps/nuke.jpg', 'outside utility'),
      ('Anubis', '/assets/gamementor/cs2/maps/anubis.jpg', 'B main punish'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'CS2: карты и тактические позиции',
          subtitle:
              'Изображения показывают конкретную карту и контекст utility.',
          trailing: TextButton.icon(
            onPressed: () => context.go('/cs2'),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Все гранаты'),
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 1040
                ? 4
                : constraints.maxWidth > 640
                ? 2
                : 1;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 1 ? 2.7 : 1.55,
              children: [
                for (final map in maps)
                  _MapPreviewCard(
                    title: map.$1,
                    imageUrl: map.$2,
                    label: map.$3,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard({
    required this.title,
    required this.imageUrl,
    required this.label,
  });

  final String title;
  final String imageUrl;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => context.go('/cs2'),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(imageUrl: imageUrl),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.64),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.map_rounded,
                    color: AppColors.neon,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotaQuickPanel extends StatelessWidget {
  const _DotaQuickPanel({required this.accountController});

  final TextEditingController accountController;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final copy = const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBadge(
                icon: Icons.query_stats_rounded,
                label: 'Dota 2 analytics',
              ),
              SizedBox(height: 14),
              Text(
                'Подключение OpenDota уже заложено в продуктовый поток',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 8),
              Text(
                'Введи account ID, получи матчи, графики, пул героев и рекомендации. В live-режиме backend заменит mock-данные без смены UI.',
                style: AppTypography.bodyMuted,
              ),
            ],
          );
          final form = _HeroActions(accountController: accountController);

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 18), form],
            );
          }

          return Row(
            children: [
              Expanded(flex: 6, child: copy),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: form),
            ],
          );
        },
      ),
    );
  }
}

class _KpiItem {
  const _KpiItem(this.value, this.label, this.icon, this.color);

  final String value;
  final String label;
  final IconData icon;
  final Color color;
}

void _openDota(BuildContext context, String rawAccountId) {
  final value = rawAccountId.trim();
  context.go(value.isEmpty ? '/dota' : '/dota?account_id=$value');
}

const _previewHeroes = [
  'https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota_react/heroes/sniper.png',
  'https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota_react/heroes/juggernaut.png',
  'https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota_react/heroes/invoker.png',
];
