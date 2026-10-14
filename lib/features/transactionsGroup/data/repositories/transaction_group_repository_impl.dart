import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:wallet/features/transactionsGroup/domain/entities/transaction_group_entity.dart';
import 'package:wallet/features/transactionsGroup/domain/repositories/transaction_group_repository.dart';

import '../../../../core/database/app_database.dart';

class TransactionGroupRepositoryImpl implements TransactionGroupRepository {
  final AppDatabase _database;

  TransactionGroupRepositoryImpl(this._database);

  @override
  Stream<List<TransactionGroupEntity>> watchAllTransactionsGroups() {
    return (_database.select(_database.transactionsGroupsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_toEntityGroups).toList());
  }

  @override
  Future<List<TransactionGroupEntity>> getAllTransactionsGroups() async {
    final rows = await (_database.select(
      _database.transactionsGroupsTable,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
    return rows.map(_toEntityGroups).toList();
  }

  @override
  Future<int> insertTransactionGroup(
    TransactionGroupEntity transactionGroupEntity,
  ) {
    return _database
        .into(_database.transactionsGroupsTable)
        .insert(_toCompanionGroup(transactionGroupEntity));
  }

  @override
  Future<bool> updateTransactionGroup(
    TransactionGroupEntity transactionGroup,
  ) async {
    try {
      final id = transactionGroup.id;

      if (id == null) return false;
      final count =
          await (_database.update(_database.transactionsGroupsTable)
                ..where((t) => t.id.equals(id)))
              .write(_toCompanionGroup(transactionGroup));
      return count > 0;
    } catch (e, s) {
      log("there was an error updateing trasnaction group Error:$e  Stack:$s");
      return false;
    }
  }

  @override
  Future<int> deleteTransactionGroup(int id) {
    return (_database.delete(
      _database.transactionsGroupsTable,
    )..where((t) => t.id.equals(id))).go();
  }

  TransactionsGroupsTableCompanion _toCompanionGroup(
    TransactionGroupEntity transactionGroup,
  ) {
    return TransactionsGroupsTableCompanion(
      name: Value(transactionGroup.name),
      description: Value.absentIfNull(transactionGroup.description),
      createdAt: Value(transactionGroup.createdAt),
    );
  }

  TransactionGroupEntity _toEntityGroups(TransactionsGroupsTableData row) {
    return TransactionGroupEntity(
      id: row.id,
      name: row.name,
      description: row.description,
      createdAt: row.createdAt,
    );
  }
}
