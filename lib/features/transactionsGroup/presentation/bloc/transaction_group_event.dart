part of 'transaction_group_bloc.dart';

sealed class TransactionGroupEvent extends Equatable {
  const TransactionGroupEvent();

  @override
  List<Object> get props => [];
}

final class LoadTransactionsGroupsEvent extends TransactionGroupEvent {
  const LoadTransactionsGroupsEvent();
}

final class AddTransactionGroupEvent extends TransactionGroupEvent {
  final TransactionGroupEntity transactionGroupEntity;

  const AddTransactionGroupEvent(this.transactionGroupEntity);

  @override
  List<Object> get props => [transactionGroupEntity];
}

final class DeleteTransactionGroupEvent extends TransactionGroupEvent {
  final int id;

  const DeleteTransactionGroupEvent(this.id);

  @override
  List<Object> get props => [id];
}

final class UpdateTransactionGroupEvent extends TransactionGroupEvent {
  final TransactionGroupEntity transactionGroup;

  const UpdateTransactionGroupEvent(this.transactionGroup);

  @override
  List<Object> get props => [transactionGroup];
}

final class TransactionGroupUpdated extends TransactionGroupEvent {
  final List<TransactionGroupEntity> transactionGroup;

  const TransactionGroupUpdated(this.transactionGroup);

  @override
  List<Object> get props => [transactionGroup];
}
