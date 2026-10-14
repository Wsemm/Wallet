import 'package:wallet/features/transactionsGroup/domain/entities/transaction_group_entity.dart';

import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Stream<List<TransactionEntity>> watchAllTransactions();
  Stream<List<TransactionGroupEntity>> watchAllTransactionsGroups();
  Future<List<TransactionEntity>> getAllTransactions();
  Future<List<TransactionGroupEntity>> getAllTransactionsGroups();
  Future<int> insertTransaction(TransactionEntity transaction);
  Future<int> insertTransactionGroup(
    TransactionGroupEntity transactionGroupEntity,
  );
  Future<bool> updateTransaction(TransactionEntity transaction);
  Future<int> deleteTransaction(int id);
}
