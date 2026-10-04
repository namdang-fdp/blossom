import 'package:drift/drift.dart';

class LocalProfiles extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get displayName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Installations extends Table {
  // Drift parses this self-reference into SQL; generated tables override it.
  // ignore: recursive_getters
  IntColumn get singleton => integer().check(singleton.equals(1))();
  TextColumn get deviceId => text().withLength(min: 36, max: 36).unique()();
  TextColumn get activeProfileId => text().references(LocalProfiles, #id)();

  @override
  Set<Column> get primaryKey => {singleton};
}
