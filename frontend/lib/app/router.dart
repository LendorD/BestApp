import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_shell.dart';
import '../features/admin/presentation/admin_page.dart';
import '../features/cs2_grenades/presentation/cs2_grenade_detail_page.dart';
import '../features/cs2_grenades/presentation/cs2_grenades_page.dart';
import '../features/dota_stats/presentation/dota_stats_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/training/presentation/training_plans_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/cs2',
          name: 'cs2',
          builder: (context, state) => const CS2GrenadesPage(),
          routes: [
            GoRoute(
              path: ':id',
              name: 'cs2-detail',
              builder: (context, state) => CS2GrenadeDetailPage(
                id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/dota',
          name: 'dota',
          builder: (context, state) {
            final accountId = state.uri.queryParameters['account_id'];
            return DotaStatsPage(initialAccountId: accountId);
          },
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
          path: '/admin',
          name: 'admin',
          builder: (context, state) => const AdminPage(),
        ),
      ],
    ),
  ],
);
