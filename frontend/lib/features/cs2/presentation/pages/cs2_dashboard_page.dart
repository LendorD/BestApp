import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/cs2_grenades/data/cs2_grenades_providers.dart';
import '../../../../features/cs2_grenades/domain/cs2_models.dart';
import '../../../../features/cs2_grenades/presentation/cs2_grenades_page.dart';

class CS2DashboardPage extends ConsumerStatefulWidget {
  const CS2DashboardPage({super.key, this.initialMap});

  final String? initialMap;

  @override
  ConsumerState<CS2DashboardPage> createState() => _CS2DashboardPageState();
}

class _CS2DashboardPageState extends ConsumerState<CS2DashboardPage> {
  bool _appliedInitialMap = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appliedInitialMap) return;
    final map = widget.initialMap;
    if (map == null || map.isEmpty) return;
    _appliedInitialMap = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cs2FiltersProvider.notifier).state = const CS2GrenadeFilters()
          .copyWith(map: map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const CS2GrenadesPage();
  }
}
