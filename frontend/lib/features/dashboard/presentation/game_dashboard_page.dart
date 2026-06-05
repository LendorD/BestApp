import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/storage/product_preference.dart';

class GameDashboardPage extends StatefulWidget {
  const GameDashboardPage({required this.product, super.key});

  final ProductDirection product;

  @override
  State<GameDashboardPage> createState() => _GameDashboardPageState();
}

class _GameDashboardPageState extends State<GameDashboardPage> {
  String _period = '30D';
  String _trend = 'winrate';

  @override
  Widget build(BuildContext context) {
    final data = _dashboardData(widget.product);
    return _Stack(
      gap: 16,
      children: [
        _ProfileHeader(data: data, period: _period, onPeriod: _setPeriod),
        _ResponsiveColumns(
          leftFlex: 5,
          rightFlex: 7,
          left: _ScorePanel(data: data),
          right: _KpiGrid(data: data),
        ),
        _ResponsiveColumns(
          leftFlex: 7,
          rightFlex: 5,
          left: _TrendCard(
            data: data,
            selected: _trend,
            onSelected: (value) => setState(() => _trend = value),
          ),
          right: _RadarCard(data: data),
        ),
        _AiInsights(data: data),
        _ResponsiveColumns(
          leftFlex: 7,
          rightFlex: 5,
          left: _MatchesTable(data: data),
          right: _LeaderboardCard(data: data),
        ),
        _TrainingGoals(data: data),
      ],
    );
  }

  void _setPeriod(String value) {
    setState(() => _period = value);
  }
}

class _Stack extends StatelessWidget {
  const _Stack({required this.children, this.gap = 16});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          children[i],
        ],
      ],
    );
  }
}

class _ResponsiveColumns extends StatelessWidget {
  const _ResponsiveColumns({
    required this.left,
    required this.right,
    this.leftFlex = 1,
    this.rightFlex = 1,
  });

