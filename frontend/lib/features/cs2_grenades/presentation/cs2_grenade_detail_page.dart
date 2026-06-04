import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../data/cs2_grenades_providers.dart';
import '../domain/cs2_models.dart';

class CS2GrenadeDetailPage extends ConsumerWidget {
  const CS2GrenadeDetailPage({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grenade = ref.watch(cs2GrenadeProvider(id));

    return grenade.when(
      data: (item) => _DetailContent(grenade: item),
      loading: () => const LoadingState(rows: 4),
      error: (error, _) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(cs2GrenadeProvider(id)),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.grenade});

  final CS2Grenade grenade;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => context.go('/cs2'),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Назад к базе CS2'),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 940;
            final media = _MediaPanel(grenade: grenade);
            final info = _InstructionPanel(grenade: grenade);
            if (compact) {
              return Column(
                children: [media, const SizedBox(height: 16), info],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: media),
                const SizedBox(width: 16),
                Expanded(flex: 4, child: info),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MediaPanel extends StatelessWidget {
  const _MediaPanel({required this.grenade});

  final CS2Grenade grenade;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      radius: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(imageUrl: grenade.imageUrl),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.black.withValues(alpha: 0.68),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 22,
                right: 22,
                bottom: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppBadge(
                          icon: Icons.map_rounded,
                          label: grenade.map.toUpperCase(),
                        ),
                        AppBadge(
                          icon: _typeIcon(grenade.type),
                          label: grenade.type.toUpperCase(),
                          color: _typeColor(grenade.type),
                        ),
                        AppBadge(
                          icon: Icons.flag_rounded,
                          label: grenade.side,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      grenade.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900, height: 1.06),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionPanel extends StatelessWidget {
  const _InstructionPanel({required this.grenade});

  final CS2Grenade grenade;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Инструкция utility',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Короткая карточка для повторения позиции, цели и сложности.',
            style: AppTypography.bodyMuted,
          ),
          const SizedBox(height: 18),
          _InfoRow(
            label: 'Откуда бросать',
            value: grenade.fromPosition,
            icon: Icons.place_rounded,
            color: AppColors.neon,
          ),
          _InfoRow(
            label: 'Куда прилетает',
            value: grenade.toPosition,
            icon: Icons.flag_rounded,
            color: AppColors.cyan,
          ),
          _InfoRow(
            label: 'Сложность',
            value: _difficultyLabel(grenade.difficulty),
            icon: Icons.speed_rounded,
            color: _difficultyColor(grenade.difficulty),
          ),
          const SizedBox(height: 10),
          Text(grenade.description, style: AppTypography.bodyMuted),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in grenade.tags) Chip(label: Text('#$tag')),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: grenade.videoUrl.isEmpty ? null : () {},
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Смотреть видео'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.label),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
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

Color _difficultyColor(String difficulty) {
  return switch (difficulty) {
    'easy' => AppColors.neon,
    'medium' => AppColors.amber,
    _ => AppColors.red,
  };
}

String _difficultyLabel(String difficulty) {
  return switch (difficulty) {
    'easy' => 'Лёгкая',
    'medium' => 'Средняя',
    _ => 'Сложная',
  };
}
