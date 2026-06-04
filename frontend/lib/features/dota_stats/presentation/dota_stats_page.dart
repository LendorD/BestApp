import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/section_header.dart';
import '../data/dota_stats_providers.dart';
import '../domain/dota_heroes.dart';
import '../domain/dota_models.dart';

class DotaStatsPage extends ConsumerStatefulWidget {
  const DotaStatsPage({super.key, this.initialAccountId});

  final String? initialAccountId;

  @override
  ConsumerState<DotaStatsPage> createState() => _DotaStatsPageState();
}

class _DotaStatsPageState extends ConsumerState<DotaStatsPage> {
  late final TextEditingController _controller;
  DotaStatsPeriod _period = DotaStatsPeriod.month;
  _DotaRole _role = _DotaRole.all;
  int? _currentAccountId;
  final Set<String> _enabledPros = {'yatoro', 'nisha', 'save'};

  @override
  void initState() {
    super.initState();
    final accountId = widget.initialAccountId ?? AppConfig.defaultDotaAccountId;
    _controller = TextEditingController(text: accountId);
    final parsed = int.tryParse(accountId);
    if (parsed != null) {
      Future.microtask(() {
        _setAnalysisQuery(parsed);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyze() {
    final accountId = int.tryParse(_controller.text.trim());
    if (accountId == null || accountId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректный OpenDota account ID')),
      );
      return;
    }
    _setAnalysisQuery(accountId);
  }

  void _setAnalysisQuery(int accountId) {
    _currentAccountId = accountId;
    ref.read(dotaAccountIdProvider.notifier).state = accountId;
    ref.read(dotaAnalysisQueryProvider.notifier).state = DotaAnalysisQuery(
      accountId: accountId,
      period: _period.apiValue,
      role: _role.apiValue,
    );
  }

  void _setPeriod(DotaStatsPeriod period) {
    setState(() => _period = period);
    final accountId = _currentAccountId;
    if (accountId != null) {
      _setAnalysisQuery(accountId);
    }
  }

  void _setRole(_DotaRole role) {
    setState(() => _role = role);
    final accountId = _currentAccountId;
    if (accountId != null) {
      _setAnalysisQuery(accountId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysis = ref.watch(dotaAnalysisProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DotaLabHeader(controller: _controller, onAnalyze: _analyze),
        const SizedBox(height: 18),
        analysis.when(
          data: (data) {
            if (data == null) {
              return const EmptyState(
                title: 'Dota Lab готов к анализу',
                message:
                    'Введи OpenDota account ID, чтобы увидеть GameMentor Score, сравнение с pro, героев, слабые места и AI Coach.',
                icon: Icons.query_stats_rounded,
              );
            }

            final roleMatches = _matchesByRole(data.matches, _role);
            final stats = DotaComputedStats.fromMatches(roleMatches, _period);

            return _DotaDashboard(
              analysis: data,
              stats: stats,
              allMatches: data.matches,
              period: _period,
              role: _role,
              enabledPros: _enabledPros,
              onPeriodChanged: _setPeriod,
              onRoleChanged: _setRole,
              onProToggled: (id, enabled) {
                setState(() {
                  if (enabled) {
                    _enabledPros.add(id);
                  } else {
                    _enabledPros.remove(id);
                  }
                });
              },
            );
          },
          loading: () => const LoadingState(rows: 8),
          error: (error, _) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(dotaAnalysisProvider),
          ),
        ),
      ],
    );
  }
}

class _DotaLabHeader extends StatelessWidget {
  const _DotaLabHeader({required this.controller, required this.onAnalyze});

  final TextEditingController controller;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hoverLift: false,
      radius: 8,
      borderColor: AppColors.borderStrong,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 860;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const AppBadge(
                    icon: Icons.analytics_rounded,
                    label: 'Dota Lab',
                  ),
                  AppBadge(
                    icon: AppConfig.useMockApi
                        ? Icons.bolt_rounded
                        : Icons.cloud_sync_rounded,
                    label: AppConfig.useMockApi
                        ? 'Демо-данные'
                        : 'OpenDota API',
                    color: AppColors.amber,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Аналитический центр игрока',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.02,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Оцени форму, сравни себя с pro-игроками и получи план роста MMR на основе последних матчей.',
                style: AppTypography.bodyMuted,
              ),
            ],
          );

          final form = _AccountForm(
            controller: controller,
            onAnalyze: onAnalyze,
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 18), form],
            );
          }

          return Row(
            children: [
              Expanded(flex: 6, child: copy),
              const SizedBox(width: 28),
              Expanded(flex: 5, child: form),
            ],
          );
        },
      ),
    );
  }
}

class _AccountForm extends StatelessWidget {
  const _AccountForm({required this.controller, required this.onAnalyze});

  final TextEditingController controller;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.black.withValues(alpha: 0.34),
      borderColor: AppColors.border,
      hoverLift: false,
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;
          final input = TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'OpenDota account ID',
              prefixIcon: Icon(Icons.tag_rounded),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            onSubmitted: (_) => onAnalyze(),
          );
          final button = ElevatedButton.icon(
            onPressed: onAnalyze,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Анализировать'),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [input, const SizedBox(height: 10), button],
            );
          }

          return Row(
            children: [
              Expanded(child: input),
              const SizedBox(width: 10),
              button,
            ],
          );
        },
      ),
    );
  }
}

class _DotaDashboard extends StatelessWidget {
  const _DotaDashboard({
    required this.analysis,
    required this.stats,
    required this.allMatches,
    required this.period,
    required this.role,
    required this.enabledPros,
    required this.onPeriodChanged,
    required this.onRoleChanged,
    required this.onProToggled,
  });

  final DotaAnalysis analysis;
  final DotaComputedStats stats;
  final List<DotaMatch> allMatches;
  final DotaStatsPeriod period;
  final _DotaRole role;
  final Set<String> enabledPros;
  final ValueChanged<DotaStatsPeriod> onPeriodChanged;
  final ValueChanged<_DotaRole> onRoleChanged;
  final void Function(String id, bool enabled) onProToggled;

