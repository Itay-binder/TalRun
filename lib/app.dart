import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:talrun/router/app_router.dart';
import 'package:talrun/theme/app_theme.dart';

class TalRunApp extends StatefulWidget {
  const TalRunApp({super.key});

  @override
  State<TalRunApp> createState() => _TalRunAppState();
}

class _TalRunAppState extends State<TalRunApp> {
  late final GoRouter _router = createAppRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TalRun',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('he', 'IL'),
      supportedLocales: const [
        Locale('he', 'IL'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}
