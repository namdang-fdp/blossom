import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:no_mobile/data/local/app_database.dart';
import 'package:no_mobile/features/profile/profile_bootstrap.dart';
import 'package:no_mobile/features/profile/guest_profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:no_mobile/app/app.dart';
import 'package:no_mobile/core/config/app_config.dart';
import 'package:no_mobile/features/scaffold/scaffold_page.dart';

void main() {
  Future<void> start(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          guestProfileProvider.overrideWith(
            (_) async => ProfileIdentity(
              profile: LocalProfile(
                id: '11111111-1111-4111-8111-111111111111',
                createdAt: DateTime.utc(2026),
              ),
              deviceId: '22222222-2222-4222-8222-222222222222',
            ),
          ),
        ],
        child: const NoApp(config: AppConfig(AppEnvironment.dev)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tab(WidgetTester tester, String route) async {
    await tester.tap(find.byKey(ValueKey('tab/$route')));
    await tester.pumpAndSettle();
  }

  testWidgets('all four tabs are reachable without authentication', (
    tester,
  ) async {
    await start(tester);
    for (final route in ['today', 'library', 'practice', 'garden']) {
      await tab(tester, route);
      expect(find.byKey(ValueKey('/$route')), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('switching tabs retains each branch navigation stack', (
    tester,
  ) async {
    await start(tester);
    await tab(tester, 'library');
    final context = tester.element(find.byType(ScaffoldPage));
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => const Scaffold(body: Text('Branch detail')),
      ),
    );
    await tester.pumpAndSettle();
    await tab(tester, 'practice');
    expect(find.text('Branch detail'), findsNothing);
    await tab(tester, 'library');
    expect(find.text('Branch detail'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('/library')), findsOneWidget);
  });

  testWidgets('Android Back returns a secondary tab to Today', (tester) async {
    await start(tester);
    await tab(tester, 'garden');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('/today')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small screen supports 200 percent text without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await start(tester);
    for (final route in ['today', 'library', 'practice', 'garden']) {
      await tab(tester, route);
      expect(tester.takeException(), isNull);
    }
  });
}
