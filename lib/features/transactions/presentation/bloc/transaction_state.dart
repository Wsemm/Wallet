import 'package:equatable/equatable.dart';

import '../../../../core/database/tables/transactions_table.dart';
import '../../domain/entities/transaction_entity.dart';

enum TransactionStatus { initial, loading, loaded, error }

class TransactionState extends Equatable {
  final TransactionStatus status;
  final List<TransactionEntity> transactions;
  final String? errorMessage;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.errorMessage,
  });

  TransactionState copyWith({
    TransactionStatus? status,
    List<TransactionEntity>? transactions,
    String? errorMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Summary Metrics
  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalDebits => transactions
      .where((t) => t.type == TransactionType.debt && t.category != 'people_debt')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalPeopleDebits => transactions
      .where((t) => t.type == TransactionType.debt && t.category == 'people_debt')
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalBalance => totalIncome - totalExpense + totalPeopleDebits - totalDebits;

  @override
  List<Object?> get props => [status, transactions, errorMessage];
}
