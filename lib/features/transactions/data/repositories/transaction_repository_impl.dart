import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase _database;

  TransactionRepositoryImpl(this._database);

  @override
  Stream<List<TransactionEntity>> watchAllTransactions() {
    return (_database.select(_database.transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    final rows = await (_database.select(_database.transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<int> insertTransaction(TransactionEntity transaction) {
    return _database.into(_database.transactions).insert(
          TransactionsCompanion.insert(
            title: transaction.title,
            amount: transaction.amount,
            type: transaction.type,
            category: transaction.category,
            createdAt: Value(transaction.createdAt),
          ),
        );
  }

  @override
  Future<int> deleteTransaction(int id) {
    return (_database.delete(_database.transactions)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  TransactionEntity _toEntity(Transaction row) {
    return TransactionEntity(
      id: row.id,
      title: row.title,
      amount: row.amount,
      type: row.type,
      category: row.category,
      createdAt: row.createdAt,
    );
  }
}
