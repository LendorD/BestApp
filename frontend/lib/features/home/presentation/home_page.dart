import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _accountController = TextEditingController(text: '123456789');

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
        _HeroSection(accountController: _accountController),
        const SizedBox(height: 26),
        _FeatureCards(accountController: _accountController),
        const SizedBox(height: 26),
        const _HowItWorks(),
        const SizedBox(height: 26),
        _PopularMaps(accountController: _accountController),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.accountController});

  final TextEditingController accountController;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 430),
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          image: NetworkImage(
            'https://cdn.cloudflare.steamstatic.com/apps/csgo/images/csgo_react/social/cs2.jpg',
          ),
          fit: BoxFit.cover,
          opacity: 0.28,
        ),
        border: Border.all(color: GameMentorColors.border),
        gradient: LinearGradient(
          colors: [
            GameMentorColors.purple.withValues(alpha: 0.36),
            GameMentorColors.background.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: GameMentorColors.green.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: GameMentorColors.green.withValues(alpha: 0.35),
                  ),
                ),
                child: const Text(
                  'Гранаты CS2 + аналитика Dota 2',
                  style: TextStyle(
                    color: GameMentorColors.green,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Тренируй гранаты CS2 и решения в Dota 2',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.02,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Изучай точные раскидки, анализируй профиль OpenDota и превращай историю матчей в понятный план тренировки.',
                style: TextStyle(
                  color: GameMentorColors.muted,
                  fontSize: 18,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.go('/cs2'),
                    icon: const Icon(Icons.track_changes_rounded),
                    label: const Text('Открыть гранаты'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      final value = accountController.text.trim();
                      context.go(
                        value.isEmpty ? '/dota' : '/dota?account_id=$value',
                      );
                    },
                    icon: const Icon(Icons.query_stats_rounded),
                    label: const Text('Анализ Dota'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCards extends StatelessWidget {
  const _FeatureCards({required this.accountController});

  final TextEditingController accountController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 900 ? 2 : 1;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: columns == 2 ? 1.9 : 1.25,
          children: [
            _BigFeatureCard(
              title: 'Гранаты CS2',
              label: 'Карты, позиции, сложность',
              icon: Icons.radar_rounded,
              colors: const [GameMentorColors.purple, GameMentorColors.blue],
              imageUrl:
                  'https://cdn.cloudflare.steamstatic.com/apps/csgo/images/csgo_react//cs2/header_ctt.png',
              onTap: () => context.go('/cs2'),
            ),
            _BigFeatureCard(
              title: 'Аналитика Dota 2',
              label: 'Винрейт, KDA, герои',
              icon: Icons.auto_graph_rounded,
              colors: const [GameMentorColors.green, GameMentorColors.blue],
              imageUrl:
                  'https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota_react/heroes/social/invoker.jpg',
              onTap: () {
                final value = accountController.text.trim();
                context.go(value.isEmpty ? '/dota' : '/dota?account_id=$value');
              },
            ),
          ],
        );
      },
    );
  }
}

class _BigFeatureCard extends StatelessWidget {
  const _BigFeatureCard({
    required this.title,
    required this.label,
    required this.icon,
    required this.colors,
    required this.onTap,
    this.imageUrl,
  });

  final String title;
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      gradient: LinearGradient(
        colors: [
          colors.first.withValues(alpha: 0.26),
          colors.last.withValues(alpha: 0.12),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.18,
                child: Image.network(imageUrl!, fit: BoxFit.cover),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: colors.first, size: 42),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(color: GameMentorColors.muted),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Выбери слабое место', 'CS2 utility или анализ профиля Dota 2.'),
      ('Посмотри сигнал', 'Карты, герои, KDA, экономика и частые ошибки.'),
      ('Закрепи тренировкой', 'Переходи к короткому плану практики.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Как это работает'),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 900 ? 3 : 1;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: columns == 3 ? 1.6 : 2.8,
              children: [
                for (final item in items)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.$2,
                          style: const TextStyle(
                            color: GameMentorColors.muted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PopularMaps extends StatelessWidget {
  const _PopularMaps({required this.accountController});

  final TextEditingController accountController;

  @override
  Widget build(BuildContext context) {
    final maps = [
      'Mirage',
      'Inferno',
      'Dust2',
      'Nuke',
      'Ancient',
      'Anubis',
      'Vertigo',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Популярные карты CS2'),
        const SizedBox(height: 14),
        AppCard(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final map in maps)
                ActionChip(
                  label: Text(map),
                  avatar: const Icon(Icons.map_rounded, size: 18),
                  onPressed: () => context.go('/cs2'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AppCard(
          gradient: LinearGradient(
            colors: [
              GameMentorColors.blue.withValues(alpha: 0.18),
              GameMentorColors.green.withValues(alpha: 0.1),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;
              final input = TextField(
                controller: accountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Dota account ID',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
                onSubmitted: (value) =>
                    context.go('/dota?account_id=${value.trim()}'),
              );
              final button = ElevatedButton.icon(
                onPressed: () {
                  final value = accountController.text.trim();
                  context.go(
                    value.isEmpty ? '/dota' : '/dota?account_id=$value',
                  );
                },
                icon: const Icon(Icons.search_rounded),
                label: const Text('Проанализировать Dota профиль'),
              );
              return compact
                  ? Column(
                      children: [input, const SizedBox(height: 12), button],
                    )
                  : Row(
                      children: [
                        Expanded(child: input),
                        const SizedBox(width: 12),
                        button,
                      ],
                    );
            },
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}
