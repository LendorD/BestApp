import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../config/app_config.dart';
import '../storage/product_preference.dart';
import 'app_badge.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final product = ProductDirection.fromPath(path);
    final isProductSelect = product == null;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1120;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _BackgroundStage(),
          if (isProductSelect)
            _ProductSelectWorkspace(child: child)
          else if (isDesktop)
            Row(
              children: [
                _DesktopSidebar(product: product),
                Expanded(
                  child: _DesktopWorkspace(product: product, child: child),
                ),
              ],
            )
          else
            _MobileWorkspace(product: product, child: child),
        ],
      ),
    );
  }
}

class _ProductSelectWorkspace extends StatelessWidget {
  const _ProductSelectWorkspace({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: AppSpacing.pageDesktop,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DesktopWorkspace extends StatelessWidget {
  const _DesktopWorkspace({required this.product, required this.child});

  final ProductDirection product;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _TopBar(product: product),
          Expanded(child: _PageSurface(desktop: true, child: child)),
        ],
      ),
    );
  }
}

class _MobileWorkspace extends StatelessWidget {
  const _MobileWorkspace({required this.product, required this.child});

  final ProductDirection product;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        titleSpacing: 16,
        title: _BrandMark(product: product, compact: true),
        actions: [
          _MobileProductMenu(product: product),
          const Padding(padding: EdgeInsets.only(right: 12), child: _ApiDot()),
        ],
      ),
      body: SafeArea(child: _PageSurface(desktop: false, child: child)),
      bottomNavigationBar: _MobileNav(product: product),
    );
  }
}

class _PageSurface extends StatelessWidget {
  const _PageSurface({required this.child, required this.desktop});

  final Widget child;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: desktop ? AppSpacing.pageDesktop : AppSpacing.pageMobile,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: child,
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.product});

  final ProductDirection product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 28, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(child: _TopContext(product: product)),
            const SizedBox(width: 12),
            AppBadge(
              icon: Icons.workspace_premium_rounded,
              label: 'Subscription product',
              color: AppColors.warningPro,
            ),
            const SizedBox(width: 10),
            const _ApiModeBadge(compact: true),
          ],
        ),
      ),
    );
  }
}

class _TopContext extends StatelessWidget {
  const _TopContext({required this.product});

  final ProductDirection product;

  @override
  Widget build(BuildContext context) {
    final accent = _productAccent(product);
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accent.withValues(alpha: 0.45)),
          ),
          child: Icon(_productIcon(product), color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product.label,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(
                _productSubtitle(product),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({required this.product});

  final ProductDirection product;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 270,
        margin: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.panel,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BrandMark(product: product),
            const SizedBox(height: 18),
            _ProductSwitcher(product: product),
            const SizedBox(height: 20),
            const _SidebarSectionLabel('Menu'),
            const SizedBox(height: 8),
            for (final item in _navFor(product)) _NavButton(item: item),
            const Spacer(),
            const _SidebarSectionLabel('Status'),
            const SizedBox(height: 8),
            const _ApiModeBadge(),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.product, this.compact = false});

  final ProductDirection product;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = _productAccent(product);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 38 : 44,
          height: compact ? 38 : 44,
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accent),
          ),
          child: Icon(_productIcon(product), color: accent),
        ),
        const SizedBox(width: 12),
        if (!compact || MediaQuery.sizeOf(context).width > 360)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GameMentor',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19),
              ),
              const SizedBox(height: 1),
              Text(
                product.label,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ProductSwitcher extends StatelessWidget {
  const _ProductSwitcher({required this.product});

  final ProductDirection product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.black,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          for (final item in ProductDirection.values)
            Expanded(
              child: _ProductSwitchButton(
                product: item,
                selected: item == product,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductSwitchButton extends StatelessWidget {
  const _ProductSwitchButton({required this.product, required this.selected});

  final ProductDirection product;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final accent = _productAccent(product);
    return TextButton(
      onPressed: () {
        ProductPreference.save(product);
        context.go(product.path);
      },
      style: TextButton.styleFrom(
        foregroundColor: selected ? AppColors.black : AppColors.muted,
        backgroundColor: selected ? accent : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: Text(product == ProductDirection.dota ? 'Dota 2' : 'CS2'),
    );
  }
}

class _MobileProductMenu extends StatelessWidget {
  const _MobileProductMenu({required this.product});

  final ProductDirection product;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProductDirection>(
      icon: const Icon(Icons.swap_horiz_rounded),
      tooltip: 'Switch product',
      onSelected: (value) {
        ProductPreference.save(value);
        context.go(value.path);
      },
      itemBuilder: (context) => [
        for (final item in ProductDirection.values)
          PopupMenuItem(value: item, child: Text(item.label)),
      ],
    );
  }
}

class _SidebarSectionLabel extends StatelessWidget {
  const _SidebarSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(), style: AppTypography.label);
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item});

  final _NavItem item;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final selected =
        item.path == currentPath ||
        (item.path != '/dota' &&
            item.path != '/cs2' &&
            currentPath.startsWith(item.path));
    final accent = item.accent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.go(item.path),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.5)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: selected ? accent : AppColors.muted,
                size: 20,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? AppColors.text : AppColors.muted,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
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
  const _MobileNav({required this.product});

  final ProductDirection product;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final items = _navFor(product).take(5).toList();
    final selectedIndex = items.indexWhere((item) {
      if (item.path == product.path) return currentPath == product.path;
      return currentPath.startsWith(item.path);
    });

    return NavigationBar(
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      destinations: [
        for (final item in items)
          NavigationDestination(icon: Icon(item.icon), label: item.shortLabel),
      ],
      onDestinationSelected: (index) => context.go(items[index].path),
    );
  }
}

