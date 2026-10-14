import 'package:wallet/features/transactionsGroup/domain/entities/transaction_group_entity.dart';

abstract class TransactionGroupRepository {
  Stream<List<TransactionGroupEntity>> watchAllTransactionsGroups();
  Future<List<TransactionGroupEntity>> getAllTransactionsGroups();
  Future<int> insertTransactionGroup(
    TransactionGroupEntity transactionGroupEntity,
  );
  Future<bool> updateTransactionGroup(TransactionGroupEntity transactionGroup);
  Future<int> deleteTransactionGroup(int id);
}
