import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/section_header.dart';
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
        const SizedBox(height: 16),
        _Cs2Kpis(activeFilters: filters.hasActiveFilters),
        const SizedBox(height: 16),
        _MapWorkflow(maps: maps, filters: filters),
        const SizedBox(height: 16),
        _FiltersBar(maps: maps, filters: filters),
        const SizedBox(height: 18),
        grenades.when(
          data: (items) {
            if (items.isEmpty) {
              return const EmptyState(
                title: 'Гранаты не найдены',
                message:
                    'Попробуй другую карту, сторону, тип гранаты, сложность или поисковый запрос.',
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
      padding: EdgeInsets.zero,
      radius: 16,
      hoverLift: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 230),
          child: Stack(
            children: [
              const Positioned.fill(
                child: AppNetworkImage(
                  imageUrl:
                      '/assets/gamementor/cs2/grenades/mirage-window-smoke.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.black.withValues(alpha: 0.88),
                        AppColors.black.withValues(alpha: 0.44),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 720;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  AppBadge(
                                    icon: Icons.grain_rounded,
                                    label: 'grenades',
                                  ),
                                  AppBadge(
                                    icon: Icons.map_rounded,
                                    label: 'maps',
                                    color: AppColors.cyan,
                                  ),
                                  AppBadge(
                                    icon: Icons.timeline_rounded,
                                    label: 'trajectories',
                                    color: AppColors.amber,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'CS2 Utility Database',
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      height: 1.02,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Гранаты, карты, траектории и тактические позиции в рабочей библиотеке без тяжёлых цветных оверлеев.',
                                style: TextStyle(
                                  color: AppColors.textSoft,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!compact) ...[
                          const SizedBox(width: 18),
                          AppBadge(
                            icon: filters.hasActiveFilters
                                ? Icons.tune_rounded
                                : Icons.all_inclusive_rounded,
                            label: filters.hasActiveFilters
                                ? 'Фильтры активны'
                                : 'Вся база',
                            color: filters.hasActiveFilters
                                ? AppColors.neon
                                : AppColors.muted,
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cs2Kpis extends StatelessWidget {
  const _Cs2Kpis({required this.activeFilters});

  final bool activeFilters;

  @override
  Widget build(BuildContext context) {
    final items = [
      _Cs2Kpi('500+', 'готовых гранат', Icons.grain_rounded, AppColors.neon),
      _Cs2Kpi('20+', 'карт и сценариев', Icons.map_rounded, AppColors.cyan),
      _Cs2Kpi('4', 'типа utility', Icons.category_rounded, AppColors.amber),
      _Cs2Kpi(
        activeFilters ? 'ON' : 'ALL',
        'режим фильтра',
        Icons.tune_rounded,
        activeFilters ? AppColors.neon : AppColors.muted,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 900
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
          childAspectRatio: columns == 1 ? 4.1 : 2.4,
          children: [for (final item in items) _Cs2KpiCard(item: item)],
        );
      },
    );
  }
}

class _Cs2KpiCard extends StatelessWidget {
  const _Cs2KpiCard({required this.item});

  final _Cs2Kpi item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Icon(item.icon, color: item.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapWorkflow extends ConsumerWidget {
  const _MapWorkflow({required this.maps, required this.filters});

  final List<CS2Map> maps;
  final CS2GrenadeFilters filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void update(CS2GrenadeFilters next) {
      ref.read(cs2FiltersProvider.notifier).state = next;
    }

    final mapItems = _mapItems(maps);
    return AppCard(
      hoverLift: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'CS2 map workflow',
            subtitle:
                'Open a map, pick a zone, then narrow utility type for the practice block.',
            trailing: AppBadge(
              icon: Icons.route_rounded,
              label: 'map -> zone -> utility',
              color: AppColors.cs2Accent,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 1100
                  ? 4
                  : constraints.maxWidth > 720
                  ? 3
                  : constraints.maxWidth > 460
                  ? 2
                  : 1;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: columns,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: columns == 1 ? 3.5 : 1.9,
                children: [
                  for (final item in mapItems)
                    _MapChoice(
                      item: item,
                      selected: filters.map == item.code,
                      onTap: () {
                        update(filters.copyWith(map: item.code));
                        context.go('/cs2/maps/${item.code}');
                      },
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _ZoneAndTypePicker(filters: filters, onChanged: update),
        ],
      ),
    );
  }
}

class _MapChoice extends StatelessWidget {
  const _MapChoice({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _Cs2MapItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.cs2Accent : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.black.withValues(alpha: 0.05),
                    AppColors.black.withValues(alpha: 0.66),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 11,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.cs2Accent,
                      size: 19,
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

class _ZoneAndTypePicker extends StatelessWidget {
  const _ZoneAndTypePicker({required this.filters, required this.onChanged});

  final CS2GrenadeFilters filters;
  final ValueChanged<CS2GrenadeFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    const zones = ['A site', 'B site', 'Mid', 'Spawn', 'Connector'];
    const types = {
      'smoke': ('Smoke', Icons.cloud_rounded),
      'flash': ('Flash', Icons.flash_on_rounded),
      'molotov': ('Molotov', Icons.local_fire_department_rounded),
      'he': ('HE', Icons.grain_rounded),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 740;
        final zoneBlock = _PickerBlock(
          title: 'Zone',
          children: [
            for (final zone in zones)
              ChoiceChip(
                selected: filters.search == zone,
                label: Text(zone),
                onSelected: (_) => onChanged(filters.copyWith(search: zone)),
              ),
          ],
        );
        final typeBlock = _PickerBlock(
          title: 'Utility',
          children: [
            for (final entry in types.entries)
              ChoiceChip(
                selected: filters.type == entry.key,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(entry.value.$2, size: 16),
                    const SizedBox(width: 6),
                    Text(entry.value.$1),
                  ],
                ),
                onSelected: (_) => onChanged(filters.copyWith(type: entry.key)),
              ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [zoneBlock, const SizedBox(height: 12), typeBlock],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: zoneBlock),
            const SizedBox(width: 18),
            Expanded(child: typeBlock),
          ],
        );
      },
    );
  }
}

class _PickerBlock extends StatelessWidget {
  const _PickerBlock({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: AppTypography.label),
        const SizedBox(height: 9),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
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
      hoverLift: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Фильтры библиотеки',
            subtitle: 'Быстро сузь базу по карте, стороне, типу и сложности.',
            trailing: TextButton.icon(
              onPressed: () => update(const CS2GrenadeFilters()),
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Сбросить'),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 780;
              final controls = [
                _SearchField(
                  initialValue: filters.search,
                  onChanged: (value) => update(filters.copyWith(search: value)),
                ),
                _Dropdown(
                  label: 'Карта',
                  value: filters.map,
                  values: {for (final map in maps) map.code: map.displayName},
                  onChanged: (value) =>
                      update(filters.copyWith(map: value ?? '')),
                ),
                _Dropdown(
                  label: 'Сторона',
                  value: filters.side,
                  values: const {'T': 'T side', 'CT': 'CT side'},
                  onChanged: (value) =>
                      update(filters.copyWith(side: value ?? '')),
                ),
                _Dropdown(
                  label: 'Тип',
                  value: filters.type,
                  values: const {
                    'smoke': 'Смок',
                    'flash': 'Флеш',
                    'molotov': 'Молотов',
                    'he': 'HE',
                  },
                  onChanged: (value) =>
                      update(filters.copyWith(type: value ?? '')),
                ),
                _Dropdown(
                  label: 'Сложность',
                  value: filters.difficulty,
                  values: const {
                    'easy': 'Легко',
                    'medium': 'Средне',
                    'hard': 'Сложно',
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
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 2, child: controls[0]),
                  const SizedBox(width: 12),
                  for (final control in controls.skip(1)) ...[
                    Expanded(child: control),
                    if (control != controls.last) const SizedBox(width: 12),
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
        hintText: 'Поиск по позиции, тегу или названию',
        prefixIcon: Icon(Icons.search_rounded),
        floatingLabelBehavior: FloatingLabelBehavior.never,
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
        const DropdownMenuItem<String>(value: '', child: Text('Все')),
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
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: columns == 1 ? 1.42 : 1.0,
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
    final typeColor = _typeColor(grenade.type);
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => context.go('/cs2/grenades/${grenade.id}'),
      borderColor: typeColor.withValues(alpha: 0.34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(imageUrl: grenade.imageUrl),
                Positioned(
                  left: 12,
                  top: 12,
                  right: 12,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppBadge(
                        label: grenade.map.toUpperCase(),
                        icon: Icons.map_rounded,
                        compact: true,
                        color: AppColors.neon,
                      ),
                      AppBadge(
                        label: grenade.type.toUpperCase(),
                        icon: _typeIcon(grenade.type),
                        compact: true,
                        color: typeColor,
                      ),
                      AppBadge(
                        label: grenade.side,
                        icon: Icons.flag_rounded,
                        compact: true,
                        color: AppColors.white,
                      ),
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
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 12),
                _RouteLine(from: grenade.fromPosition, to: grenade.toPosition),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _DifficultyPill(difficulty: grenade.difficulty),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Открыть карточку',
                      onPressed: () =>
                          context.go('/cs2/grenades/${grenade.id}'),
                      icon: const Icon(Icons.arrow_forward_rounded),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.place_rounded, color: AppColors.neon, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              from,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSoft),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 7),
            child: Icon(Icons.arrow_forward_rounded, size: 16),
          ),
          Expanded(
            child: Text(
              to,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyPill extends StatelessWidget {
  const _DifficultyPill({required this.difficulty});

  final String difficulty;

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      'easy' => AppColors.neon,
      'medium' => AppColors.amber,
      _ => AppColors.red,
    };
    final label = switch (difficulty) {
      'easy' => 'Лёгкая',
      'medium' => 'Средняя',
      _ => 'Сложная',
    };
    return AppBadge(
      icon: Icons.speed_rounded,
      label: label,
      color: color,
      compact: true,
    );
  }
}

Color _typeColor(String type) {
  return switch (type) {
    'smoke' => AppColors.cyan,
    'flash' => AppColors.amber,
    'molotov' => AppColors.red,
    'he' => AppColors.neon,
    _ => AppColors.muted,
  };
}

IconData _typeIcon(String type) {
  return switch (type) {
    'smoke' => Icons.cloud_rounded,
    'flash' => Icons.flash_on_rounded,
    'molotov' => Icons.local_fire_department_rounded,
    'he' => Icons.grain_rounded,
    _ => Icons.category_rounded,
  };
}

class _Cs2Kpi {
  const _Cs2Kpi(this.value, this.label, this.icon, this.color);

  final String value;
  final String label;
  final IconData icon;
  final Color color;
}

class _Cs2MapItem {
  const _Cs2MapItem(this.code, this.title, this.imageUrl);

  final String code;
  final String title;
  final String imageUrl;
}

List<_Cs2MapItem> _mapItems(List<CS2Map> maps) {
  final fromApi = {
    for (final map in maps)
      map.code: _Cs2MapItem(
        map.code,
        map.displayName,
        '/assets/gamementor/cs2/maps/${map.code}.jpg',
      ),
  };
  const requested = [
    _Cs2MapItem('mirage', 'Mirage', '/assets/gamementor/cs2/maps/mirage.jpg'),
    _Cs2MapItem(
      'inferno',
      'Inferno',
      '/assets/gamementor/cs2/maps/inferno.jpg',
    ),
    _Cs2MapItem('dust2', 'Dust 2', '/assets/gamementor/cs2/maps/dust2.jpg'),
    _Cs2MapItem(
      'ancient',
      'Ancient',
      '/assets/gamementor/cs2/maps/ancient.jpg',
    ),
    _Cs2MapItem('nuke', 'Nuke', '/assets/gamementor/cs2/maps/nuke.jpg'),
    _Cs2MapItem(
      'vertigo',
      'Vertigo',
      '/assets/gamementor/cs2/maps/vertigo.jpg',
    ),
    _Cs2MapItem(
      'overpass',
      'Overpass',
      '/assets/gamementor/cs2/maps/overpass.jpg',
    ),
    _Cs2MapItem('anubis', 'Anubis', '/assets/gamementor/cs2/maps/anubis.jpg'),
  ];
  return [for (final item in requested) fromApi[item.code] ?? item];
}
