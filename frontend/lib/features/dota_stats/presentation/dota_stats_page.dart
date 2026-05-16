import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../data/dota_stats_providers.dart';
import '../domain/dota_models.dart';

class DotaStatsPage extends ConsumerStatefulWidget {
  const DotaStatsPage({super.key, this.initialAccountId});

  final String? initialAccountId;

  @override
  ConsumerState<DotaStatsPage> createState() => _DotaStatsPageState();
}

class _DotaStatsPageState extends ConsumerState<DotaStatsPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAccountId ?? '');
    final parsed = int.tryParse(widget.initialAccountId ?? '');
    if (parsed != null) {
      Future.microtask(() {
        ref.read(dotaAccountIdProvider.notifier).state = parsed;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid account ID')));
      return;
    }
    ref.read(dotaAccountIdProvider.notifier).state = accountId;
  }

  @override
  Widget build(BuildContext context) {
    final analysis = ref.watch(dotaAnalysisProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          gradient: LinearGradient(
            colors: [
              GameMentorColors.green.withValues(alpha: 0.16),
              GameMentorColors.blue.withValues(alpha: 0.1),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dota 2 Stats',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Analyze recent matches, hero patterns and decision quality.',
                    style: TextStyle(
                      color: GameMentorColors.muted,
                      height: 1.45,
                    ),
                  ),
                ],
              );
              final form = Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'OpenDota account ID',
                        prefixIcon: Icon(Icons.tag_rounded),
                      ),
                      onSubmitted: (_) => _analyze(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _analyze,
                    icon: const Icon(Icons.analytics_rounded),
                    label: const Text('Analyze'),
                  ),
                ],
              );

              return compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [title, const SizedBox(height: 18), form],
                    )
                  : Row(
                      children: [
                        Expanded(child: title),
                        const SizedBox(width: 24),
                        Expanded(child: form),
                      ],
                    );
            },
          ),
        ),
        const SizedBox(height: 20),
        analysis.when(
          data: (data) {
            if (data == null) {
              return const EmptyState(
                title: 'Ready when you are',
                message:
                    'Enter a Dota account ID to fetch profile, recent matches and summary.',
                icon: Icons.query_stats_rounded,
              );
            }
            return _AnalysisContent(analysis: data);
          },
          loading: () => const LoadingState(rows: 6),
          error: (error, _) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(dotaAnalysisProvider),
          ),
        ),
      ],
    );
  }
}

class _AnalysisContent extends StatelessWidget {
  const _AnalysisContent({required this.analysis});

  final DotaAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileSummary(player: analysis.player, summary: analysis.summary),
        const SizedBox(height: 18),
        _StatsGrid(summary: analysis.summary),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 980;
            final heroes = _TopHeroes(heroes: analysis.summary.topHeroes);
            final recommendations = _Recommendations(summary: analysis.summary);
            return compact
                ? Column(
                    children: [
                      heroes,
                      const SizedBox(height: 18),
                      recommendations,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: heroes),
                      const SizedBox(width: 18),
                      Expanded(child: recommendations),
                    ],
                  );
          },
        ),
        const SizedBox(height: 18),
        _MatchesTable(matches: analysis.matches),
      ],
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.player, required this.summary});

  final DotaPlayer player;
  final DotaSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: GameMentorColors.surfaceAlt,
            backgroundImage: player.avatarFull.isEmpty
                ? null
                : NetworkImage(player.avatarFull),
            child: player.avatarFull.isEmpty
                ? const Icon(Icons.person_rounded)
                : null,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.personaName.isEmpty
                      ? 'Dota Player ${player.accountId}'
                      : player.personaName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Account ${player.accountId} · ${summary.matches} recent matches',
                  style: const TextStyle(color: GameMentorColors.muted),
                ),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width > 640)
            Chip(
              avatar: const Icon(Icons.military_tech_rounded, size: 18),
              label: Text(
                player.rankTier == null
                    ? 'Rank unknown'
                    : 'Rank ${player.rankTier}',
              ),
            ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.summary});

  final DotaSummary summary;

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        'Winrate',
        '${summary.winrate.toStringAsFixed(1)}%',
        Icons.percent_rounded,
        GameMentorColors.green,
      ),
      (
        'KDA',
        summary.kda.toStringAsFixed(2),
        Icons.trending_up_rounded,
        GameMentorColors.purple,
      ),
      (
        'Avg kills',
        summary.averageKills.toStringAsFixed(1),
        Icons.flash_on_rounded,
        GameMentorColors.blue,
      ),
      (
        'Avg deaths',
        summary.averageDeaths.toStringAsFixed(1),
        Icons.shield_rounded,
        GameMentorColors.red,
      ),
      (
        'Avg assists',
        summary.averageAssists.toStringAsFixed(1),
        Icons.groups_rounded,
        GameMentorColors.amber,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 1100
            ? 5
            : constraints.maxWidth > 720
            ? 3
            : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: columns == 1 ? 3.2 : 1.4,
          children: [
            for (final stat in stats)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(stat.$3, color: stat.$4),
                    Text(
                      stat.$2,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      stat.$1,
                      style: const TextStyle(color: GameMentorColors.muted),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TopHeroes extends StatelessWidget {
  const _TopHeroes({required this.heroes});

  final List<DotaHeroSummary> heroes;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top heroes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          for (final hero in heroes)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: GameMentorColors.purple.withValues(
                      alpha: 0.18,
                    ),
                    child: Text(hero.heroId.toString()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hero ${hero.heroId}',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '${hero.matches} matches · ${hero.wins} wins',
                          style: const TextStyle(color: GameMentorColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${hero.winrate.toStringAsFixed(0)}%',
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

class _Recommendations extends StatelessWidget {
  const _Recommendations({required this.summary});

  final DotaSummary summary;

  @override
  Widget build(BuildContext context) {
    final recommendations = [
      if (summary.averageDeaths > 6)
        'Reduce mid-game deaths by reviewing smoke timings.',
      if (summary.winrate < 55)
        'Focus on first 10 minutes and lane resource trades.',
      if (summary.kda > 4)
        'Keep high-impact heroes in your main pool this week.',
      'Build a 3-hero comfort pool for ranked consistency.',
    ];

    return AppCard(
      gradient: LinearGradient(
        colors: [
          GameMentorColors.green.withValues(alpha: 0.14),
          GameMentorColors.purple.withValues(alpha: 0.08),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommendations',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          for (final item in recommendations)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: GameMentorColors.green,
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

class _MatchesTable extends StatelessWidget {
  const _MatchesTable({required this.matches});

  final List<DotaMatch> matches;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent matches',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(
                color: GameMentorColors.muted,
                fontWeight: FontWeight.w800,
              ),
              columns: const [
                DataColumn(label: Text('Match')),
                DataColumn(label: Text('Result')),
                DataColumn(label: Text('Hero')),
                DataColumn(label: Text('K/D/A')),
                DataColumn(label: Text('Duration')),
                DataColumn(label: Text('Date')),
              ],
              rows: [
                for (final match in matches)
                  DataRow(
                    cells: [
                      DataCell(Text(match.matchId.toString())),
                      DataCell(
                        Text(
                          match.won ? 'Win' : 'Loss',
                          style: TextStyle(
                            color: match.won
                                ? GameMentorColors.green
                                : GameMentorColors.red,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      DataCell(Text('Hero ${match.heroId}')),
                      DataCell(
                        Text('${match.kills}/${match.deaths}/${match.assists}'),
                      ),
                      DataCell(
                        Text('${(match.durationSeconds / 60).round()}m'),
                      ),
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