  @override
  Widget build(BuildContext context) {
    final favoriteRole = _favoriteRole(allMatches);
    final score = _PerformanceBreakdown.fromStats(stats);
    final heroPerformance = _heroPerformance(stats.filteredMatches);
    final bestHeroes = heroPerformance.take(5).toList();
    final problemHeroes = heroPerformance
        .where((hero) => hero.matches >= 2 && hero.winrate < 50)
        .take(4)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PlayerHeader(
          player: analysis.player,
          stats: stats,
          favoriteRole: favoriteRole,
        ),
        const SizedBox(height: 14),
        _ControlsBar(
          period: period,
          role: role,
          onPeriodChanged: onPeriodChanged,
          onRoleChanged: onRoleChanged,
        ),
        const SizedBox(height: 14),
        _HeroGraphGrid(
          bestHeroes: bestHeroes,
          problemHeroes: problemHeroes,
          stats: stats,
          enabledPros: enabledPros,
          onProToggled: onProToggled,
        ),
        const SizedBox(height: 14),
        _ScoreAndMatchReview(score: score, stats: stats),
        const SizedBox(height: 14),
        _HeroRecommendationsCard(best: bestHeroes, problem: problemHeroes),
        const SizedBox(height: 14),
        _TimelineAndWeaknesses(stats: stats),
        const SizedBox(height: 14),
        _CoachAndPlan(stats: stats, bestHeroes: bestHeroes),
        const SizedBox(height: 14),
        _MatchesTable(matches: stats.filteredMatches),
      ],
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({
    required this.player,
    required this.stats,
    required this.favoriteRole,
  });

  final DotaPlayer player;
  final DotaComputedStats stats;
  final _DotaRole favoriteRole;

  @override
  Widget build(BuildContext context) {
    final rank = rankLabel(player.rankTier);
    final form = _formLabel(stats);

    return AppCard(
      hoverLift: false,
      borderColor: AppColors.borderStrong,
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 780;
          final identity = Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AppNetworkImage(
                  imageUrl: player.avatarFull.isEmpty
                      ? '/assets/gamementor/dota/profile-fallback.jpg'
                      : player.avatarFull,
                  width: 78,
                  height: 78,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.personaName.isEmpty
                          ? 'Игрок ${player.accountId}'
                          : player.personaName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ID ${player.accountId} · ${stats.period.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          );

          final metrics = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeaderMetric('Ранг', rank, Icons.military_tech_rounded),
              _HeaderMetric(
                'Винрейт',
                '${stats.winrate.toStringAsFixed(1)}%',
                Icons.percent_rounded,
              ),
              _HeaderMetric(
                'Роль',
                favoriteRole.shortLabel,
                Icons.sports_esports_rounded,
              ),
              _HeaderMetric(
                'Матчи',
                stats.matches.toString(),
                Icons.format_list_numbered_rounded,
              ),
              _HeaderMetric('Форма', form.label, form.icon, color: form.color),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [identity, const SizedBox(height: 16), metrics],
            );
          }

          return Row(
            children: [
              Expanded(flex: 4, child: identity),
              const SizedBox(width: 18),
              Expanded(flex: 6, child: metrics),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric(
    this.label,
    this.value,
    this.icon, {
    this.color = AppColors.neon,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.label),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({
    required this.period,
    required this.role,
    required this.onPeriodChanged,
    required this.onRoleChanged,
  });

  final DotaStatsPeriod period;
  final _DotaRole role;
  final ValueChanged<DotaStatsPeriod> onPeriodChanged;
  final ValueChanged<_DotaRole> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hoverLift: false,
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 960;
          final periods = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in DotaStatsPeriod.values)
                ChoiceChip(
                  selected: period == item,
                  label: Text(item.label),
                  onSelected: (_) => onPeriodChanged(item),
                ),
            ],
          );
          final roles = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<_DotaRole>(
              showSelectedIcon: false,
              segments: [
                for (final item in _DotaRole.values)
                  ButtonSegment(value: item, label: Text(item.label)),
              ],
              selected: {role},
              onSelectionChanged: (values) {
                if (values.isNotEmpty) {
                  onRoleChanged(values.first);
                }
              },
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ControlTitle('Период'),
                const SizedBox(height: 8),
                periods,
                const SizedBox(height: 14),
                const _ControlTitle('Роль'),
                const SizedBox(height: 8),
                roles,
              ],
            );
          }

          return Row(
            children: [
              const _ControlTitle('Период'),
              const SizedBox(width: 12),
              Expanded(child: periods),
              const SizedBox(width: 18),
              const _ControlTitle('Роль'),
              const SizedBox(width: 12),
              Expanded(child: roles),
            ],
          );
        },
      ),
    );
  }
}

class _ControlTitle extends StatelessWidget {
  const _ControlTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.muted,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _HeroGraphGrid extends StatelessWidget {
  const _HeroGraphGrid({
    required this.bestHeroes,
    required this.problemHeroes,
    required this.stats,
    required this.enabledPros,
    required this.onProToggled,
  });

  final List<_HeroPerformance> bestHeroes;
  final List<_HeroPerformance> problemHeroes;
  final DotaComputedStats stats;
  final Set<String> enabledPros;
  final void Function(String id, bool enabled) onProToggled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1120;
        final heroes = _HeroSpotlightCard(
          bestHeroes: bestHeroes,
          problemHeroes: problemHeroes,
        );
        final graph = _ProComparisonCard(
          stats: stats,
          enabledPros: enabledPros,
          onProToggled: onProToggled,
        );

        if (!wide) {
          return Column(children: [heroes, const SizedBox(height: 14), graph]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: heroes),
            const SizedBox(width: 14),
            Expanded(flex: 7, child: graph),
          ],
        );
      },
    );
  }
}

class _HeroSpotlightCard extends StatelessWidget {
  const _HeroSpotlightCard({
    required this.bestHeroes,
    required this.problemHeroes,
  });

  final List<_HeroPerformance> bestHeroes;
  final List<_HeroPerformance> problemHeroes;

