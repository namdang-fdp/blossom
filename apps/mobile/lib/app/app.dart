import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_config.dart';
import '../features/profile/profile_bootstrap.dart';
import 'router.dart';

class NoApp extends ConsumerStatefulWidget {
  const NoApp({super.key, required this.config});

  final AppConfig config;

  @override
  ConsumerState<NoApp> createState() => _NoAppState();
}

class _NoAppState extends ConsumerState<NoApp> {
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
    theme: _createLightTheme(),
    routerConfig: _router,
    builder: (context, child) => ref
        .watch(guestProfileProvider)
        .when(
          skipLoadingOnRefresh: false,
          data: (_) => child ?? const SizedBox.shrink(),
          loading: () => const ProfileBootstrap(),
          error: (_, _) => ProfileBootstrap(
            onRetry: () => ref.invalidate(guestProfileProvider),
          ),
        ),
  );
}

// Scaffold baseline from docs/ux.md; the full component system belongs to NO-006.
ThemeData _createLightTheme() {
  final colors = ColorScheme.fromSeed(seedColor: const Color(0xFFE85D86))
      .copyWith(
        primary: const Color(0xFFC43D68),
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFFFF0F4),
        onPrimaryContainer: const Color(0xFF1F2937),
        surface: Colors.white,
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: const Color(0xFFF7F8FA),
        surfaceContainer: const Color(0xFFF7F8FA),
        surfaceContainerHigh: const Color(0xFFF7F8FA),
        surfaceContainerHighest: const Color(0xFFF7F8FA),
        onSurface: const Color(0xFF1F2937),
        onSurfaceVariant: const Color(0xFF667085),
        surfaceTint: Colors.transparent,
      );
  return ThemeData(
    colorScheme: colors,
    scaffoldBackgroundColor: colors.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surface,
      indicatorColor: colors.primaryContainer,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
