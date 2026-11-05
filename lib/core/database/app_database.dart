import 'dart:developer';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wallet/core/di/injection.dart';

import 'tables/transactions_group_table.dart';
import 'tables/transactions_table.dart';

export 'tables/transactions_group_table.dart';
export 'tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [TransactionsTable, TransactionsGroupsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2; // Incremented to 2 for all production users

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },

    onUpgrade: (Migrator m, int from, int to) async {
      // 1. Safe condition: Catches all production users upgrading from version 1
      if (from < 2) {
        await m.addColumn(transactionsTable, transactionsTable.isArchived);

        // 2. Safe Backfill (Crucial step for old data protection):
        // Since the column is nullable, old rows will have a 'null' value.
        // If your app or UI expects a default of false, update existing rows to false:
        await customStatement(
          'UPDATE transactions_table SET is_archived = 0 WHERE is_archived IS NULL;',
        );
      }
    },

    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'wallet_app.db'));
    return NativeDatabase.createInBackground(file);
  });
}

Future<void> closeAndDeleteDatabase() async {
  // 1. Get the registered instance from GetIt and close it securely
  if (sl.isRegistered<AppDatabase>()) {
    await sl<AppDatabase>().close();
  }

  // 2. Delete the actual file from the device
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'wallet_app.db'));
  if (await file.exists()) {
    await file.delete();
  }
}

Future<void> deleteDatabaseFile() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'wallet_app.db'));
  if (await file.exists()) {
    await file.delete();
  }
}
