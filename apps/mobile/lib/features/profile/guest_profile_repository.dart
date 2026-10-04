import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../data/local/app_database.dart';

class ProfileIdentity {
  const ProfileIdentity({required this.profile, required this.deviceId});
  final LocalProfile profile;
  final String deviceId;
}

class GuestProfileRepository {
  GuestProfileRepository(this._db, {String Function()? createId})
    : _createId = createId ?? const Uuid().v4;

  final AppDatabase _db;
  final String Function() _createId;

  // Drift serializes transactions on this connection, including separate
  // repository instances. SQL constraints also enforce a single installation.
  Future<ProfileIdentity> ensureGuestProfile() => _db.transaction(() async {
    final installation = await _db.select(_db.installations).getSingleOrNull();
    if (installation != null) {
      return ProfileIdentity(
        profile: await readProfile(installation.activeProfileId),
        deviceId: installation.deviceId,
      );
    }
    if ((await _db.select(_db.localProfiles).get()).isNotEmpty) {
      throw StateError('Profile data exists without an installation');
    }
    final profileId = _createId();
    await _db
        .into(_db.localProfiles)
        .insert(
          LocalProfilesCompanion.insert(
            id: profileId,
            createdAt: DateTime.now().toUtc(),
          ),
        );
    final deviceId = _createId();
    await _db
        .into(_db.installations)
        .insert(
          InstallationsCompanion.insert(
            singleton: const Value(1),
            deviceId: deviceId,
            activeProfileId: profileId,
          ),
        );
    return ProfileIdentity(
      profile: await readProfile(profileId),
      deviceId: deviceId,
    );
  });

  Future<LocalProfile> readProfile(String profileId) async {
    final profile = await (_db.select(
      _db.localProfiles,
    )..where((row) => row.id.equals(profileId))).getSingleOrNull();
    if (profile == null) throw StateError('Local profile is missing');
    return profile;
  }

  // Callers receive a store confined to one explicit profile, rather than an
  // unscoped DB or an implicit "current user" that can change mid-transaction.
  Future<T> withProfile<T>(
    String profileId,
    Future<T> Function(ProfileStore scope) action,
  ) => _db.transaction(() async {
    await readProfile(profileId);
    final scope = ProfileStore._(_db, profileId);
    try {
      return await action(scope);
    } finally {
      scope._active = false;
    }
  });
}

class ProfileStore {
  ProfileStore._(this._db, this.profileId);
  final AppDatabase _db;
  final String profileId;
  bool _active = true;

  Future<void> rename(String? displayName) async {
    if (!_active) throw StateError('Profile transaction has ended');
    final changed =
        await (_db.update(_db.localProfiles)
              ..where((row) => row.id.equals(profileId)))
            .write(LocalProfilesCompanion(displayName: Value(displayName)));
    if (changed != 1) throw StateError('Local profile is missing');
  }
}
