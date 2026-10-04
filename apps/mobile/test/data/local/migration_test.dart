import 'package:drift_dev/api/migrations_native.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:no_mobile/data/local/app_database.dart';

import 'generated/app_database/generated/schema.dart';
import 'generated/app_database/generated/schema_v1.dart' as v1;
import 'generated/app_database/generated/schema_v2.dart' as v2;

void main() {
  final verifier = SchemaVerifier(GeneratedHelper());

  test('fresh v2 schema matches the exported schema', () async {
    final db = AppDatabase(NativeDatabase.memory());
    try {
      await db.customSelect('SELECT 1').get();
      await db.validateDatabaseSchema();
    } finally {
      await db.close();
    }
  });

  test(
    'v1 migration preserves two profiles, device and active reference',
    () async {
      const a = '11111111-1111-4111-8111-111111111111';
      const b = '22222222-2222-4222-8222-222222222222';
      const device = '33333333-3333-4333-8333-333333333333';
      const createdAt = 1791072000;
      await verifier.testWithDataIntegrity(
        oldVersion: 1,
        newVersion: 2,
        createOld: v1.DatabaseAtV1.new,
        createNew: v2.DatabaseAtV2.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) {
          batch.insertAll(oldDb.localProfiles, const [
            v1.LocalProfilesData(id: a, createdAt: createdAt),
            v1.LocalProfilesData(id: b, createdAt: createdAt + 1),
          ]);
          batch.insert(
            oldDb.installations,
            const v1.InstallationsData(
              singleton: 1,
              deviceId: device,
              activeProfileId: a,
            ),
          );
        },
        validateItems: (newDb) async {
          expect(await newDb.select(newDb.localProfiles).get(), const [
            v2.LocalProfilesData(id: a, createdAt: createdAt),
            v2.LocalProfilesData(id: b, createdAt: createdAt + 1),
          ]);
          expect(await newDb.select(newDb.installations).get(), const [
            v2.InstallationsData(
              singleton: 1,
              deviceId: device,
              activeProfileId: a,
            ),
          ]);
        },
      );
    },
  );
}
