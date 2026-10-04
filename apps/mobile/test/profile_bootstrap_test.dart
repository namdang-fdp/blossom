import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:no_mobile/app/app.dart';
import 'package:no_mobile/core/config/app_config.dart';
import 'package:no_mobile/data/local/app_database.dart';
import 'package:no_mobile/features/profile/guest_profile_repository.dart';
import 'package:no_mobile/features/profile/profile_bootstrap.dart';

final identity = ProfileIdentity(
  profile: LocalProfile(
    id: '11111111-1111-4111-8111-111111111111',
    createdAt: DateTime.utc(2026),
  ),
  deviceId: '22222222-2222-4222-8222-222222222222',
);

void main() {
  testWidgets('shell stays behind loading until identity commits', (
    tester,
  ) async {
    final committed = Completer<ProfileIdentity>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [guestProfileProvider.overrideWith((_) => committed.future)],
        child: const NoApp(config: AppConfig(AppEnvironment.dev)),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const ValueKey('tab/today')), findsNothing);
    committed.complete(identity);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('/today')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets(
    'failed startup requires retry and then opens committed profile',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guestProfileProvider.overrideWith((_) async {
              if (++calls == 1) throw StateError('private database path');
              return identity;
            }),
          ],
          child: const NoApp(config: AppConfig(AppEnvironment.dev)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('tab/today')), findsNothing);
      expect(find.textContaining('private database path'), findsNothing);
      expect(calls, 1); // No automatic identity bootstrap retry.
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(find.byKey(const ValueKey('/today')), findsOneWidget);
      final context = tester.element(find.byKey(const ValueKey('/today')));
      expect(
        ProviderScope.containerOf(
          context,
        ).read(guestProfileProvider).requireValue,
        same(identity),
      );
    },
  );

  testWidgets(
    'startup error and retry fit a small screen at 200 percent text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guestProfileProvider.overrideWith(
              (_) async => throw StateError('disk full'),
            ),
          ],
          child: const NoApp(config: AppConfig(AppEnvironment.dev)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Thử lại'));
      expect(tester.takeException(), isNull);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
    },
  );
}
