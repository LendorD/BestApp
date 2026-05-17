import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
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
  DotaStatsPeriod _period = DotaStatsPeriod.recent;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректный OpenDota account ID')),
      );
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
              final compact = constraints.maxWidth < 820;
              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Статистика Dota 2',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Профиль, последние матчи, герои, экономика и подсказки для тренировки.',
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
                    label: const Text('Анализ'),
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
                title: 'Готов к анализу',
                message:
                    'Введите OpenDota account ID, чтобы загрузить профиль, матчи и статистику.',
                icon: Icons.query_stats_rounded,
              );
            }
            final stats = DotaComputedStats.fromMatches(data.matches, _period);
            return _AnalysisContent(
              analysis: data,
              stats: stats,
              period: _period,
              onPeriodChanged: (value) => setState(() => _period = value),
            );
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
  const _AnalysisContent({
    required this.analysis,
    required this.stats,
    required this.period,
    required this.onPeriodChanged,
  });

  final DotaAnalysis analysis;
  final DotaComputedStats stats;
  final DotaStatsPeriod period;
  final ValueChanged<DotaStatsPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileSummary(player: analysis.player, stats: stats),
        const SizedBox(height: 18),
        _PeriodSelector(selected: period, onChanged: onPeriodChanged),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 940;
            return compact
                ? Column(
                    children: [
                      _TopHeroes(heroes: stats.topHeroes),
                      const SizedBox(height: 18),
                      _StatsGrid(stats: stats),
                      const SizedBox(height: 18),
                      _Recommendations(stats: stats),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 390,
                        child: _TopHeroes(heroes: stats.topHeroes),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          children: [
                            _StatsGrid(stats: stats),
                            const SizedBox(height: 18),
                            _Recommendations(stats: stats),
                          ],
                        ),
                      ),
                    ],
                  );
          },
        ),
        const SizedBox(height: 18),
        _MatchesTable(matches: stats.filteredMatches),
      ],
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.player, required this.stats});

  final DotaPlayer player;
  final DotaComputedStats stats;

  @override
  Widget build(BuildContext context) {
    final rank = rankLabel(player.rankTier);
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
                      ? 'Игрок ${player.accountId}'
                      : player.personaName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Account ${player.accountId} · ${stats.matches} матчей в выбранном срезе',
                  style: const TextStyle(color: GameMentorColors.muted),
                ),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width > 640)
            Tooltip(
              message:
                  'rank_tier OpenDota: первая цифра — медаль, вторая — звезда. 80 = Immortal.',
              child: Chip(
                avatar: const Icon(Icons.military_tech_rounded, size: 18),
                label: Text(rank),
              ),
            ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});

  final DotaStatsPeriod selected;
  final ValueChanged<DotaStatsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.date_range_rounded, color: GameMentorColors.green),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Период расчёта статистики',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final period in DotaStatsPeriod.values)
                ChoiceChip(
                  selected: selected == period,
                  label: Text(period.label),
                  onSelected: (_) => onChanged(period),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final DotaComputedStats stats;

  @override
  Widget build(BuildContext context) {
    final values = [
      _StatValue(
        'Матчи',
        stats.matches.toString(),
        Icons.sports_esports_rounded,
        GameMentorColors.blue,
      ),
      _StatValue(
        'Винрейт',
        '${stats.winrate.toStringAsFixed(1)}%',
        Icons.percent_rounded,
        GameMentorColors.green,
      ),
      _StatValue(
        'Победы / поражения',
        '${stats.wins}/${stats.losses}',
        Icons.emoji_events_rounded,
        GameMentorColors.amber,
      ),
      _StatValue(
        'KDA',
        stats.kda.toStringAsFixed(2),
        Icons.trending_up_rounded,
        GameMentorColors.purple,
      ),
      _StatValue(
        'Убийства',
        stats.averageKills.toStringAsFixed(1),
        Icons.flash_on_rounded,
        GameMentorColors.blue,
      ),
      _StatValue(
        'Смерти',
        stats.averageDeaths.toStringAsFixed(1),
        Icons.shield_rounded,
        GameMentorColors.red,
      ),
      _StatValue(
        'Ассисты',
        stats.averageAssists.toStringAsFixed(1),
        Icons.groups_rounded,
        GameMentorColors.amber,
      ),
      _StatValue(
        'GPM',
        stats.averageGpm.toStringAsFixed(0),
        Icons.paid_rounded,
        GameMentorColors.green,
      ),
      _StatValue(
        'XPM',
        stats.averageXpm.toStringAsFixed(0),
        Icons.auto_awesome_rounded,
        GameMentorColors.blue,
      ),
      _StatValue(
        'Ластхиты',
        stats.averageLastHits.toStringAsFixed(0),
        Icons.my_location_rounded,
        GameMentorColors.purple,
      ),
      _StatValue(
        'Урон героям',
        stats.averageHeroDamage.toStringAsFixed(0),
        Icons.local_fire_department_rounded,
        GameMentorColors.red,
      ),
      _StatValue(
        'Урон башням',
        stats.averageTowerDamage.toStringAsFixed(0),
        Icons.account_balance_rounded,
        GameMentorColors.amber,
      ),
      _StatValue(
        'Лечение',
        stats.averageHeroHealing.toStringAsFixed(0),
        Icons.healing_rounded,
        GameMentorColors.green,
      ),
      _StatValue(
        'Длительность',
        '${stats.averageDurationMinutes.toStringAsFixed(0)} мин',
        Icons.timer_rounded,
        GameMentorColors.muted,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 760
            ? 4
            : constraints.maxWidth > 520
            ? 3
            : constraints.maxWidth > 360
            ? 2
            : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: columns == 1 ? 4.4 : 2.15,
          children: [
            for (final stat in values)
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: stat.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(stat.icon, color: stat.color, size: 19),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            stat.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stat.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: GameMentorColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
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
            'Лучшие герои',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          if (heroes.isEmpty)
            const Text(
              'В выбранном периоде нет матчей.',
              style: TextStyle(color: GameMentorColors.muted),
            )
          else
            for (final hero in heroes) _HeroCard(hero: hero),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.hero});

  final DotaHeroSummary hero;

  @override
  Widget build(BuildContext context) {
    final info = heroInfoById(hero.heroId);
    return Container(
      height: 92,
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: GameMentorColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameMentorColors.border),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (info != null)
            Image.network(
              info.cardUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GameMentorColors.background.withValues(alpha: 0.88),
                  GameMentorColors.background.withValues(alpha: 0.32),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _HeroAvatar(heroId: hero.heroId),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        info?.nameRu ?? 'Герой ${hero.heroId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${hero.matches} матчей · ${hero.wins} побед',
                        style: const TextStyle(
                          color: GameMentorColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
  const _Recommendations({required this.stats});

  final DotaComputedStats stats;

  @override
  Widget build(BuildContext context) {
    final recommendations = [
      if (stats.averageDeaths > 6)
        'Слишком много смертей: разбери 2-3 смерти после 10-й минуты и отметь, где не хватило обзора.',
      if (stats.winrate < 50)
        'Винрейт просел: сузь пул до 2-3 героев и тренируй первые 10 минут.',
      if (stats.averageGpm < 450)
        'Экономика ниже комфортной: добавь фокус на ластхиты и безопасный фарм после линии.',
      if (stats.averageTowerDamage < 1000)
        'Мало давления по объектам: после выигранной драки сразу ищи вышку или Рошана.',
      if (stats.kda >= 4)
        'KDA хороший: закрепляй героев с высоким импактом и играй вокруг своих сильных таймингов.',
      'Сравни проигрыши и победы: ищи повторяющийся момент, где теряется темп.',
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
            'Рекомендации',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          for (final item in recommendations.take(5))
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
    final dateFormat = DateFormat('dd.MM');
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Последние матчи',
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
                DataColumn(label: Text('Матч')),
                DataColumn(label: Text('Результат')),
                DataColumn(label: Text('Герой')),
                DataColumn(label: Text('K/D/A')),
                DataColumn(label: Text('GPM/XPM')),
                DataColumn(label: Text('LH')),
                DataColumn(label: Text('Урон')),
                DataColumn(label: Text('Длительность')),
                DataColumn(label: Text('Дата')),
              ],
              rows: [
                for (final match in matches)
                  DataRow(
                    cells: [
                      DataCell(Text(match.matchId.toString())),
                      DataCell(
                        Text(
                          match.won ? 'Победа' : 'Поражение',
                          style: TextStyle(
                            color: match.won
                                ? GameMentorColors.green
                                : GameMentorColors.red,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _HeroAvatar(heroId: match.heroId, small: true),
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
                      DataCell(
                        Text('${(match.durationSeconds / 60).round()} мин'),
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

class _HeroAvatar extends StatelessWidget {
  const _HeroAvatar({required this.heroId, this.small = false});

  final int heroId;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final hero = heroInfoById(heroId);
    final size = small ? 34.0 : 48.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(small ? 10 : 14),
      child: Container(
        width: size,
        height: size,
        color: GameMentorColors.purple.withValues(alpha: 0.18),
        child: hero == null
            ? Center(child: Text(heroId.toString()))
            : Image.network(
                hero.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Center(child: Text(heroId.toString())),
              ),
      ),
    );
  }
}

class _StatValue {
  const _StatValue(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

String rankLabel(int? rankTier) {
  if (rankTier == null || rankTier <= 0) {
    return 'Ранг неизвестен';
  }
  if (rankTier >= 80) {
    return 'Immortal ($rankTier)';
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
