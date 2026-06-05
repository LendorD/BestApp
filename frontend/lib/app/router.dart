import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_shell.dart';
import '../features/admin/presentation/admin_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/cs2/presentation/pages/cs2_dashboard_page.dart';
import '../features/cs2/presentation/pages/cs2_training_page.dart';
import '../features/cs2_grenades/presentation/cs2_grenade_detail_page.dart';
import '../features/dashboard/presentation/game_dashboard_page.dart';
import '../features/dota/presentation/pages/dota_ai_coach_page.dart';
import '../features/dota/presentation/pages/dota_heroes_page.dart';
import '../features/dota/presentation/pages/dota_player_analysis_page.dart';
import '../features/product_switch/presentation/product_select_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/training/presentation/training_plans_page.dart';
import '../core/storage/product_preference.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/product-select',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', redirect: (_, _) => '/product-select'),
        GoRoute(
          path: '/product-select',
          name: 'product-select',
          builder: (context, state) => const ProductSelectPage(),
        ),
        GoRoute(
          path: '/cs2',
          name: 'cs2',
          builder: (context, state) =>
              const GameDashboardPage(product: ProductDirection.cs2),
          routes: [
            GoRoute(
              path: 'maps',
              name: 'cs2-maps',
              builder: (context, state) => const CS2DashboardPage(),
            ),
            GoRoute(
              path: 'maps/:map',
              name: 'cs2-map',
              builder: (context, state) =>
                  CS2DashboardPage(initialMap: state.pathParameters['map']),
            ),
            GoRoute(
              path: 'training',
              name: 'cs2-training',
              builder: (context, state) => const CS2TrainingPage(),
            ),
            GoRoute(
              path: 'sets',
              name: 'cs2-sets',
              builder: (context, state) => const CS2DashboardPage(),
            ),
            GoRoute(
              path: 'grenades',
              name: 'cs2-grenades',
              builder: (context, state) => const CS2DashboardPage(),
            ),
            GoRoute(
              path: 'ai-coach',
              name: 'cs2-ai-coach',
              builder: (context, state) => const CS2TrainingPage(),
            ),
            GoRoute(
              path: 'subscription',
              name: 'cs2-subscription',
              builder: (context, state) => const ProfilePage(),
            ),
            GoRoute(
              path: 'grenades/:id',
              name: 'cs2-detail',
              builder: (context, state) => CS2GrenadeDetailPage(
                id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
              ),
            ),
            GoRoute(
              path: ':id',
              name: 'cs2-legacy-detail',
              builder: (context, state) => CS2GrenadeDetailPage(
                id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/dota',
          name: 'dota',
          redirect: (context, state) {
            final accountId = state.uri.queryParameters['account_id'];
            if (accountId == null || accountId.trim().isEmpty) return null;
            return '/dota/player/${accountId.trim()}';
          },
          builder: (context, state) =>
              const GameDashboardPage(product: ProductDirection.dota),
          routes: [
            GoRoute(
              path: 'player/:id',
              name: 'dota-player',
              builder: (context, state) => DotaPlayerAnalysisPage(
                accountId: state.pathParameters['id'] ?? '',
              ),
            ),
            GoRoute(
              path: 'ai-coach',
              name: 'dota-ai-coach',
              builder: (context, state) => const DotaAICoachPage(),
            ),
            GoRoute(
              path: 'heroes',
              name: 'dota-heroes',
              builder: (context, state) => const DotaHeroesPage(),
            ),
            GoRoute(
              path: 'training',
              name: 'dota-training',
              builder: (context, state) => const TrainingPlansPage(),
            ),
            GoRoute(
              path: 'meta',
              name: 'dota-meta',
              builder: (context, state) => const DotaHeroesPage(),
            ),
            GoRoute(
              path: 'subscription',
              name: 'dota-subscription',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
        GoRoute(
          path: '/training',
          name: 'training',
          builder: (context, state) => const TrainingPlansPage(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/admin',
          name: 'admin',
          builder: (context, state) => const AdminPage(),
        ),
      ],
    ),
  ],
);