  @override
  Widget build(BuildContext context) {
    final heroes = bestHeroes.take(4).toList();
    return AppCard(
      hoverLift: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Лучшие герои',
            subtitle: 'Твой рабочий hero pool в выбранном периоде.',
          ),
          const SizedBox(height: 16),
          if (heroes.isEmpty)
            const Text(
              'В выбранном периоде пока нет героев.',
              style: AppTypography.bodyMuted,
            )
          else
            Column(
              children: [
                for (var i = 0; i < heroes.length; i++)
                  _HeroTiltCard(hero: heroes[i], index: i),
              ],
            ),
          const SizedBox(height: 14),
          _HeroPoolHint(best: bestHeroes, problem: problemHeroes),
        ],
      ),
    );
  }
}

class _HeroTiltCard extends StatefulWidget {
  const _HeroTiltCard({required this.hero, required this.index});

  final _HeroPerformance hero;
  final int index;

  @override
  State<_HeroTiltCard> createState() => _HeroTiltCardState();
}

class _HeroTiltCardState extends State<_HeroTiltCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hero = widget.hero;
    final info = heroInfoById(hero.heroId);
    final angle = widget.index.isEven ? -0.025 : 0.025;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.025 : 1,
        duration: const Duration(milliseconds: 160),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(_hovered ? -angle * 2 : angle),
          child: Container(
            height: 116,
            margin: const EdgeInsets.only(bottom: 12),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              border: Border.all(
                color: _hovered
                    ? AppColors.dotaAccent.withValues(alpha: 0.7)
                    : AppColors.border,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AppNetworkImage(
                    imageUrl: info?.cardUrl ?? '',
                    fallbackImageUrl: '/assets/gamementor/home/dota-card.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
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
                          AppColors.black.withValues(alpha: 0.58),
                          AppColors.black.withValues(alpha: 0.18),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              info?.nameRu ?? 'Герой ${hero.heroId}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${hero.matches} матчей · KDA ${hero.kda.toStringAsFixed(2)} · GPM ${hero.gpm.toStringAsFixed(0)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSoft,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.72),
                          border: Border.all(
                            color: AppColors.dotaAccent.withValues(alpha: 0.6),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${hero.winrate.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: AppColors.dotaAccent,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPoolHint extends StatelessWidget {
  const _HeroPoolHint({required this.best, required this.problem});

  final List<_HeroPerformance> best;
  final List<_HeroPerformance> problem;

  @override
  Widget build(BuildContext context) {
    final bestNames = best
        .take(3)
        .map(
          (hero) => heroInfoById(hero.heroId)?.nameRu ?? 'герой ${hero.heroId}',
        )
        .join(', ');
    final problemName = problem.isEmpty
        ? 'героев с явной просадкой пока нет'
        : 'убери на неделю ${heroInfoById(problem.first.heroId)?.nameRu ?? 'героя ${problem.first.heroId}'}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.3),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        bestNames.isEmpty
            ? 'Сыграй больше матчей, чтобы собрать уверенный hero pool.'
            : 'Фокус пула: $bestNames. Рекомендация: $problemName.',
        style: AppTypography.bodyMuted,
      ),
    );
  }
}

class _ScoreAndMatchReview extends StatelessWidget {
  const _ScoreAndMatchReview({required this.score, required this.stats});

  final _PerformanceBreakdown score;
  final DotaComputedStats stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final scoreCard = _PerformanceScoreCard(score: score);
        final review = _MatchReviewTeaser(stats: stats);
        if (!wide) {
          return Column(
            children: [scoreCard, const SizedBox(height: 14), review],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: scoreCard),
            const SizedBox(width: 14),
            Expanded(flex: 6, child: review),
          ],
        );
      },
    );
  }
}

class _MatchReviewTeaser extends StatelessWidget {
  const _MatchReviewTeaser({required this.stats});

  final DotaComputedStats stats;

