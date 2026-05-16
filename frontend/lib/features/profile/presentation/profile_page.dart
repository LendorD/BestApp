import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          gradient: LinearGradient(
            colors: [
              GameMentorColors.purple.withValues(alpha: 0.2),
              GameMentorColors.green.withValues(alpha: 0.1),
            ],
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: GameMentorColors.purple,
                child: Icon(Icons.person_rounded, size: 34),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Player Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Favorites, Dota searches and training progress.',
                      style: TextStyle(color: GameMentorColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 920;
            final blocks = [
              const _ProfileBlock(
                title: 'Favorite grenades',
                icon: Icons.star_rounded,
                items: [
                  'Mirage window smoke',
                  'Inferno banana flash',
                  'Nuke hut molotov',
                ],
              ),
              const _ProfileBlock(
                title: 'Recent Dota searches',
                icon: Icons.history_rounded,
                items: ['123456789', '8675309', '42424242'],
              ),
              const _ProfileBlock(
                title: 'Training progress',
                icon: Icons.timeline_rounded,
                items: [
                  'Mirage utility 68%',
                  'Inferno flashes 42%',
                  'Hero pool 31%',
                ],
              ),
            ];
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: compact ? 1 : 3,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: compact ? 2 : 1.1,
              children: blocks,
            );
          },
        ),
      ],
    );
  }
}

class _ProfileBlock extends StatelessWidget {
  const _ProfileBlock({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: GameMentorColors.green),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.chevron_right_rounded, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: GameMentorColors.muted),
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