class _ApiModeBadge extends StatelessWidget {
  const _ApiModeBadge({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final mockMode = AppConfig.useMockApi;
    final color = mockMode ? AppColors.warningPro : AppColors.dotaAccent;
    final title = mockMode ? 'Demo mode' : 'Live API';
    final body = mockMode ? 'Mock data enabled' : AppConfig.apiBaseUrl;

    if (compact) {
      return AppBadge(
        icon: mockMode ? Icons.bolt_rounded : Icons.cloud_done_rounded,
        label: title,
        color: color,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                mockMode ? Icons.bolt_rounded : Icons.cloud_done_rounded,
                color: color,
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.muted,
              height: 1.35,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiDot extends StatelessWidget {
  const _ApiDot();

  @override
  Widget build(BuildContext context) {
    final color = AppConfig.useMockApi
        ? AppColors.warningPro
        : AppColors.dotaAccent;
    return Tooltip(
      message: AppConfig.useMockApi ? 'Demo mode' : 'Live API',
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.42)),
        ),
        child: Icon(Icons.hub_rounded, color: color, size: 18),
      ),
    );
  }
}

class _BackgroundStage extends StatelessWidget {
  const _BackgroundStage();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.background),
        child: CustomPaint(painter: _GridPainter()),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;

    const step = 56.0;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NavItem {
  const _NavItem(
    this.label,
    this.shortLabel,
    this.path,
    this.icon,
    this.accent,
  );

  final String label;
  final String shortLabel;
  final String path;
  final IconData icon;
  final Color accent;
}

List<_NavItem> _navFor(ProductDirection product) {
  return switch (product) {
    ProductDirection.dota => const [
      _NavItem(
        'Dashboard',
        'Home',
        '/dota',
        Icons.dashboard_rounded,
        AppColors.dotaAccent,
      ),
      _NavItem(
        'Мой профиль',
        'Профиль',
        '/dota?account_id=369102305',
        Icons.person_search_rounded,
        AppColors.dotaAccent,
      ),
      _NavItem(
        'AI Coach',
        'Coach',
        '/dota/ai-coach',
        Icons.psychology_alt_rounded,
        AppColors.warningPro,
      ),
      _NavItem(
        'Match Review',
        'Review',
        '/dota',
        Icons.manage_search_rounded,
        AppColors.dotaAccent,
      ),
      _NavItem(
        'Heroes',
        'Heroes',
        '/dota/heroes',
        Icons.view_in_ar_rounded,
        AppColors.dotaAccent,
      ),
      _NavItem(
        'Training',
        'Train',
        '/dota/training',
        Icons.fitness_center_rounded,
        AppColors.warningPro,
      ),
      _NavItem(
        'Meta',
        'Meta',
        '/dota/meta',
        Icons.auto_graph_rounded,
        AppColors.dotaAccent,
      ),
      _NavItem(
        'Subscription',
        'Pro',
        '/dota/subscription',
        Icons.workspace_premium_rounded,
        AppColors.warningPro,
      ),
    ],
    ProductDirection.cs2 => const [
      _NavItem('Maps', 'Maps', '/cs2', Icons.map_rounded, AppColors.cs2Accent),
      _NavItem(
        'Grenades',
        'Nades',
        '/cs2/grenades',
        Icons.grain_rounded,
        AppColors.cs2Accent,
      ),
      _NavItem(
        'Training',
        'Train',
        '/cs2/training',
        Icons.fitness_center_rounded,
        AppColors.warningPro,
      ),
      _NavItem(
        'Utility Sets',
        'Sets',
        '/cs2/sets',
        Icons.view_module_rounded,
        AppColors.cs2Accent,
      ),
      _NavItem(
        'AI Coach',
        'Coach',
        '/cs2/ai-coach',
        Icons.psychology_alt_rounded,
        AppColors.warningPro,
      ),
      _NavItem(
        'Subscription',
        'Pro',
        '/cs2/subscription',
        Icons.workspace_premium_rounded,
        AppColors.warningPro,
      ),
    ],
  };
}

Color _productAccent(ProductDirection product) {
  return switch (product) {
    ProductDirection.dota => AppColors.dotaAccent,
    ProductDirection.cs2 => AppColors.cs2Accent,
  };
}

IconData _productIcon(ProductDirection product) {
  return switch (product) {
    ProductDirection.dota => Icons.query_stats_rounded,
    ProductDirection.cs2 => Icons.radar_rounded,
  };
}

String _productSubtitle(ProductDirection product) {
  return switch (product) {
    ProductDirection.dota => 'Profile analytics, AI coach, hero pool',
    ProductDirection.cs2 => 'Maps, positions, grenades, training sets',
  };
}