  @override
  Widget build(BuildContext context) {
    final target = stats.filteredMatches.firstWhere(
      (match) => !match.won,
      orElse: () => stats.filteredMatches.isEmpty
          ? DotaMatch(
              matchId: 0,
              accountId: 0,
              playerSlot: 0,
              radiantWin: false,
              won: false,
              heroId: 0,
              kills: 0,
              deaths: 0,
              assists: 0,
              durationSeconds: 0,
              startTime: DateTime.now(),
            )
          : stats.filteredMatches.first,
    );
    final hero = heroInfoById(target.heroId);
    return AppCard(
      hoverLift: false,
      borderColor: AppColors.cyan.withValues(alpha: 0.42),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Разбор матча',
            subtitle: 'Быстрый teaser будущего Match Insights.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroAvatar(heroId: target.heroId),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  target.matchId == 0
                      ? 'Пока нет матча для разбора'
                      : 'Матч ${target.matchId} · ${hero?.nameRu ?? 'герой ${target.heroId}'} · ${target.kills}/${target.deaths}/${target.assists}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _matchReviewSummary(target, stats),
            style: AppTypography.bodyMuted,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => _openMatchReviewStub(context, target),
                icon: const Icon(Icons.manage_search_rounded),
                label: const Text('Проанализировать матч'),
              ),
              OutlinedButton.icon(
                onPressed: () => _openAiReport(context, stats),
                icon: const Icon(Icons.psychology_alt_rounded),
                label: const Text('Добавить в AI-отчёт'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroRecommendationsCard extends StatelessWidget {
  const _HeroRecommendationsCard({required this.best, required this.problem});

  final List<_HeroPerformance> best;
  final List<_HeroPerformance> problem;

  @override
  Widget build(BuildContext context) {
    final main = best.take(3).toList();
    final remove = problem.take(2).toList();

    return AppCard(
      hoverLift: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Рекомендации по героям',
            subtitle:
                'Кого оставить в пуле, кого тренировать и кого убрать на неделю.',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final left = _HeroRecommendationColumn(
                title: 'Основной пул',
                icon: Icons.check_circle_rounded,
                color: AppColors.dotaAccent,
                heroes: main,
                emptyText: 'Нужно больше матчей для уверенного пула.',
              );
              final right = _HeroRecommendationColumn(
                title: 'Убрать / пересмотреть',
                icon: Icons.warning_rounded,
                color: AppColors.red,
                heroes: remove,
                emptyText: 'Критичных просадок пока не видно.',
              );
              if (!wide) {
                return Column(
                  children: [left, const SizedBox(height: 12), right],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 12),
                  Expanded(child: right),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroRecommendationColumn extends StatelessWidget {
  const _HeroRecommendationColumn({
    required this.title,
    required this.icon,
    required this.color,
    required this.heroes,
    required this.emptyText,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<_HeroPerformance> heroes;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.24),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 19),
              const SizedBox(width: 9),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          if (heroes.isEmpty)
            Text(emptyText, style: AppTypography.bodyMuted)
          else
            for (final hero in heroes)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    _HeroAvatar(heroId: hero.heroId),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        heroInfoById(hero.heroId)?.nameRu ??
                            'Герой ${hero.heroId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      '${hero.winrate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
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

class _PerformanceScoreCard extends StatelessWidget {
  const _PerformanceScoreCard({required this.score});

  final _PerformanceBreakdown score;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hoverLift: false,
      borderColor: _scoreColor(score.total).withValues(alpha: 0.44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'GameMentor Score',
            subtitle: 'Единая оценка формы от 0 до 100.',
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 126,
                height: 126,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: score.total / 100,
                      strokeWidth: 10,
                      backgroundColor: AppColors.border,
                      color: _scoreColor(score.total),
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            score.total.toString(),
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const Text('/ 100', style: AppTypography.label),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  children: [
                    _ScoreRow('Фарм', score.farm),
                    _ScoreRow('Драки', score.fights),
                    _ScoreRow('Объекты', score.objectives),
                    _ScoreRow('Стабильность', score.stability),
                    _ScoreRow('Командная игра', score.teamplay),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                value.toString(),
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 6,
              backgroundColor: AppColors.border,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProComparisonCard extends StatelessWidget {
  const _ProComparisonCard({
    required this.stats,
    required this.enabledPros,
    required this.onProToggled,
  });

  final DotaComputedStats stats;
  final Set<String> enabledPros;
  final void Function(String id, bool enabled) onProToggled;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hoverLift: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Сравнение с pro-игроками',
            subtitle:
                'Нормализованный график по GPM, XPM, KDA, винрейту, урону и объектам.',
            trailing: AppBadge(
              icon: Icons.stacked_line_chart_rounded,
              label: 'fl_chart',
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final pro in _proProfiles)
                FilterChip(
                  selected: enabledPros.contains(pro.id),
                  label: Text(pro.name),
                  avatar: Icon(Icons.circle, color: pro.color, size: 13),
                  onSelected: (value) => onProToggled(pro.id, value),
                ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 330,
            child: _ProComparisonChart(stats: stats, enabledPros: enabledPros),
          ),
        ],
      ),
    );
  }
}

class _ProComparisonChart extends StatelessWidget {
  const _ProComparisonChart({required this.stats, required this.enabledPros});

  final DotaComputedStats stats;
  final Set<String> enabledPros;

  @override
  Widget build(BuildContext context) {
    final series = [
      _ProfileSeries.player(stats),
      for (final pro in _proProfiles)
        if (enabledPros.contains(pro.id)) _ProfileSeries.pro(pro),
    ];

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        minX: 0,
        maxX: (_comparisonMetrics.length - 1).toDouble(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.border.withValues(alpha: 0.72),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.border),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 38,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= _comparisonMetrics.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 10,
                  angle: -0.42,
                  child: Text(
                    _comparisonMetrics[index].shortLabel,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surfaceAlt,
            tooltipBorder: BorderSide(color: AppColors.borderStrong),
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final metricIndex = spot.x.round().clamp(
                  0,
                  _comparisonMetrics.length - 1,
                );
                final metric = _comparisonMetrics[metricIndex];
                final item = series[spot.barIndex];
                final raw = item.values[metric.key] ?? 0;
                return LineTooltipItem(
                  '${item.name}\n${metric.shortLabel}: ${metric.format(raw)}',
                  TextStyle(color: item.color, fontWeight: FontWeight.w900),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          for (final item in series)
            LineChartBarData(
              spots: [
                for (var i = 0; i < _comparisonMetrics.length; i++)
                  FlSpot(
                    i.toDouble(),
                    _comparisonMetrics[i].normalize(
                      item.values[_comparisonMetrics[i].key] ?? 0,
                    ),
                  ),
              ],
              isCurved: true,
              curveSmoothness: 0.28,
              preventCurveOverShooting: true,
              barWidth: item.isPlayer ? 3.2 : 2.2,
              color: item.color,
              isStrokeCapRound: true,
              isStrokeJoinRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: item.isPlayer ? 4 : 3,
                    color: AppColors.background,
                    strokeColor: item.color,
                    strokeWidth: item.isPlayer ? 2.4 : 1.8,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: item.isPlayer,
                color: item.color.withValues(alpha: 0.08),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineAndWeaknesses extends StatelessWidget {
  const _TimelineAndWeaknesses({required this.stats});

  final DotaComputedStats stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        final timeline = _FormTimelineCard(matches: stats.filteredMatches);
        final weaknesses = _WeaknessesCard(stats: stats);

        if (!wide) {
          return Column(
            children: [timeline, const SizedBox(height: 14), weaknesses],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: timeline),
            const SizedBox(width: 14),
            Expanded(flex: 4, child: weaknesses),
          ],
        );
      },
    );
  }
}

class _FormTimelineCard extends StatelessWidget {
  const _FormTimelineCard({required this.matches});

  final List<DotaMatch> matches;

  @override
  Widget build(BuildContext context) {
    final sample = matches.take(50).toList().reversed.toList();

    return AppCard(
      hoverLift: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Form Timeline',
            subtitle:
                'Последние 50 матчей: рост формы, победы, поражения, пики и просадки.',
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 290,
            child: sample.isEmpty
                ? const Center(
                    child: Text(
                      'Нет матчей для графика',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : _FormTimelineChart(matches: sample),
          ),
        ],
      ),
    );
  }
}

class _FormTimelineChart extends StatelessWidget {
  const _FormTimelineChart({required this.matches});

  final List<DotaMatch> matches;

  @override
  Widget build(BuildContext context) {
    final scores = [for (final match in matches) _matchFormScore(match)];
    final peak = scores.reduce((a, b) => a > b ? a : b);
    final low = scores.reduce((a, b) => a < b ? a : b);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        minX: 0,
        maxX: (matches.length - 1).toDouble(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.border.withValues(alpha: 0.72),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.border),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 38,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: matches.length <= 12 ? 2 : 8,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                  '#${value.toInt() + 1}',
                  style: const TextStyle(
                    color: AppColors.mutedDeep,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surfaceAlt,
            tooltipBorder: BorderSide(color: AppColors.borderStrong),
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final index = spot.x.round().clamp(0, matches.length - 1);
                final match = matches[index];
                final result = match.won ? 'Победа' : 'Поражение';
                return LineTooltipItem(
                  '$result\n${spot.y.toStringAsFixed(0)} form · ${match.kills}/${match.deaths}/${match.assists}',
                  TextStyle(
                    color: match.won ? AppColors.neon : AppColors.red,
                    fontWeight: FontWeight.w900,
                  ),
                );
              }).toList();
            },
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: peak,
              color: AppColors.neon.withValues(alpha: 0.24),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
            HorizontalLine(
              y: low,
              color: AppColors.red.withValues(alpha: 0.24),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < scores.length; i++)
                FlSpot(i.toDouble(), scores[i]),
            ],
            isCurved: true,
            curveSmoothness: 0.28,
            preventCurveOverShooting: true,
            barWidth: 3,
            color: AppColors.neon,
            isStrokeCapRound: true,
            isStrokeJoinRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                final won = matches[index].won;
                return FlDotCirclePainter(
                  radius: won ? 3.8 : 3.4,
                  color: AppColors.background,
                  strokeColor: won ? AppColors.neon : AppColors.red,
                  strokeWidth: 2,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.neon.withValues(alpha: 0.07),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeaknessesCard extends StatelessWidget {
  const _WeaknessesCard({required this.stats});

  final DotaComputedStats stats;

  @override
  Widget build(BuildContext context) {
    final items = _weaknessesFor(stats);
    return AppCard(
      hoverLift: false,
      borderColor: AppColors.red.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Слабые стороны',
            subtitle: 'Что сильнее всего мешает росту рейтинга.',
          ),
          const SizedBox(height: 16),
          for (final item in items)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item, style: const TextStyle(height: 1.4)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CoachAndPlan extends StatelessWidget {
  const _CoachAndPlan({required this.stats, required this.bestHeroes});

  final DotaComputedStats stats;
  final List<_HeroPerformance> bestHeroes;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1080;
        final coach = _AICoachCard(stats: stats);
        final plan = _TrainingPlanCard(bestHeroes: bestHeroes);

        if (!wide) {
          return Column(children: [coach, const SizedBox(height: 14), plan]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: coach),
            const SizedBox(width: 14),
            Expanded(flex: 5, child: plan),
          ],
        );
      },
    );
  }
}

class _AICoachCard extends StatelessWidget {
  const _AICoachCard({required this.stats});

  final DotaComputedStats stats;

  @override
  Widget build(BuildContext context) {
    final mainProblem = _mainProblem(stats);
    return AppCard(
      hoverLift: false,
      borderColor: AppColors.amber.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppBadge(
            icon: Icons.psychology_alt_rounded,
            label: 'AI Coach · первый прогон 0 ₽',
            color: AppColors.amber,
          ),
          const SizedBox(height: 14),
          const Text(
            'Твой персональный тренер',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'После анализа последних матчей обнаружено: $mainProblem Из-за этого может теряться примерно 6-8% винрейта.',
            style: AppTypography.bodyMuted,
          ),
          const SizedBox(height: 18),
          _ReportPreview(stats: stats),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => _openAiReport(context, stats),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('0 ₽ AI-прогон'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _openPaymentStub(context),
                icon: const Icon(Icons.credit_card_rounded),
                label: const Text('Premium позже'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportPreview extends StatelessWidget {
  const _ReportPreview({required this.stats});

  final DotaComputedStats stats;

  @override
  Widget build(BuildContext context) {
    final errors = stats.averageDeaths > 6 ? 5 : 3;
    final strengths = stats.skillScore >= 55 ? 3 : 2;
    final recommendations = stats.winrate < 50 ? 5 : 4;
    final items = [
      ('Сильные стороны', strengths.toString()),
      ('Ошибки', errors.toString()),
      ('Рекомендации', recommendations.toString()),
      ('План тренировок', '1'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.35,
      children: [
        for (final item in items)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.26),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Text(
                  item.$2,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.$1,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TrainingPlanCard extends StatelessWidget {
  const _TrainingPlanCard({required this.bestHeroes});

  final List<_HeroPerformance> bestHeroes;

  @override
  Widget build(BuildContext context) {
    final mainHero = bestHeroes.isEmpty
        ? 'основном герое'
        : heroInfoById(bestHeroes.first.heroId)?.nameRu ?? 'основном герое';
    final plan = [
      ('Понедельник', '2 игры на $mainHero'),
      ('Вторник', 'Разбор одного проигранного реплея'),
      ('Среда', 'Тренировка лейнинга и первых 10 минут'),
      ('Четверг', '3 рейтинговые игры с тем же пулом'),
      ('Пятница', 'Проверка объектов после выигранных драк'),
    ];

    return AppCard(
      hoverLift: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Training Plan',
            subtitle: 'Автоматический план на неделю №1.',
          ),
          const SizedBox(height: 16),
          for (final item in plan)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: Text(
                      item.$1,
                      style: const TextStyle(
                        color: AppColors.neon,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(child: Text(item.$2)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MatchesTable extends StatelessWidget {
  const _MatchesTable({required this.matches});

  final List<DotaMatch> matches;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM');
    return AppCard(
      hoverLift: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Матчи в выбранном срезе',
            subtitle:
                'Сырые данные остаются под рукой для ручной проверки анализа.',
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Матч')),
                DataColumn(label: Text('Результат')),
                DataColumn(label: Text('Герой')),
                DataColumn(label: Text('K/D/A')),
                DataColumn(label: Text('GPM/XPM')),
                DataColumn(label: Text('LH')),
                DataColumn(label: Text('Урон')),
                DataColumn(label: Text('Объекты')),
                DataColumn(label: Text('Дата')),
              ],
              rows: [
                for (final match in matches.take(20))
                  DataRow(
                    cells: [
                      DataCell(Text(match.matchId.toString())),
                      DataCell(
                        Text(
                          match.won ? 'Победа' : 'Поражение',
                          style: TextStyle(
                            color: match.won ? AppColors.neon : AppColors.red,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _HeroAvatar(heroId: match.heroId),
                            const SizedBox(width: 8),
                            Text(
                              heroInfoById(match.heroId)?.nameRu ??
                                  'Герой ${match.heroId}',
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text('${match.kills}/${match.deaths}/${match.assists}'),
                      ),
                      DataCell(Text('${match.goldPerMin}/${match.xpPerMin}')),
                      DataCell(Text(match.lastHits.toString())),
                      DataCell(Text(match.heroDamage.toString())),
                      DataCell(Text(match.towerDamage.toString())),
                      DataCell(Text(dateFormat.format(match.startTime))),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroAvatar extends StatelessWidget {
  const _HeroAvatar({required this.heroId});

  final int heroId;

  @override
  Widget build(BuildContext context) {
    final hero = heroInfoById(heroId);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 34,
        height: 34,
        child: AppNetworkImage(
          imageUrl: hero?.imageUrl ?? '',
          fallbackImageUrl: '/assets/gamementor/home/dota-card.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

enum _DotaRole {
  all('Все роли', 'All'),
  carry('Carry', 'Pos 1 Carry'),
  mid('Mid', 'Pos 2 Mid'),
  offlane('Offlane', 'Pos 3 Offlane'),
  support4('Support 4', 'Pos 4 Support'),
  support5('Support 5', 'Pos 5 Support');

  const _DotaRole(this.label, this.shortLabel);

  final String label;
  final String shortLabel;

  String get apiValue => switch (this) {
    _DotaRole.all => 'all',
    _DotaRole.carry => 'carry',
    _DotaRole.mid => 'mid',
    _DotaRole.offlane => 'offlane',
    _DotaRole.support4 => 'support4',
    _DotaRole.support5 => 'support5',
  };
}

class _PerformanceBreakdown {
  const _PerformanceBreakdown({
    required this.total,
    required this.farm,
    required this.fights,
    required this.objectives,
    required this.stability,
    required this.teamplay,
  });

  final int total;
  final int farm;
  final int fights;
  final int objectives;
  final int stability;
  final int teamplay;

  factory _PerformanceBreakdown.fromStats(DotaComputedStats stats) {
    final farm = _scoreClamp(
      _normalize(stats.averageGpm, 320, 760) * 56 +
          _normalize(stats.averageXpm, 380, 860) * 34 +
          _normalize(stats.averageLastHits, 70, 310) * 10,
    );
    final fights = _scoreClamp(
      _normalize(stats.kda, 1, 6.5) * 48 +
          _normalize(stats.averageKills, 2, 13) * 24 +
          _normalize(stats.averageHeroDamage, 7000, 36000) * 28,
    );
    final objectives = _scoreClamp(
      _normalize(stats.averageTowerDamage, 250, 5000) * 78 +
          _normalize(stats.winrate, 35, 70) * 22,
    );
    final stability = _scoreClamp(
      _normalize(stats.winrate, 35, 70) * 58 +
          _normalize(9 - stats.averageDeaths, 1, 8) * 42,
    );
    final teamplay = _scoreClamp(
      _normalize(stats.averageAssists, 5, 22) * 62 +
          _normalize(stats.averageHeroHealing, 0, 4200) * 18 +
          _normalize(stats.kda, 1, 6.5) * 20,
    );
    final total = _scoreClamp(
      farm * 0.22 +
          fights * 0.22 +
          objectives * 0.18 +
          stability * 0.22 +
          teamplay * 0.16,
    );
    return _PerformanceBreakdown(
      total: total,
      farm: farm,
      fights: fights,
      objectives: objectives,
      stability: stability,
      teamplay: teamplay,
    );
  }
}

class _HeroPerformance {
  const _HeroPerformance({
    required this.heroId,
    required this.matches,
    required this.wins,
    required this.winrate,
    required this.kda,
    required this.gpm,
  });

  final int heroId;
  final int matches;
  final int wins;
  final double winrate;
  final double kda;
  final double gpm;
}

class _ComparisonMetric {
  const _ComparisonMetric(
    this.key,
    this.shortLabel,
    this.maxValue, {
    this.minValue = 0,
    this.suffix = '',
    this.decimals = 0,
  });

  final String key;
  final String shortLabel;
  final double minValue;
  final double maxValue;
  final String suffix;
  final int decimals;

  double normalize(double value) => _normalize(value, minValue, maxValue) * 100;

  String format(double value) => '${value.toStringAsFixed(decimals)}$suffix';
}

class _ProProfile {
  const _ProProfile(this.id, this.name, this.color, this.values);

  final String id;
  final String name;
  final Color color;
  final Map<String, double> values;
}

class _ProfileSeries {
  const _ProfileSeries({
    required this.name,
    required this.color,
    required this.values,
    required this.isPlayer,
  });

  final String name;
  final Color color;
  final Map<String, double> values;
  final bool isPlayer;

  factory _ProfileSeries.player(DotaComputedStats stats) {
    return _ProfileSeries(
      name: 'Твой профиль',
      color: AppColors.neon,
      isPlayer: true,
      values: {
        'gpm': stats.averageGpm,
        'xpm': stats.averageXpm,
        'kda': stats.kda,
        'winrate': stats.winrate,
        'hero_damage': stats.averageHeroDamage,
        'tower_damage': stats.averageTowerDamage,
        'last_hits': stats.averageLastHits,
        'net_worth': stats.averageGpm * stats.averageDurationMinutes,
      },
    );
  }

  factory _ProfileSeries.pro(_ProProfile pro) {
    return _ProfileSeries(
      name: pro.name,
      color: pro.color,
      values: pro.values,
      isPlayer: false,
    );
  }
}

const _comparisonMetrics = [
  _ComparisonMetric('gpm', 'GPM', 820, minValue: 300),
  _ComparisonMetric('xpm', 'XPM', 920, minValue: 350),
  _ComparisonMetric('kda', 'KDA', 7, minValue: 1, decimals: 1),
  _ComparisonMetric('winrate', 'Winrate', 75, minValue: 35, suffix: '%'),
  _ComparisonMetric('hero_damage', 'Hero DMG', 42000, minValue: 7000),
  _ComparisonMetric('tower_damage', 'Tower DMG', 6000, minValue: 250),
  _ComparisonMetric('last_hits', 'LH', 360, minValue: 50),
  _ComparisonMetric('net_worth', 'Net Worth', 33000, minValue: 9000),
];

const _proProfiles = [
  _ProProfile('yatoro', 'Yatoro', AppColors.amber, {
    'gpm': 735,
    'xpm': 820,
    'kda': 5.4,
    'winrate': 63,
    'hero_damage': 31500,
    'tower_damage': 4100,
    'last_hits': 320,
    'net_worth': 29500,
  }),
  _ProProfile('nisha', 'Nisha', AppColors.cyan, {
    'gpm': 690,
    'xpm': 850,
    'kda': 5.8,
    'winrate': 61,
    'hero_damage': 34000,
    'tower_damage': 2600,
    'last_hits': 285,
    'net_worth': 28200,
  }),
  _ProProfile('save', 'Save', AppColors.red, {
    'gpm': 430,
    'xpm': 590,
    'kda': 4.6,
    'winrate': 62,
    'hero_damage': 17000,
    'tower_damage': 950,
    'last_hits': 75,
    'net_worth': 16800,
  }),
  _ProProfile('collapse', 'Collapse', Color(0xFF9B7BFF), {
    'gpm': 560,
    'xpm': 705,
    'kda': 4.8,
    'winrate': 60,
    'hero_damage': 26000,
    'tower_damage': 2200,
    'last_hits': 210,
    'net_worth': 23800,
  }),
  _ProProfile('mira', 'Mira', Color(0xFFFF8A3D), {
    'gpm': 395,
    'xpm': 565,
    'kda': 4.2,
    'winrate': 59,
    'hero_damage': 15500,
    'tower_damage': 800,
    'last_hits': 62,
    'net_worth': 15100,
  }),
  _ProProfile('pure', 'Pure', Color(0xFFB8D660), {
    'gpm': 710,
    'xpm': 810,
    'kda': 5.2,
    'winrate': 60,
    'hero_damage': 30500,
    'tower_damage': 3900,
    'last_hits': 310,
    'net_worth': 28900,
  }),
  _ProProfile('malr1ne', 'Malr1ne', Color(0xFFFF6BAA), {
    'gpm': 675,
    'xpm': 855,
    'kda': 5.1,
    'winrate': 60,
    'hero_damage': 36000,
    'tower_damage': 2100,
    'last_hits': 270,
    'net_worth': 27400,
  }),
];

const _carryHeroes = {1, 6, 8, 12, 35, 41, 44, 48, 54, 67, 70};
const _midHeroes = {10, 11, 13, 17, 22, 25, 34, 39, 46, 52, 74};
const _offlaneHeroes = {2, 16, 19, 29, 38, 49, 55, 60, 65, 69};
const _support4Heroes = {7, 9, 20, 27, 51, 62, 64, 71, 72};
const _support5Heroes = {3, 5, 26, 30, 31, 37, 50, 57, 58, 66, 68};

List<DotaMatch> _matchesByRole(List<DotaMatch> matches, _DotaRole role) {
  if (role == _DotaRole.all) return matches;
  return matches.where((match) => _roleForMatch(match) == role).toList();
}

_DotaRole _favoriteRole(List<DotaMatch> matches) {
  if (matches.isEmpty) return _DotaRole.all;
  final counts = <_DotaRole, int>{};
  for (final match in matches) {
    final role = _roleForMatch(match);
    counts[role] = (counts[role] ?? 0) + 1;
  }
  return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}

_DotaRole _roleForMatch(DotaMatch match) {
  if (_carryHeroes.contains(match.heroId)) return _DotaRole.carry;
  if (_midHeroes.contains(match.heroId)) return _DotaRole.mid;
  if (_offlaneHeroes.contains(match.heroId)) return _DotaRole.offlane;
  if (_support4Heroes.contains(match.heroId)) return _DotaRole.support4;
  if (_support5Heroes.contains(match.heroId)) return _DotaRole.support5;
  if (match.goldPerMin >= 560 || match.lastHits >= 230) return _DotaRole.carry;
  if (match.goldPerMin >= 500) return _DotaRole.mid;
  if (match.goldPerMin >= 430) return _DotaRole.offlane;
  return match.assists >= 14 ? _DotaRole.support5 : _DotaRole.support4;
}

List<_HeroPerformance> _heroPerformance(List<DotaMatch> matches) {
  final grouped = <int, List<DotaMatch>>{};
  for (final match in matches) {
    grouped.putIfAbsent(match.heroId, () => []).add(match);
  }

  final heroes = grouped.entries.map((entry) {
    final heroMatches = entry.value;
    final wins = heroMatches.where((match) => match.won).length;
    final kills = heroMatches.fold<int>(0, (sum, match) => sum + match.kills);
    final deaths = heroMatches.fold<int>(0, (sum, match) => sum + match.deaths);
    final assists = heroMatches.fold<int>(
      0,
      (sum, match) => sum + match.assists,
    );
    final gpm = heroMatches.fold<int>(
      0,
      (sum, match) => sum + match.goldPerMin,
    );
    final kda = deaths == 0 ? kills + assists : (kills + assists) / deaths;
    return _HeroPerformance(
      heroId: entry.key,
      matches: heroMatches.length,
      wins: wins,
      winrate: heroMatches.isEmpty ? 0 : wins / heroMatches.length * 100,
      kda: kda.toDouble(),
      gpm: heroMatches.isEmpty ? 0 : gpm / heroMatches.length,
    );
  }).toList();

  heroes.sort((a, b) {
    final aScore = a.winrate * 0.58 + a.kda * 8 + a.matches * 2;
    final bScore = b.winrate * 0.58 + b.kda * 8 + b.matches * 2;
    return bScore.compareTo(aScore);
  });
  return heroes;
}

List<String> _weaknessesFor(DotaComputedStats stats) {
  final items = <String>[];
  if (stats.averageTowerDamage < 1000) {
    items.add(
      'Низкий урон по строениям: преимущество после драк не конвертируется в объекты.',
    );
  }
  if (stats.averageGpm < 470) {
    items.add(
      'GPM ниже комфортного для ранга: теряется темп после стадии линий.',
    );
  }
  if (stats.averageDeaths > 6.5) {
    items.add(
      'Слишком много смертей: часть ресурсов уходит в восстановление позиции.',
    );
  }
  if (stats.averageAssists < 9 && stats.averageKills < 7) {
    items.add(
      'Мало участия в убийствах: герой недостаточно влияет на ключевые драки.',
    );
  }
  if (stats.kda < 2.4) {
    items.add('KDA проседает: нужно сократить рискованные выходы без обзора.');
  }
  if (stats.winrate < 50) {
    items.add(
      'Винрейт ниже 50%: пул героев и план первых 10 минут требуют стабилизации.',
    );
  }
  if (items.isEmpty) {
    items.add(
      'Критичных слабых мест не видно: следующий рост даст точная работа с таймингами объектов.',
    );
  }
  return items.take(5).toList();
}

String _mainProblem(DotaComputedStats stats) {
  if (stats.averageTowerDamage < 1000) {
    return 'низкая реализация преимущества после выигранных драк.';
  }
  if (stats.averageDeaths > 6.5) {
    return 'слишком много смертей в середине игры.';
  }
  if (stats.averageGpm < 470) {
    return 'просадка экономики после линии.';
  }
  if (stats.winrate < 50) {
    return 'нестабильный пул героев и слабый стартовый план.';
  }
  return 'нужно лучше закреплять сильные тайминги и превращать их в объекты.';
}

String _matchReviewSummary(DotaMatch match, DotaComputedStats stats) {
  if (match.matchId == 0) {
    return '?????? ??? ??????? ????????? ??????, ? ????? ???????? ??????? ?????? ?????????? ????.';
  }
  final issues = <String>[];
  if (match.deaths >= 8) {
    issues.add('????? ???????, ????? ????????? 2-3 ???????? ???????');
  }
  if (match.towerDamage < 800 && match.goldPerMin >= 470) {
    issues.add('???? ???????? ?? ???????? ??? ?????????? ?????????');
  }
  if (match.goldPerMin < stats.averageGpm * 0.85) {
    issues.add('???? ????? ???? ?????? ???????? ?????');
  }
  if (issues.isEmpty) {
    issues.add(
      '??????? ????? - ????? ??????, ??? ???????????? ?? ???????????? ? ??????',
    );
  }
  return '??????????????? ?????: ${issues.join(', ')}. ?????? Match Insights ????? ?????? ????????? ????????, ?????? ? ???? ?? ????????? ????.';
}

({String label, IconData icon, Color color}) _formLabel(
  DotaComputedStats stats,
) {
  if (stats.matches == 0) {
    return (
      label: 'Нет данных',
      icon: Icons.help_outline_rounded,
      color: AppColors.muted,
    );
  }
  if (stats.winrateTrend == 'down' || stats.skillScore < 45) {
    return (
      label: 'Просадка',
      icon: Icons.trending_down_rounded,
      color: AppColors.red,
    );
  }
  if (stats.skillScore >= 70 || stats.winrateTrend == 'up') {
    return (
      label: 'Хорошая',
      icon: Icons.trending_up_rounded,
      color: AppColors.neon,
    );
  }
  return (
    label: 'Стабильная',
    icon: Icons.trending_flat_rounded,
    color: AppColors.amber,
  );
}

void _openAiReport(BuildContext context, DotaComputedStats stats) {
  final weaknesses = _weaknessesFor(stats);
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text('AI Coach Report'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Главная проблема: ${_mainProblem(stats)}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              const Text('Что улучшить на этой неделе:'),
              const SizedBox(height: 8),
              for (final item in weaknesses.take(4))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.neon,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      );
    },
  );
}

void _openMatchReviewStub(BuildContext context, DotaMatch match) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        match.matchId == 0 ? 'Матч не выбран' : 'Разбор матча ${match.matchId}',
      ),
      content: const Text(
        'Это заглушка будущего Match Insights. Следующий шаг - отдельная ручка анализа матча, сохранение отчёта и связка с AI Coach.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Понятно'),
        ),
      ],
    ),
  );
}

void _openPaymentStub(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Premium будет позже'),
      content: const Text(
        'Пока первый AI-прогон бесплатный. Для платной версии заложим лимиты, подписки и оплату через Stripe или ЮKassa.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Понятно'),
        ),
      ],
    ),
  );
}

double _matchFormScore(DotaMatch match) {
  final kda =
      (match.kills + match.assists) / (match.deaths == 0 ? 1 : match.deaths);
  final result = match.won ? 15 : -9;
  return (46 + result + kda * 7 + (match.goldPerMin - 420) / 12)
      .clamp(5, 96)
      .toDouble();
}

double _normalize(num value, num min, num max) {
  if (max <= min) return 0;
  return ((value - min) / (max - min)).clamp(0, 1).toDouble();
}

int _scoreClamp(num value) => value.round().clamp(0, 100).toInt();

Color _scoreColor(num score) {
  if (score >= 70) return AppColors.neon;
  if (score >= 50) return AppColors.amber;
  return AppColors.red;
}

String rankLabel(int? rankTier) {
  if (rankTier == null || rankTier <= 0) {
    return 'Ранг неизвестен';
  }
  if (rankTier >= 80) {
    return 'Immortal';
  }
  final medal = rankTier ~/ 10;
  final star = rankTier % 10;
  final medalName = switch (medal) {
    1 => 'Herald',
    2 => 'Guardian',
    3 => 'Crusader',
    4 => 'Archon',
    5 => 'Legend',
    6 => 'Ancient',
    7 => 'Divine',
    _ => 'Неизвестно',
  };
  return '$medalName ${star == 0 ? '' : star}'.trim();
}
