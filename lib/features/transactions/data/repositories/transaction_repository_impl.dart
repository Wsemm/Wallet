import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:wallet/features/transactionsGroup/domain/entities/transaction_group_entity.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase _database;

  TransactionRepositoryImpl(this._database);

  @override
  Stream<List<TransactionEntity>> watchAllTransactions() {
    return (_database.select(_database.transactionsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Stream<List<TransactionGroupEntity>> watchAllTransactionsGroups() {
    return (_database.select(_database.transactionsGroupsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_toEntityGroups).toList());
  }

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    final rows = await (_database.select(
      _database.transactionsTable,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<TransactionGroupEntity>> getAllTransactionsGroups() async {
    final rows = await (_database.select(
      _database.transactionsGroupsTable,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
    return rows.map(_toEntityGroups).toList();
  }

  @override
  Future<int> insertTransaction(TransactionEntity transaction) async {
    try {
      log("inserting");

      var s = await _database
          .into(_database.transactionsTable)
          .insert(_toCompanion(transaction));
      log("erro  ${s}");

      return Future.value(s);
    } catch (e) {
      log(e.toString());
      return Future.value(0);
    }
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
  Future<bool> updateTransaction(TransactionEntity transaction) async {
    final id = transaction.id;
    if (id == null) return false;
    final count = await (_database.update(
      _database.transactionsTable,
    )..where((t) => t.id.equals(id))).write(_toCompanion(transaction));
    return count > 0;
  }

  @override
  Future<int> deleteTransaction(int id) {
    return (_database.delete(
      _database.transactionsTable,
    )..where((t) => t.id.equals(id))).go();
  }

  TransactionsTableCompanion _toCompanion(TransactionEntity transaction) {
    return TransactionsTableCompanion(
      title: Value(transaction.title),
      amount: Value(transaction.amount),
      type: Value(transaction.type),
      category: Value(transaction.category),
      note: Value.absentIfNull(transaction.note),
      groupId: Value.absentIfNull(transaction.groupId),
      createdAt: Value(transaction.createdAt),
      isArchived: Value(transaction.isArchived),
    );
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

  TransactionEntity _toEntity(TransactionsTableData row) {
    return TransactionEntity(
      id: row.id,
      title: row.title,
      amount: row.amount,
      type: row.type,
      category: row.category,
      note: row.note,
      groupId: row.groupId,
      createdAt: row.createdAt,
      isArchived: row.isArchived,
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
