import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Local database. Drift is the Room equivalent: a table is an entity,
/// a query method is a DAO, and [schemaVersion] plus [migration] are the
/// Room migration. Add the first table in the feature branch that needs it.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  static QueryExecutor _open() {
    return driftDatabase(
      name: 'anit_scan',
      native: const DriftNativeOptions(
        // The UI isolate and a later notification isolate share one connection.
        shareAcrossIsolates: true,
      ),
    );
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator migrator) async {
      await migrator.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );
}
