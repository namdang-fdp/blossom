import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_config.dart';
import 'router.dart';

class NoApp extends StatefulWidget {
  const NoApp({super.key, required this.config});

  final AppConfig config;

  @override
  State<NoApp> createState() => _NoAppState();
}

class _NoAppState extends State<NoApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: widget.config.appName,
    debugShowCheckedModeBanner: false,
    locale: const Locale('vi'),
    supportedLocales: const [Locale('vi')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFBE185D)),
      scaffoldBackgroundColor: const Color(0xFFFFF8FA),
    ),
    routerConfig: _router,
  );
}
