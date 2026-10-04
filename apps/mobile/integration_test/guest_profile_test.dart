import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:no_mobile/data/local/app_database.dart';
import 'package:no_mobile/features/profile/guest_profile_repository.dart';
import 'package:no_mobile/features/profile/profile_bootstrap.dart';
import 'package:no_mobile/main.dart' as app;
import 'package:path_provider/path_provider.dart';

import '../test/data/local/generated/app_database/generated/schema_v1.dart'
    as v1;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('real app commits and reopens the same local guest', (
    tester,
  ) async {
    app.main();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('/today')), findsOneWidget);
    final context = tester.element(find.byKey(const ValueKey('/today')));
    final container = ProviderScope.containerOf(context);
    final first = container.read(guestProfileProvider).requireValue;
    final db = container.read(appDatabaseProvider);
    expect(await db.select(db.localProfiles).get(), hasLength(1));
    expect(await db.select(db.installations).get(), hasLength(1));

    // Dispose the provider-owned connection, then bootstrap from its real file.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await db.close();
    app.main();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    final reopenedContext = tester.element(
      find.byKey(const ValueKey('/today')),
    );
    final second = ProviderScope.containerOf(
      reopenedContext,
    ).read(guestProfileProvider).requireValue;
    expect(second.profile.id, first.profile.id);
    expect(second.deviceId, first.deviceId);
    expect(second.profile.createdAt, first.profile.createdAt);
    expect(second.profile.displayName, first.profile.displayName);
  });

  testWidgets(
    'Android upgrades a populated v1 SQLite file without changing identity',
    (tester) async {
      final temp = await getTemporaryDirectory();
      final dir = await temp.createTemp('guest-upgrade-');
      final file = File('${dir.path}/fixture.sqlite');
      const profile = '11111111-1111-4111-8111-111111111111';
      const device = '22222222-2222-4222-8222-222222222222';
      final old = v1.DatabaseAtV1(NativeDatabase(file));
      try {
        await old
            .into(old.localProfiles)
            .insert(
              const v1.LocalProfilesData(id: profile, createdAt: 1791072000),
            );
        await old
            .into(old.installations)
            .insert(
              const v1.InstallationsData(
                singleton: 1,
                deviceId: device,
                activeProfileId: profile,
              ),
            );
      } finally {
        await old.close();
      }
      final upgraded = AppDatabase(NativeDatabase(file));
      try {
        final repo = GuestProfileRepository(upgraded);
        final saved = await repo.ensureGuestProfile();
        expect(saved.profile.id, profile);
        expect(saved.deviceId, device);
        expect(saved.profile.displayName, isNull);
        expect(
          saved.profile.createdAt.toUtc(),
          DateTime.fromMillisecondsSinceEpoch(1791072000000, isUtc: true),
        );
        await repo.withProfile(profile, (scope) => scope.rename('Fixture'));
        expect((await repo.readProfile(profile)).displayName, 'Fixture');
        expect(
          (await upgraded.customSelect('PRAGMA user_version').getSingle())
              .read<int>('user_version'),
          2,
        );
      } finally {
        await upgraded.close();
        await dir.delete(recursive: true);
      }
    },
  );
}
