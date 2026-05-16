import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cs2_models.dart';
import 'cs2_grenades_api.dart';

final cs2MapsProvider = FutureProvider<List<CS2Map>>((ref) {
  return ref.watch(cs2GrenadesApiProvider).getMaps();
});

final cs2FiltersProvider = StateProvider<CS2GrenadeFilters>((ref) {
  return const CS2GrenadeFilters();
});

final cs2GrenadesProvider = FutureProvider.autoDispose<List<CS2Grenade>>((
  ref,
) async {
  final filters = ref.watch(cs2FiltersProvider);
  final api = ref.watch(cs2GrenadesApiProvider);
  final grenades = await api.getGrenades(
    map: filters.map,
    side: filters.side,
    type: filters.type,
    difficulty: filters.difficulty,
  );
  final search = filters.search.trim().toLowerCase();
  if (search.isEmpty) {
    return grenades;
  }
  return grenades.where((grenade) {
    return grenade.title.toLowerCase().contains(search) ||
        grenade.fromPosition.toLowerCase().contains(search) ||
        grenade.toPosition.toLowerCase().contains(search) ||
        grenade.tags.any((tag) => tag.toLowerCase().contains(search));
  }).toList();
});

final cs2GrenadeProvider = FutureProvider.autoDispose.family<CS2Grenade, int>((
  ref,
  id,
) {
  return ref.watch(cs2GrenadesApiProvider).getGrenade(id);
});
