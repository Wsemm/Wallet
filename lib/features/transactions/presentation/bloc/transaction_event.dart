import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction_entity.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

final class LoadTransactions extends TransactionEvent {
  const LoadTransactions();
}

final class AddTransactionEvent extends TransactionEvent {
  final TransactionEntity transaction;

  const AddTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

final class DeleteTransactionEvent extends TransactionEvent {
  final int id;

  const DeleteTransactionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

final class TransactionsUpdated extends TransactionEvent {
  final List<TransactionEntity> transactions;

  const TransactionsUpdated(this.transactions);

  @override
  List<Object?> get props => [transactions];
}
