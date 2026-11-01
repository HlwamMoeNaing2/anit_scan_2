import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Opens the one on-device database. Feature packages own the tables.
QueryExecutor openAppDatabase() {
  return driftDatabase(
    name: 'anit_scan',
    native: const DriftNativeOptions(
      shareAcrossIsolates: true,
    ),
  );
}

Future<void> configureSqlite(GeneratedDatabase database) async {
  await database.customStatement('PRAGMA foreign_keys = ON');
  await database.customStatement('PRAGMA journal_mode = WAL');
}
