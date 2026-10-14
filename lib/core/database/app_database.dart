import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/transactions_group_table.dart';
import 'tables/transactions_table.dart';

export 'tables/transactions_group_table.dart';
export 'tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [TransactionsTable, TransactionsGroupsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1; // Reset to 1

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
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

Future<void> deleteDatabaseFile() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'wallet_app.db'));
  if (await file.exists()) {
    await file.delete();
  }
}
