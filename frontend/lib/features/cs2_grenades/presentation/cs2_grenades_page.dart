import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../data/cs2_grenades_providers.dart';
import '../domain/cs2_models.dart';

class CS2GrenadesPage extends ConsumerWidget {
  const CS2GrenadesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(cs2FiltersProvider);
    final grenades = ref.watch(cs2GrenadesProvider);
    final maps = ref.watch(cs2MapsProvider).valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageHeader(filters: filters),
        const SizedBox(height: 20),
        _FiltersBar(maps: maps, filters: filters),
        const SizedBox(height: 20),
        grenades.when(
          data: (items) {
            if (items.isEmpty) {
              return const EmptyState(
                title: 'No grenades found',
                message: 'Try another map, type, side or search phrase.',
                icon: Icons.filter_alt_off_rounded,
              );
            }
            return _GrenadeGrid(grenades: items);
          },
          loading: () => const LoadingState(rows: 5),
          error: (error, _) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(cs2GrenadesProvider),
          ),
        ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.filters});

  final CS2GrenadeFilters filters;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: LinearGradient(
        colors: [
          GameMentorColors.purple.withValues(alpha: 0.2),
          GameMentorColors.blue.withValues(alpha: 0.08),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CS2 Grenades',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Browse lineups by map, side, grenade type and difficulty.',
                  style: TextStyle(color: GameMentorColors.muted, height: 1.45),
                ),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width > 680)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: filters.hasActiveFilters
                    ? GameMentorColors.green.withValues(alpha: 0.18)
                    : GameMentorColors.surfaceAlt,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: GameMentorColors.border),
              ),
              child: Text(
                filters.hasActiveFilters ? 'Filtered view' : 'All utilities',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }
}

class _FiltersBar extends ConsumerWidget {
  const _FiltersBar({required this.maps, required this.filters});

  final List<CS2Map> maps;
  final CS2GrenadeFilters filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void update(CS2GrenadeFilters next) {
      ref.read(cs2FiltersProvider.notifier).state = next;
    }

    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final controls = [
            _SearchField(
              initialValue: filters.search,
              onChanged: (value) => update(filters.copyWith(search: value)),
            ),
            _Dropdown(
              label: 'Map',
              value: filters.map,
              values: {for (final map in maps) map.code: map.displayName},
              onChanged: (value) => update(filters.copyWith(map: value ?? '')),
            ),
            _Dropdown(
              label: 'Side',
              value: filters.side,
              values: const {'T': 'T Side', 'CT': 'CT Side'},
              onChanged: (value) => update(filters.copyWith(side: value ?? '')),
            ),
            _Dropdown(
              label: 'Type',
              value: filters.type,
              values: const {
                'smoke': 'Smoke',
                'flash': 'Flash',
                'molotov': 'Molotov',
                'he': 'HE',
              },
              onChanged: (value) => update(filters.copyWith(type: value ?? '')),
            ),
            _Dropdown(
              label: 'Difficulty',
              value: filters.difficulty,
              values: const {
                'easy': 'Easy',
                'medium': 'Medium',
                'hard': 'Hard',
              },
              onChanged: (value) =>
                  update(filters.copyWith(difficulty: value ?? '')),
            ),
          ];

          if (compact) {
            return Column(
              children: [
                for (final control in controls)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: control,
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => update(const CS2GrenadeFilters()),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Reset'),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 2, child: controls[0]),
                  const SizedBox(width: 12),
                  for (final control in controls.skip(1)) ...[
                    Expanded(child: control),
                    const SizedBox(width: 12),
                  ],
                  IconButton.filledTonal(
                    tooltip: 'Reset filters',
                    onPressed: () => update(const CS2GrenadeFilters()),
                    icon: const Icon(Icons.restart_alt_rounded),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        labelText: 'Search',
        prefixIcon: Icon(Icons.search_rounded),
      ),
      onChanged: widget.onChanged,
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Map<String, String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value.isEmpty ? null : value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem<String>(value: '', child: Text('All')),
        for (final entry in values.entries)
          DropdownMenuItem<String>(value: entry.key, child: Text(entry.value)),
      ],
      onChanged: onChanged,
    );
  }
}

class _GrenadeGrid extends StatelessWidget {
  const _GrenadeGrid({required this.grenades});

  final List<CS2Grenade> grenades;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 1180
            ? 3
            : constraints.maxWidth > 760
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: grenades.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: columns == 1 ? 1.05 : 0.88,
          ),
          itemBuilder: (context, index) =>
              _GrenadeCard(grenade: grenades[index]),
        );
      },
    );
  }
}

class _GrenadeCard extends StatelessWidget {
  const _GrenadeCard({required this.grenade});

  final CS2Grenade grenade;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => context.go('/cs2/${grenade.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  grenade.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: GameMentorColors.surfaceAlt,
                    child: const Icon(Icons.image_not_supported_rounded),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        GameMentorColors.background.withValues(alpha: 0.86),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniBadge(label: grenade.map.toUpperCase()),
                      _MiniBadge(label: grenade.type.toUpperCase()),
                      _MiniBadge(label: grenade.side),
                    ],
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
                  grenade.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                _RouteLine(from: grenade.fromPosition, to: grenade.toPosition),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _DifficultyPill(difficulty: grenade.difficulty),
                    const Spacer(),
                    IconButton.filledTonal(
                      tooltip: 'Open video',
                      onPressed: grenade.videoUrl.isEmpty ? null : () {},
                      icon: const Icon(Icons.play_arrow_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in grenade.tags.take(3))
                      Chip(label: Text('#$tag')),
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

class _RouteLine extends StatelessWidget {
  const _RouteLine({required this.from, required this.to});

  final String from;
  final String to;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.place_rounded,
          color: GameMentorColors.green,
          size: 18,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            from,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: GameMentorColors.muted),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.arrow_forward_rounded, size: 16),
        ),
        Expanded(
          child: Text(
            to,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: GameMentorColors.muted),
          ),
        ),
      ],
    );
  }
}

class _DifficultyPill extends StatelessWidget {
  const _DifficultyPill({required this.difficulty});

  final String difficulty;

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      'easy' => GameMentorColors.green,
      'medium' => GameMentorColors.amber,
      _ => GameMentorColors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: GameMentorColors.background.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
      ),
    );
  }
}
