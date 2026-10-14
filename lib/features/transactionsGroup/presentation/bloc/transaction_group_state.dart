part of 'transaction_group_bloc.dart';

enum TransactionGroupStatus { initial, loading, loaded, error, updated }

class TransactionGroupState extends Equatable {
  final TransactionGroupStatus status;
  final List<TransactionGroupEntity> transactionsGroups;
  final String? errorMessage;

  const TransactionGroupState({
    this.status = TransactionGroupStatus.initial,
    this.transactionsGroups = const [],
    this.errorMessage,
  });

  TransactionGroupState copyWith({
    TransactionGroupStatus? status,
    List<TransactionGroupEntity>? transactionsGroups,
    String? errorMessage,
  }) {
    return TransactionGroupState(
      status: status ?? this.status,
      transactionsGroups: transactionsGroups ?? this.transactionsGroups,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Summary Metrics

  @override
  List<Object?> get props => [status, errorMessage, transactionsGroups];
}
