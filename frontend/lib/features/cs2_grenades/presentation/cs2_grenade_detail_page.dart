import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_card.dart';
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
          label: const Text('Back to grenades'),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 920;
            final image = _HeroImage(grenade: grenade);
            final info = _InfoPanel(grenade: grenade);
            return compact
                ? Column(children: [image, const SizedBox(height: 18), info])
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: image),
                      const SizedBox(width: 18),
                      Expanded(flex: 2, child: info),
                    ],
                  );
          },
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.grenade});

  final CS2Grenade grenade;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                grenade.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: GameMentorColors.surfaceAlt,
                  child: const Icon(
                    Icons.image_not_supported_rounded,
                    size: 40,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      GameMentorColors.background.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text(grenade.map.toUpperCase())),
                        Chip(label: Text(grenade.type.toUpperCase())),
                        Chip(label: Text(grenade.side)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      grenade.title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
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

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.grenade});

  final CS2Grenade grenade;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lineup details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 18),
          _InfoRow(
            label: 'From',
            value: grenade.fromPosition,
            icon: Icons.place_rounded,
          ),
          _InfoRow(
            label: 'To',
            value: grenade.toPosition,
            icon: Icons.flag_rounded,
          ),
          _InfoRow(
            label: 'Difficulty',
            value: grenade.difficulty,
            icon: Icons.speed_rounded,
          ),
          const SizedBox(height: 14),
          Text(
            grenade.description,
            style: const TextStyle(color: GameMentorColors.muted, height: 1.55),
          ),
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
              label: const Text('Watch lineup video'),
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
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: GameMentorColors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: GameMentorColors.muted),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
