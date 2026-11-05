import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

final class LoadTransactionsEvent extends TransactionEvent {
  const LoadTransactionsEvent();
}

final class AddTransactionEvent extends TransactionEvent {
  final TransactionEntity transaction;

  const AddTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

final class UpdateTransactionEvent extends TransactionEvent {
  final TransactionEntity transaction;

  const UpdateTransactionEvent(this.transaction);

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

final class AddSelectedTransToArchive extends TransactionEvent {
  final Set<int> ids;

  const AddSelectedTransToArchive(this.ids);

  @override
  List<Object?> get props => [ids];
}
