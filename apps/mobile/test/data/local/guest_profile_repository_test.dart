import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:no_mobile/data/local/app_database.dart';
import 'package:no_mobile/features/profile/guest_profile_repository.dart';

void main() {
  // Each test owns separate SQLite connections; no executors are shared.
  final previousWarnings = driftRuntimeOptions.dontWarnAboutMultipleDatabases;
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  tearDownAll(
    () => driftRuntimeOptions.dontWarnAboutMultipleDatabases = previousWarnings,
  );
  late AppDatabase db;
  late GuestProfileRepository repo;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = GuestProfileRepository(db);
  });
  tearDown(() => db.close());

  test('concurrent first opens commit one stable guest and device', () async {
    final identities = await Future.wait(
      List.generate(20, (_) => GuestProfileRepository(db).ensureGuestProfile()),
    );
    expect(identities.map((i) => i.profile.id).toSet(), hasLength(1));
    expect(identities.map((i) => i.deviceId).toSet(), hasLength(1));
    expect(identities.first.profile.id, isNot(identities.first.deviceId));
    expect(
      identities.first.profile.id,
      matches(RegExp(r'^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$')),
    );
    expect(await db.select(db.localProfiles).get(), hasLength(1));
    expect(await db.select(db.installations).get(), hasLength(1));
  });

  test(
    'committed identity and profile data survive file close/reopen',
    () async {
      final dir = await Directory.systemTemp.createTemp('no-profile-');
      final file = File('${dir.path}/profile.sqlite');
      final firstDb = AppDatabase(NativeDatabase(file));
      final firstRepo = GuestProfileRepository(firstDb);
      final first = await firstRepo.ensureGuestProfile();
      await firstRepo.withProfile(
        first.profile.id,
        (scope) => scope.rename('An'),
      );
      await firstDb.close();
      final secondDb = AppDatabase(NativeDatabase(file));
      try {
        final second = await GuestProfileRepository(
          secondDb,
        ).ensureGuestProfile();
        expect(second.profile.id, first.profile.id);
        expect(second.deviceId, first.deviceId);
        expect(second.profile.displayName, 'An');
      } finally {
        await secondDb.close();
        await dir.delete(recursive: true);
      }
    },
  );

  test(
    'failure after profile insert rolls back and retry persists once',
    () async {
      var calls = 0;
      final failing = GuestProfileRepository(
        db,
        createId: () {
          if (++calls == 2) throw StateError('injected identity failure');
          return '11111111-1111-4111-8111-111111111111';
        },
      );
      await expectLater(failing.ensureGuestProfile(), throwsStateError);
      expect(await db.select(db.localProfiles).get(), isEmpty);
      expect(await db.select(db.installations).get(), isEmpty);
      final saved = await repo.ensureGuestProfile();
      expect((await repo.ensureGuestProfile()).profile.id, saved.profile.id);
    },
  );

  test(
    'profile transaction confines writes and rolls back on failure',
    () async {
      final a = await repo.ensureGuestProfile();
      const b = '22222222-2222-4222-8222-222222222222';
      await db
          .into(db.localProfiles)
          .insert(
            LocalProfilesCompanion.insert(
              id: b,
              createdAt: DateTime.utc(2026),
              displayName: const Value('B'),
            ),
          );
      await repo.withProfile(a.profile.id, (scope) => scope.rename('A'));
      expect((await repo.readProfile(b)).displayName, 'B');
      await expectLater(
        repo.withProfile(a.profile.id, (scope) async {
          await scope.rename('discard');
          throw StateError('injected write failure');
        }),
        throwsStateError,
      );
      expect((await repo.readProfile(a.profile.id)).displayName, 'A');
      await expectLater(
        repo.withProfile('missing', (scope) => scope.rename('X')),
        throwsStateError,
      );
      expect((await repo.readProfile(b)).displayName, 'B');
      expect((await repo.ensureGuestProfile()).deviceId, a.deviceId);
    },
  );

  test('foreign key prevents a missing active profile', () async {
    await repo.ensureGuestProfile();
    await expectLater(
      db
          .update(db.installations)
          .write(
            const InstallationsCompanion(activeProfileId: Value('missing')),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test(
    'orphaned profile data is not silently replaced with a new guest',
    () async {
      await db
          .into(db.localProfiles)
          .insert(
            LocalProfilesCompanion.insert(
              id: '33333333-3333-4333-8333-333333333333',
              createdAt: DateTime.utc(2026),
            ),
          );
      await expectLater(repo.ensureGuestProfile(), throwsStateError);
      expect(await db.select(db.localProfiles).get(), hasLength(1));
      expect(await db.select(db.installations).get(), isEmpty);
    },
  );
  test('profile store cannot write after its transaction completes', () async {
    final guest = await repo.ensureGuestProfile();
    final escaped = await repo.withProfile(
      guest.profile.id,
      (scope) async => scope,
    );
    await expectLater(escaped.rename('outside transaction'), throwsStateError);
    expect((await repo.readProfile(guest.profile.id)).displayName, isNull);
  });

  test(
    'missing active reference fails without replacing saved identities',
    () async {
      final guest = await repo.ensureGuestProfile();
      await db.customStatement('PRAGMA foreign_keys = OFF');
      await db
          .update(db.installations)
          .write(
            const InstallationsCompanion(activeProfileId: Value('missing')),
          );
      await db.customStatement('PRAGMA foreign_keys = ON');
      await expectLater(repo.ensureGuestProfile(), throwsStateError);
      expect(
        (await db.select(db.localProfiles).getSingle()).id,
        guest.profile.id,
      );
      expect(
        (await db.select(db.installations).getSingle()).deviceId,
        guest.deviceId,
      );
    },
  );
}
