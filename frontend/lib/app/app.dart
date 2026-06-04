import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class GameMentorApp extends StatelessWidget {
  const GameMentorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GameMentor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: appRouter,
    );
  }
}
