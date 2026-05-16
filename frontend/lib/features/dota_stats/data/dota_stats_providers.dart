import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/dota_models.dart';
import 'dota_stats_api.dart';

final dotaAccountIdProvider = StateProvider<int?>((ref) => null);

final dotaAnalysisProvider = FutureProvider.autoDispose<DotaAnalysis?>((
  ref,
) async {
  final accountId = ref.watch(dotaAccountIdProvider);
  if (accountId == null) {
    return null;
  }
  final api = ref.watch(dotaStatsApiProvider);
  final playerFuture = api.getPlayer(accountId);
  final matchesFuture = api.getMatches(accountId);
  final summaryFuture = api.getSummary(accountId);
  final results = await Future.wait<dynamic>([
    playerFuture,
    matchesFuture,
    summaryFuture,
  ]);
  return DotaAnalysis(
    player: results[0] as DotaPlayer,
    matches: results[1] as List<DotaMatch>,
    summary: results[2] as DotaSummary,
  );
});
