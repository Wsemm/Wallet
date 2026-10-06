import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Stream<List<TransactionEntity>> watchAllTransactions();
  Future<List<TransactionEntity>> getAllTransactions();
  Future<int> insertTransaction(TransactionEntity transaction);
  Future<int> deleteTransaction(int id);
}
