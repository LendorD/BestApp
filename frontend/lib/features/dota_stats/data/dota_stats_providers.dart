import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/dota_models.dart';
import 'dota_stats_api.dart';

final dotaAccountIdProvider = StateProvider<int?>((ref) => null);
final dotaAnalysisQueryProvider = StateProvider<DotaAnalysisQuery?>(
  (ref) => null,
);

class DotaAnalysisQuery {
  const DotaAnalysisQuery({
    required this.accountId,
    required this.period,
    required this.role,
  });

  final int accountId;
  final String period;
  final String role;
}

final dotaAnalysisProvider = FutureProvider.autoDispose<DotaAnalysis?>((
  ref,
) async {
  final query = ref.watch(dotaAnalysisQueryProvider);
  if (query == null) {
    return null;
  }
  final api = ref.watch(dotaStatsApiProvider);
  return api.getAnalysis(
    query.accountId,
    period: query.period,
    role: query.role,
  );
});
