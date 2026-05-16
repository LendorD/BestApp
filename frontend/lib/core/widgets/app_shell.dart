import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1120;

    return Scaffold(
      backgroundColor: GameMentorColors.background,
      body: Stack(
        children: [
          const _BackgroundGlow(),
          if (isDesktop)
            Row(
              children: [
                const _DesktopSidebar(),
                Expanded(child: _PageSurface(child: child)),
              ],
            )
          else
            _MobileShell(child: child),
        ],
      ),
    );
  }
}

class _PageSurface extends StatelessWidget {
  const _PageSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: GameMentorColors.background.withValues(alpha: 0.86),
        title: const _BrandMark(compact: true),
      ),
      body: _PageSurface(child: child),
      bottomNavigationBar: const _MobileNav(),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 264,
        margin: const EdgeInsets.fromLTRB(18, 18, 8, 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: GameMentorColors.surface.withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: GameMentorColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _BrandMark(),
            const SizedBox(height: 30),
            for (final item in _navItems) _NavButton(item: item),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [
                    GameMentorColors.green.withValues(alpha: 0.22),
                    GameMentorColors.blue.withValues(alpha: 0.16),
                  ],
                ),
                border: Border.all(
                  color: GameMentorColors.green.withValues(alpha: 0.35),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.bolt_rounded, color: GameMentorColors.green),
                  SizedBox(height: 10),
                  Text(
                    'Mock mode active',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Switch with dart-define when backend is running.',
                    style: TextStyle(
                      color: GameMentorColors.muted,
                      height: 1.35,
                    ),
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

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [GameMentorColors.purple, GameMentorColors.blue],
            ),
          ),
          child: const Icon(Icons.sports_esports_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        if (!compact || MediaQuery.sizeOf(context).width > 360)
          const Text(
            'GameMentor',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item});

  final _NavItem item;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final selected = item.path == '/'
        ? currentPath == '/'
        : currentPath == item.path || currentPath.startsWith('${item.path}/');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.go(item.path),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: selected
                ? GameMentorColors.purple.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? GameMentorColors.purple : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: selected
                    ? GameMentorColors.green
                    : GameMentorColors.muted,
                size: 21,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: selected
                        ? GameMentorColors.text
                        : GameMentorColors.muted,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileNav extends StatelessWidget {
  const _MobileNav();

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final visibleItems = _navItems.take(5).toList();
    final selectedIndex = visibleItems.indexWhere((item) {
      return item.path == '/'
          ? currentPath == '/'
          : currentPath.startsWith(item.path);
    });

    return NavigationBar(
      backgroundColor: GameMentorColors.surface,
      indicatorColor: GameMentorColors.purple.withValues(alpha: 0.24),
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      destinations: [
        for (final item in visibleItems)
          NavigationDestination(icon: Icon(item.icon), label: item.shortLabel),
      ],
      onDestinationSelected: (index) => context.go(visibleItems[index].path),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.8, -0.8),
            radius: 1.25,
            colors: [
              GameMentorColors.purple.withValues(alpha: 0.22),
              GameMentorColors.background,
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.shortLabel, this.path, this.icon);

  final String label;
  final String shortLabel;
  final String path;
  final IconData icon;
}

const _navItems = [
  _NavItem('Home', 'Home', '/', Icons.grid_view_rounded),
  _NavItem('CS2 Grenades', 'CS2', '/cs2', Icons.track_changes_rounded),
  _NavItem('Dota 2 Stats', 'Dota', '/dota', Icons.query_stats_rounded),
  _NavItem(
    'Training Plans',
    'Train',
    '/training',
    Icons.fitness_center_rounded,
  ),
  _NavItem('Profile', 'Profile', '/profile', Icons.person_rounded),
  _NavItem(
    'Admin Panel',
    'Admin',
    '/admin',
    Icons.admin_panel_settings_rounded,
  ),
];