  final Widget left;
  final Widget right;
  final int leftFlex;
  final int rightFlex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 980) {
          return _Stack(children: [left, right]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: leftFlex, child: left),
            const SizedBox(width: 16),
            Expanded(flex: rightFlex, child: right),
          ],
        );
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.accent,
    this.glow = false,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accent;
  final bool glow;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final glowColor = accent ?? AppColors.dotaAccent;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor ?? AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.86),
              blurRadius: 40,
              offset: const Offset(0, 18),
              spreadRadius: -28,
            ),
          ],
        ),
        child: Stack(
          children: [
            if (glow)
              Positioned(
                top: -72,
                right: -54,
                child: IgnorePointer(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          glowColor.withValues(alpha: 0.16),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.white.withValues(alpha: 0.03),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.data,
    required this.period,
    required this.onPeriod,
  });

  final _DashboardData data;
  final String period;
  final ValueChanged<String> onPeriod;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: EdgeInsets.zero,
      accent: data.accent,
      borderColor: data.accent.withValues(alpha: 0.34),
      glow: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 980;
          final profile = Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                _Avatar(letter: data.avatar, accent: data.accent, size: 76),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Kicker(data.seasonLabel, color: data.accent),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Text(
                            data.playerName,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          _Mono(
                            '#${data.accountId}',
                            color: AppColors.mutedDeep,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _Badge(label: data.rankTier, color: data.accent),
                          _InlineMetric(
                            value: data.rating,
                            label: data.ratingLabel,
                            delta: '+${data.ratingDelta}',
                            accent: data.accent,
                          ),
                          Text(data.region, style: _mutedText(12)),
                          Text(data.rolesLine, style: _mutedText(12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

          final stats = Padding(
            padding: EdgeInsets.fromLTRB(compact ? 22 : 0, 18, 22, 18),
            child: Row(
              mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
              children: [
                _HeaderStat(
                  label: 'Rank percentile',
                  value: data.percentile,
                  accent: data.accent,
                ),
                const SizedBox(width: 28),
                _HeaderStat(
                  label: 'Form (10g)',
                  value: data.form,
                  accent: data.accent,
                ),
                const Spacer(),
                _PeriodTabs(
                  accent: data.accent,
                  selected: period,
                  onSelected: onPeriod,
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                profile,
                Divider(color: AppColors.border, height: 1),
                stats,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: profile),
              Container(width: 1, height: 112, color: AppColors.border),
              Flexible(child: stats),
            ],
          );
        },
      ),
    );
  }
}

class _ScorePanel extends StatelessWidget {
  const _ScorePanel({required this.data});

  final _DashboardData data;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      accent: data.accent,
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'GameMentor Score',
            subtitle: data.scoreCaption,
            right: _Delta(
              value: '+${data.scoreDelta}',
              up: true,
              accent: data.accent,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 540;
              final gauge = Column(
                children: [
                  _Gauge(value: data.score, accent: data.accent, size: 156),
                  const SizedBox(height: 8),
                  _Badge(label: data.percentile, color: data.accent),
                ],
              );
              final bars = _Stack(
                gap: 10,
                children: [
                  for (final metric in data.scoreBreakdown)
                    _MetricBar(metric: metric, accent: data.accent),
                ],
              );

              if (compact) {
                return _Stack(
                  children: [
                    Center(child: gauge),
                    bars,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  gauge,
                  const SizedBox(width: 22),
                  Expanded(child: bars),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.data});

  final _DashboardData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 760 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: constraints.maxWidth >= 760 ? 1.72 : 1.5,
          ),
          itemCount: data.kpis.length,
          itemBuilder: (context, index) =>
              _KpiCard(kpi: data.kpis[index], accent: data.accent),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.kpi, required this.accent});

  final _KpiItem kpi;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final lineColor = kpi.up ? accent : AppColors.red;
    return _DashboardCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _Kicker(kpi.label)),
              _Delta(value: kpi.delta, up: kpi.up, accent: accent),
            ],
          ),
          const SizedBox(height: 8),
          _Mono(
            kpi.value,
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
          const Spacer(),
          SizedBox(
            height: 32,
            child: CustomPaint(
              painter: _SparklinePainter(data: kpi.spark, color: lineColor),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.data,
    required this.selected,
    required this.onSelected,
  });

  final _DashboardData data;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final values = selected == 'winrate' ? data.winrateTrend : data.ratingTrend;
    final latest = values.last.round();
    final latestLabel = selected == 'winrate' ? '$latest%' : '$latest';
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Performance Trend',
            subtitle: 'Rolling window - last 16 sessions',
            right: _SwitchPills(
              values: [('winrate', 'Winrate'), ('rating', data.ratingLabel)],
              selected: selected,
              accent: data.accent,
              onSelected: onSelected,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Mono(
                latestLabel,
                color: AppColors.text,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(width: 10),
              _Delta(
                value: selected == 'winrate' ? '+4%' : '+184',
                up: true,
                accent: data.accent,
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('vs start of period', style: _mutedText(12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 156,
            child: CustomPaint(
              painter: _LineChartPainter(data: values, accent: data.accent),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarCard extends StatelessWidget {
  const _RadarCard({required this.data});

  final _DashboardData data;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Skill Profile',
            subtitle: 'You vs rank average',
          ),
          SizedBox(
            height: 236,
            child: CustomPaint(
              painter: _RadarPainter(
                labels: data.radarLabels,
                you: data.radarYou,
                average: data.radarAverage,
                accent: data.accent,
              ),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: data.accent, label: 'You'),
              const SizedBox(width: 18),
              const _Legend(
                color: AppColors.muted,
                label: 'Rank avg',
                dashed: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiInsights extends StatelessWidget {
  const _AiInsights({required this.data});

  final _DashboardData data;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      accent: AppColors.warningPro,
      glow: true,
      borderColor: AppColors.warningPro.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'AI Coach Insights',
            subtitle: 'Generated from your last 100 matches',
            right: const _Badge(label: 'PRO', color: AppColors.warningPro),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final row = constraints.maxWidth >= 920;
              final cards = [
                for (final insight in data.insights)
                  _InsightCard(insight: insight, accent: data.accent),
              ];
              if (!row) return _Stack(gap: 12, children: cards);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.bolt_rounded, size: 18),
              label: const Text('Generate full AI report'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warningPro,
                side: BorderSide(color: AppColors.warningPro),
                backgroundColor: AppColors.warningPro.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchesTable extends StatelessWidget {
  const _MatchesTable({required this.data});

  final _DashboardData data;

  @override
  Widget build(BuildContext context) {
    final headers = data.product == ProductDirection.cs2
        ? ['Map', '', 'K/D/A', 'Score', 'ADR', 'Rating']
        : ['Hero', '', 'K/D/A', 'GPM', 'Duration', 'Impact'];
    return _DashboardCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: _SectionTitle(
              title: 'Recent Matches',
              subtitle:
                  'Last ${data.matches.length} - ${data.product == ProductDirection.cs2 ? 'Premier' : 'Ranked'}',
              right: Text(
                'View all ->',
                style: TextStyle(
                  color: data.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          _MatchGridHeader(headers: headers),
          for (final match in data.matches.take(6))
            _MatchRowView(match: match, data: data),
        ],
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard({required this.data});

  final _DashboardData data;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Pro Benchmark',
            subtitle: data.benchmarkCaption,
          ),
          const SizedBox(height: 2),
          _Stack(
            gap: 7,
            children: [
              for (var i = 0; i < data.leaderboard.length; i++)
                _LeaderRowView(
                  row: data.leaderboard[i],
                  index: i,
                  accent: data.accent,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _Stack(
            gap: 11,
            children: [
              for (final bar in data.benchmarkBars)
                _BenchmarkBar(bar: bar, accent: data.accent),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrainingGoals extends StatelessWidget {
  const _TrainingGoals({required this.data});

  final _DashboardData data;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Training Goals',
            subtitle: 'Next week focus plan',
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final row = constraints.maxWidth >= 900;
              final cards = [
                for (final goal in data.goals)
                  _GoalCard(goal: goal, accent: data.accent),
              ];
              if (!row) return _Stack(gap: 12, children: cards);
              return Row(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.subtitle, this.right});

  final String title;
  final String? subtitle;
  final Widget? right;

  @override
  Widget build(BuildContext context) {
    final trailing = right;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: _mutedText(12)),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({required this.metric, required this.accent});

  final _MetricItem metric;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final color = metric.value < 62 ? AppColors.red : accent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                metric.label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _Mono(
              '${metric.value}',
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(height: 7, color: AppColors.surfaceAlt),
              FractionallySizedBox(
                widthFactor: metric.value / 100,
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.45),
                        blurRadius: 10,
                      ),
                    ],
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

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight, required this.accent});

  final _Insight insight;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final color = switch (insight.kind) {
      _InsightKind.weak => AppColors.red,
      _InsightKind.strong => accent,
      _InsightKind.focus => AppColors.warningPro,
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 86,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Kicker(insight.tag, color: color),
                const SizedBox(height: 8),
                Text(
                  insight.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(insight.body, style: _mutedText(12.5, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchGridHeader extends StatelessWidget {
  const _MatchGridHeader({required this.headers});

  final List<String> headers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: Grid(
        columnsTemplate: '1.4fr .5fr 1fr .8fr .8fr .6fr',
        columnGap: 8,
        children: [for (final header in headers) _Kicker(header)],
      ),
    );
  }
}

class _MatchRowView extends StatelessWidget {
  const _MatchRowView({required this.match, required this.data});

  final _MatchItem match;
  final _DashboardData data;

  @override
  Widget build(BuildContext context) {
    final won = match.result == 'W';
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.58)),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 3,
            child: ColoredBox(color: won ? data.accent : AppColors.red),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Grid(
              columnsTemplate: '1.4fr .5fr 1fr .8fr .8fr .6fr',
              columnGap: 8,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: _Mono(
                          match.short,
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          _Mono(
                            '${match.when} ago',
                            color: AppColors.mutedDeep,
                            fontSize: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _Mono(
                  match.result,
                  color: won ? data.accent : AppColors.red,
                  fontWeight: FontWeight.w800,
                ),
                _Mono(match.kda, color: AppColors.text, align: TextAlign.right),
                _Mono(
                  match.metricA,
                  color: AppColors.muted,
                  align: TextAlign.right,
                ),
                _Mono(
                  match.metricB,
                  color: AppColors.muted,
                  align: TextAlign.right,
                ),
                _Mono(
                  match.impact,
                  color: data.accent,
                  align: TextAlign.right,
                  fontWeight: FontWeight.w800,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderRowView extends StatelessWidget {
  const _LeaderRowView({
    required this.row,
    required this.index,
    required this.accent,
  });

  final _LeaderItem row;
  final int index;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: row.you ? accent.withValues(alpha: 0.08) : AppColors.background,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: row.you ? accent.withValues(alpha: 0.28) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          _Mono('${index + 1}', color: AppColors.mutedDeep, fontSize: 12),
          const SizedBox(width: 11),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                row.name[0],
                style: TextStyle(
                  color: row.you ? accent : AppColors.muted,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              spacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  row.name,
                  style: TextStyle(
                    color: row.you ? AppColors.text : AppColors.muted,
                    fontWeight: row.you ? FontWeight.w900 : FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                if (row.you) _Mono('YOU', color: accent, fontSize: 10),
              ],
            ),
          ),
          _Mono(
            '${row.score}',
            color: row.you ? accent : AppColors.text,
            fontWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }
}

class _BenchmarkBar extends StatelessWidget {
  const _BenchmarkBar({required this.bar, required this.accent});

  final _BenchmarkItem bar;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(bar.label, style: _mutedText(12))),
            _Mono(
              '${bar.you} / ${bar.pro}',
              color: AppColors.muted,
              fontSize: 12,
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(height: 8, color: AppColors.background),
              FractionallySizedBox(
                widthFactor: bar.pro / 100,
                child: Container(
                  height: 8,
                  color: AppColors.muted.withValues(alpha: 0.36),
                ),
              ),
              FractionallySizedBox(
                widthFactor: bar.you / 100,
                child: Container(height: 8, color: accent),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.accent});

  final _GoalItem goal;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(goal.label, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(goal.subtitle, style: _mutedText(12)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(height: 8, color: AppColors.surfaceAlt),
                FractionallySizedBox(
                  widthFactor: goal.percent / 100,
                  child: Container(height: 8, color: accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({
    required this.accent,
    required this.selected,
    required this.onSelected,
  });

  final Color accent;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return _SwitchPills(
      values: const [('7D', '7D'), ('30D', '30D'), ('90D', '90D')],
      selected: selected,
      accent: accent,
      onSelected: onSelected,
    );
  }
}

class _SwitchPills extends StatelessWidget {
  const _SwitchPills({
    required this.values,
    required this.selected,
    required this.accent,
    required this.onSelected,
  });

  final List<(String, String)> values;
  final String selected;
  final Color accent;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in values)
            TextButton(
              onPressed: () => onSelected(item.$1),
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                backgroundColor: item.$1 == selected
                    ? accent
                    : Colors.transparent,
                foregroundColor: item.$1 == selected
                    ? AppColors.background
                    : AppColors.muted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: _Mono(
                item.$2,
                color: item.$1 == selected
                    ? AppColors.background
                    : AppColors.muted,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.letter, required this.accent, this.size = 56});

  final String letter;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceAlt, AppColors.background],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 0,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: accent,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Kicker(label),
        const SizedBox(height: 4),
        _Mono(value, color: accent, fontSize: 18, fontWeight: FontWeight.w800),
      ],
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({
    required this.value,
    required this.label,
    required this.delta,
    required this.accent,
  });

  final String value;
  final String label;
  final String delta;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Mono(value, color: AppColors.text, fontWeight: FontWeight.w800),
        const SizedBox(width: 5),
        Text(label, style: _mutedText(12)),
        const SizedBox(width: 6),
        _Delta(value: delta, up: true, accent: accent),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: _Mono(
          label,
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Delta extends StatelessWidget {
  const _Delta({required this.value, required this.up, required this.accent});

  final String value;
  final bool up;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final color = up ? accent : AppColors.red;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(up ? '▲' : '▼', style: TextStyle(color: color, fontSize: 9)),
        const SizedBox(width: 3),
        _Mono(value, color: color, fontSize: 11, fontWeight: FontWeight.w800),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 18,
          height: 2,
          child: CustomPaint(
            painter: _LegendPainter(color: color, dashed: dashed),
          ),
        ),
        const SizedBox(width: 7),
        Text(label, style: _mutedText(11.5)),
      ],
    );
  }
}

class _Kicker extends StatelessWidget {
  const _Kicker(this.text, {this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color ?? AppColors.mutedDeep,
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        fontFamily: 'JetBrains Mono',
        letterSpacing: 0,
      ),
    );
  }
}

class _Mono extends StatelessWidget {
  const _Mono(
    this.text, {
    this.color = AppColors.muted,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w600,
    this.align,
  });

  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: align,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: 'JetBrains Mono',
        letterSpacing: 0,
      ),
    );
  }
}

class _Gauge extends StatelessWidget {
  const _Gauge({required this.value, required this.accent, this.size = 156});

  final int value;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _GaugePainter(value: value, accent: accent),
            size: Size.square(size),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Mono(
                '$value',
                color: AppColors.text,
                fontSize: size * 0.3,
                fontWeight: FontWeight.w800,
              ),
              _Mono('/ 100', color: AppColors.mutedDeep, fontSize: 9.5),
            ],
          ),
        ],
      ),
    );
  }
}

class Grid extends StatelessWidget {
  const Grid({
    required this.columnsTemplate,
    required this.children,
    this.columnGap = 0,
    super.key,
  });

  final String columnsTemplate;
  final List<Widget> children;
  final double columnGap;

  @override
  Widget build(BuildContext context) {
    final flexes = columnsTemplate
        .split(' ')
        .map((part) => double.tryParse(part.replaceAll('fr', '')) ?? 1)
        .toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: columnGap),
          Expanded(flex: (flexes[i] * 100).round(), child: children[i]),
        ],
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.value, required this.accent});

  final int value;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final rect = Offset.zero & size;
    final inset = stroke / 2 + 2;
    final arcRect = rect.deflate(inset);
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.surfaceAlt;
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = accent;
    const start = math.pi * 0.75;
    const sweep = math.pi * 1.5;
    canvas.drawArc(arcRect, start, sweep, false, basePaint);
    canvas.drawArc(arcRect, start, sweep * (value / 100), false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return value != oldDelegate.value || accent != oldDelegate.accent;
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.data, required this.color});

  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2 || size.width <= 0 || size.height <= 0) return;
    final minValue = data.reduce(math.min);
    final maxValue = data.reduce(math.max);
    final range = maxValue - minValue == 0 ? 1 : maxValue - minValue;
    final path = Path();
    for (var i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y = 4 + (1 - (data[i] - minValue) / range) * (size.height - 8);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({required this.data, required this.accent});

  final List<double> data;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final minValue = data.reduce(math.min);
    final maxValue = data.reduce(math.max);
    final range = maxValue - minValue == 0 ? 1 : maxValue - minValue;
    const left = 6.0;
    const right = 6.0;
    const top = 12.0;
    const bottom = 10.0;
    final width = size.width - left - right;
    final height = size.height - top - bottom;

    for (final g in [0.25, 0.5, 0.75]) {
      final y = top + g * height;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        Paint()
          ..color = AppColors.border
          ..strokeWidth = 1,
      );
    }

    final path = Path();
    final area = Path();
    for (var i = 0; i < data.length; i++) {
      final x = left + i / (data.length - 1) * width;
      final y = top + (1 - (data[i] - minValue) / range) * height;
      if (i == 0) {
        path.moveTo(x, y);
        area.moveTo(x, size.height - bottom);
        area.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        area.lineTo(x, y);
      }
    }
    area.lineTo(size.width - right, size.height - bottom);
    area.close();

    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent.withValues(alpha: 0.28), Colors.transparent],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = accent,
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => true;
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({
    required this.labels,
    required this.you,
    required this.average,
    required this.accent,
  });

  final List<String> labels;
  final List<int> you;
  final List<int> average;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final n = labels.length;
    if (n < 3) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 28;

    Offset point(int i, double fraction) {
      final angle = math.pi * 2 * i / n - math.pi / 2;
      return center +
          Offset(math.cos(angle), math.sin(angle)) * radius * fraction;
    }

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.border;
    for (final fraction in [0.25, 0.5, 0.75, 1.0]) {
      final p = Path();
      for (var i = 0; i < n; i++) {
        final offset = point(i, fraction);
        if (i == 0) {
          p.moveTo(offset.dx, offset.dy);
        } else {
          p.lineTo(offset.dx, offset.dy);
        }
      }
      p.close();
      canvas.drawPath(p, gridPaint);
    }
    for (var i = 0; i < n; i++) {
      canvas.drawLine(center, point(i, 1), gridPaint);
    }

    Path polygon(List<int> values) {
      final p = Path();
      for (var i = 0; i < n; i++) {
        final offset = point(i, values[i] / 100);
        if (i == 0) {
          p.moveTo(offset.dx, offset.dy);
        } else {
          p.lineTo(offset.dx, offset.dy);
        }
      }
      p.close();
      return p;
    }

    canvas.drawPath(
      polygon(average),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.muted,
    );
    canvas.drawPath(
      polygon(you),
      Paint()
        ..style = PaintingStyle.fill
        ..color = accent.withValues(alpha: 0.12),
    );
    canvas.drawPath(
      polygon(you),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = accent,
    );

    for (var i = 0; i < n; i++) {
      final p = point(i, 1.15);
      final painter = TextPainter(
        text: TextSpan(
          text: labels[i].toUpperCase(),
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 9.5,
            fontFamily: 'JetBrains Mono',
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 80);
      painter.paint(canvas, p - Offset(painter.width / 2, painter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => true;
}

class _LegendPainter extends CustomPainter {
  const _LegendPainter({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    if (!dashed) {
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      return;
    }
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(math.min(x + 4, size.width), size.height / 2),
        paint,
      );
      x += 7;
    }
  }

  @override
  bool shouldRepaint(covariant _LegendPainter oldDelegate) => false;
}

TextStyle _mutedText(double size, {double height = 1.35}) {
  return TextStyle(color: AppColors.muted, fontSize: size, height: height);
}

_DashboardData _dashboardData(ProductDirection product) {
  return product == ProductDirection.cs2 ? _cs2Data : _dotaData;
}

final _dotaData = _DashboardData(
  product: ProductDirection.dota,
  accent: AppColors.dotaAccent,
  playerName: 'Lendor',
  accountId: '369102305',
  region: 'EU West',
  rolesLine: 'Carry - Mid',
  avatar: 'L',
  rankTier: 'Divine III',
  rating: '5420',
  ratingLabel: 'MMR',
  ratingDelta: '184',
  percentile: 'Top 12%',
  form: 'W W L W L',
  seasonLabel: 'RANKED - SEASON 7',
  score: 74,
  scoreDelta: 6,
  scoreCaption: 'Better than 88% of Divine players',
  scoreBreakdown: const [
    _MetricItem('Laning', 71),
    _MetricItem('Teamfight', 78),
    _MetricItem('Farming', 82),
    _MetricItem('Objectives', 64),
    _MetricItem('Vision', 58),
    _MetricItem('Survival', 69),
  ],
  kpis: const [
    _KpiItem('Winrate', '56%', '+4', true, [
      52,
      58,
      49,
      61,
      55,
      63,
      57,
      64,
      60,
      66,
      59,
      62,
      65,
      56,
    ]),
    _KpiItem('KDA', '3.42', '+0.31', true, [
      3.0,
      3.3,
      2.9,
      3.5,
      3.2,
      3.8,
      3.1,
      3.6,
      3.4,
      3.9,
      3.7,
      3.2,
      3.8,
      3.42,
    ]),
    _KpiItem('GPM', '612', '+18', true, [
      560,
      590,
      575,
      610,
      604,
      620,
      598,
      635,
      618,
      642,
      607,
      630,
      636,
      612,
    ]),
    _KpiItem('XPM', '684', '+22', true, [
      640,
      672,
      651,
      690,
      681,
      703,
      660,
      710,
      695,
      718,
      676,
      702,
      724,
      684,
    ]),
    _KpiItem('Last hits / 10m', '78', '-3', false, [
      82,
      78,
      84,
      80,
      76,
      79,
      81,
      77,
      75,
      80,
      78,
      73,
      76,
      78,
    ]),
    _KpiItem('Hero DMG', '28.4k', '+2.1k', true, [
      24,
      26,
      25,
      29,
      27,
      31,
      28,
      32,
      30,
      33,
      29,
      31,
      32,
      28.4,
    ]),
  ],
  winrateTrend: const [
    49,
    51,
    47,
    53,
    55,
    52,
    57,
    54,
    59,
    58,
    61,
    56,
    63,
    62,
    65,
    56,
  ],
  ratingTrend: const [
    5180,
    5210,
    5236,
    5268,
    5304,
    5290,
    5332,
    5356,
    5380,
    5404,
    5378,
    5420,
    5455,
    5480,
    5502,
    5420,
  ],
  radarLabels: const [
    'Laning',
    'Fight',
    'Farm',
    'Objectives',
    'Vision',
    'Survival',
  ],
  radarYou: const [71, 78, 82, 64, 58, 69],
  radarAverage: const [66, 64, 70, 62, 60, 63],
  insights: const [
    _Insight(
      _InsightKind.weak,
      'PRIMARY LEAK',
      'You stop pressuring after won fights',
      'In 9 of last 14 wins the advantage faded before the next objective. Convert kills into tower or Roshan within 25s.',
    ),
    _Insight(
      _InsightKind.strong,
      'STRENGTH',
      'Elite early farm tempo',
      'GPM at 10 minutes sits in the top 8% of your bracket. Your laning conversion is a real edge.',
    ),
    _Insight(
      _InsightKind.focus,
      'FOCUS THIS WEEK',
      'Ward efficiency and deward windows',
      'Vision score is your lowest pillar. Target 1.4 dewards per 10 minutes and play around rune timings.',
    ),
  ],
  matches: const [
    _MatchItem('Juggernaut', 'JG', 'W', '12/3/9', '678', '38:12', '9.1', '2h'),
    _MatchItem(
      'Phantom Assassin',
      'PA',
      'W',
      '15/6/7',
      '712',
      '41:50',
      '8.4',
      '5h',
    ),
    _MatchItem(
      'Faceless Void',
      'FV',
      'L',
      '6/9/11',
      '521',
      '47:03',
      '5.2',
      '8h',
    ),
    _MatchItem('Morphling', 'MO', 'W', '11/4/13', '645', '35:40', '8.8', '1d'),
    _MatchItem('Ember Spirit', 'ES', 'L', '8/8/9', '558', '44:19', '5.9', '1d'),
    _MatchItem('Anti-Mage', 'AM', 'W', '10/2/5', '734', '33:08', '9.4', '2d'),
  ],
  benchmarkCaption: 'vs Pro carries - normalized per-min',
  leaderboard: const [
    _LeaderItem('You', true, 74),
    _LeaderItem('Yatoro', false, 96),
    _LeaderItem('Nisha', false, 94),
    _LeaderItem('Ame', false, 95),
  ],
  benchmarkBars: const [
    _BenchmarkItem('GPM', 82, 96),
    _BenchmarkItem('KDA', 67, 92),
    _BenchmarkItem('Last hits', 88, 97),
    _BenchmarkItem('Map impact', 71, 95),
  ],
  goals: const [
    _GoalItem('Last-hits - 78 by 10:00', 'current avg 73', 86),
    _GoalItem('Deward 1.4 / 10 min', 'current 0.8', 54),
    _GoalItem('Smoke participation 60%', 'current 49%', 71),
  ],
);

final _cs2Data = _DashboardData(
  product: ProductDirection.cs2,
  accent: AppColors.cs2Accent,
  playerName: 'Lendor',
  accountId: 'STEAM 7656...4021',
  region: 'EU',
  rolesLine: 'Entry - AWP',
  avatar: 'L',
  rankTier: 'Faceit 9',
  rating: '1984',
  ratingLabel: 'ELO',
  ratingDelta: '96',
  percentile: 'Top 18%',
  form: 'W W L W L',
  seasonLabel: 'PREMIER - S2',
  score: 68,
  scoreDelta: 4,
  scoreCaption: 'Better than 82% of Premier players',
  scoreBreakdown: const [
    _MetricItem('Aim', 80),
    _MetricItem('Utility', 61),
    _MetricItem('Positioning', 66),
    _MetricItem('Clutch', 72),
    _MetricItem('Economy', 70),
    _MetricItem('Entry', 58),
  ],
  kpis: const [
    _KpiItem('K/D', '1.18', '+0.07', true, [
      1.1,
      1.2,
      1.0,
      1.16,
      1.23,
      1.18,
      1.29,
      1.14,
      1.22,
      1.31,
      1.17,
      1.2,
      1.25,
      1.18,
    ]),
    _KpiItem('ADR', '86.4', '+5.1', true, [
      78,
      82,
      80,
      86,
      84,
      90,
      88,
      91,
      83,
      94,
      87,
      89,
      92,
      86.4,
    ]),
    _KpiItem('HS%', '54%', '+3', true, [
      47,
      50,
      52,
      49,
      55,
      53,
      57,
      51,
      58,
      56,
      55,
      59,
      52,
      54,
    ]),
    _KpiItem('Win%', '52%', '-2', false, [
      56,
      54,
      58,
      51,
      55,
      52,
      49,
      57,
      53,
      50,
      52,
      48,
      51,
      52,
    ]),
    _KpiItem('Util DMG', '12.4', '+1.2', true, [
      9,
      10,
      12,
      11,
      13,
      10,
      14,
      12,
      13,
      15,
      11,
      14,
      13,
      12.4,
    ]),
    _KpiItem('Clutch%', '31%', '+4', true, [
      24,
      28,
      26,
      31,
      29,
      34,
      30,
      36,
      32,
      35,
      28,
      33,
      34,
      31,
    ]),
  ],
  winrateTrend: const [
    44,
    48,
    51,
    47,
    52,
    55,
    49,
    54,
    50,
    58,
    53,
    56,
    51,
    57,
    55,
    52,
  ],
  ratingTrend: const [
    1860,
    1880,
    1892,
    1904,
    1910,
    1922,
    1930,
    1948,
    1954,
    1962,
    1970,
    1960,
    1980,
    1991,
    2004,
    1984,
  ],
  radarLabels: const [
    'Aim',
    'Utility',
    'Position',
    'Clutch',
    'Economy',
    'Entry',
  ],
  radarYou: const [80, 61, 66, 72, 70, 58],
  radarAverage: const [70, 64, 65, 63, 66, 62],
  insights: const [
    _Insight(
      _InsightKind.weak,
      'PRIMARY LEAK',
      'Over-peeking on entry without trade setup',
      'You take first contact often but die un-traded. Anchor a trader before the swing.',
    ),
    _Insight(
      _InsightKind.strong,
      'STRENGTH',
      'Top-tier raw aim and HS%',
      'HS% sits top 9% of Premier. Your duel mechanics carry rounds.',
    ),
    _Insight(
      _InsightKind.focus,
      'FOCUS THIS WEEK',
      'Utility damage and default smokes',
      'Utility is your lowest pillar. Drill 3 map-default smoke sets and target 16+ util damage per round.',
    ),
  ],
  matches: const [
    _MatchItem('Mirage', 'MR', 'W', '24/16/5', '16-12', 'ADR 94', '1.28', '1h'),
    _MatchItem('Inferno', 'IN', 'W', '21/14/7', '16-9', 'ADR 88', '1.31', '3h'),
    _MatchItem(
      'Ancient',
      'AN',
      'L',
      '17/22/4',
      '11-16',
      'ADR 71',
      '0.86',
      '6h',
    ),
    _MatchItem('Nuke', 'NK', 'W', '27/18/6', '16-14', 'ADR 101', '1.34', '1d'),
    _MatchItem('Anubis', 'AB', 'L', '15/19/8', '13-16', 'ADR 76', '0.92', '1d'),
    _MatchItem(
      'Vertigo',
      'VT',
      'W',
      '23/15/5',
      '16-11',
      'ADR 90',
      '1.22',
      '2d',
    ),
  ],
  benchmarkCaption: 'vs Pro riflers - normalized',
  leaderboard: const [
    _LeaderItem('You', true, 68),
    _LeaderItem('s1mple', false, 97),
    _LeaderItem('ZywOo', false, 97),
    _LeaderItem('donk', false, 96),
  ],
  benchmarkBars: const [
    _BenchmarkItem('Aim', 86, 98),
    _BenchmarkItem('Util', 61, 90),
    _BenchmarkItem('Clutch', 72, 94),
    _BenchmarkItem('Impact', 70, 96),
  ],
  goals: const [
    _GoalItem('Util damage 16+ / round', 'current 12.4', 62),
    _GoalItem('Traded death rate < 35%', 'current 60%', 48),
    _GoalItem('Crosshair placement drills', '12 / 15 sessions', 80),
  ],
);

class _DashboardData {
  const _DashboardData({
    required this.product,
    required this.accent,
    required this.playerName,
    required this.accountId,
    required this.region,
    required this.rolesLine,
    required this.avatar,
    required this.rankTier,
    required this.rating,
    required this.ratingLabel,
    required this.ratingDelta,
    required this.percentile,
    required this.form,
    required this.seasonLabel,
    required this.score,
    required this.scoreDelta,
    required this.scoreCaption,
    required this.scoreBreakdown,
    required this.kpis,
    required this.winrateTrend,
    required this.ratingTrend,
    required this.radarLabels,
    required this.radarYou,
    required this.radarAverage,
    required this.insights,
    required this.matches,
    required this.benchmarkCaption,
    required this.leaderboard,
    required this.benchmarkBars,
    required this.goals,
  });

  final ProductDirection product;
  final Color accent;
  final String playerName;
  final String accountId;
  final String region;
  final String rolesLine;
  final String avatar;
  final String rankTier;
  final String rating;
  final String ratingLabel;
  final String ratingDelta;
  final String percentile;
  final String form;
  final String seasonLabel;
  final int score;
  final int scoreDelta;
  final String scoreCaption;
  final List<_MetricItem> scoreBreakdown;
  final List<_KpiItem> kpis;
  final List<double> winrateTrend;
  final List<double> ratingTrend;
  final List<String> radarLabels;
  final List<int> radarYou;
  final List<int> radarAverage;
  final List<_Insight> insights;
  final List<_MatchItem> matches;
  final String benchmarkCaption;
  final List<_LeaderItem> leaderboard;
  final List<_BenchmarkItem> benchmarkBars;
  final List<_GoalItem> goals;
}

class _MetricItem {
  const _MetricItem(this.label, this.value);

  final String label;
  final int value;
}

class _KpiItem {
  const _KpiItem(this.label, this.value, this.delta, this.up, this.spark);

  final String label;
  final String value;
  final String delta;
  final bool up;
  final List<double> spark;
}

class _Insight {
  const _Insight(this.kind, this.tag, this.title, this.body);

  final _InsightKind kind;
  final String tag;
  final String title;
  final String body;
}

enum _InsightKind { weak, strong, focus }

class _MatchItem {
  const _MatchItem(
    this.title,
    this.short,
    this.result,
    this.kda,
    this.metricA,
    this.metricB,
    this.impact,
    this.when,
  );

  final String title;
  final String short;
  final String result;
  final String kda;
  final String metricA;
  final String metricB;
  final String impact;
  final String when;
}

class _LeaderItem {
  const _LeaderItem(this.name, this.you, this.score);

  final String name;
  final bool you;
  final int score;
}

class _BenchmarkItem {
  const _BenchmarkItem(this.label, this.you, this.pro);

  final String label;
  final int you;
  final int pro;
}

class _GoalItem {
  const _GoalItem(this.label, this.subtitle, this.percent);

  final String label;
  final String subtitle;
  final int percent;
}
