import 'package:flutter/material.dart';

import 'config/env.dart';
import 'theme/app_theme.dart';
import 'routes/app_router.dart';

class MixeraApp extends StatelessWidget {
  const MixeraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Env.appName,
      debugShowCheckedModeBanner: Env.isDebug,
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.initialRoute,
    );
  }
}
