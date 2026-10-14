import '../../../../core/database/tables/transactions_table.dart';
import 'transaction_entity.dart';

enum TransactionListFilter {
  all,
  income,
  expense,
  debt,
  peopleDebt,
}

extension TransactionListFilterX on TransactionListFilter {
  String get title => switch (this) {
    TransactionListFilter.all => 'All operations',
    TransactionListFilter.income => 'Income',
    TransactionListFilter.expense => 'Expenses',
    TransactionListFilter.debt => 'Debits',
    TransactionListFilter.peopleDebt => 'People debits',
  };

  bool matches(TransactionEntity transaction) {
    return switch (this) {
      TransactionListFilter.all => true,
      TransactionListFilter.income =>
        transaction.type == TransactionType.income,
      TransactionListFilter.expense =>
        transaction.type == TransactionType.expense,
      TransactionListFilter.debt =>
        transaction.type == TransactionType.debt && !transaction.isPeopleDebt,
      TransactionListFilter.peopleDebt => transaction.isPeopleDebt,
    };
  }
}
