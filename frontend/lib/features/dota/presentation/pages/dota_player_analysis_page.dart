import 'package:flutter/material.dart';

import '../../../../features/dota_stats/presentation/dota_stats_page.dart';

class DotaPlayerAnalysisPage extends StatelessWidget {
  const DotaPlayerAnalysisPage({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context) {
    return DotaStatsPage(initialAccountId: accountId);
  }
}
