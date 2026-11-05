import 'package:go_router/go_router.dart';
import 'package:wallet/features/transactions/domain/entities/transaction_entity.dart';
import 'package:wallet/features/transactionsGroup/domain/entities/transaction_group_entity.dart';
import 'package:wallet/features/transactionsGroup/presentation/screens/transaction_group_screen.dart';
import 'package:wallet/features/transactionsGroup/presentation/screens/transactions_by_group_screen.dart';
import 'package:wallet/main.dart';

import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/home/presentation/screens/filtered_transactions_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/transactions/domain/entities/transaction_filter.dart';
import '../../features/transactions/presentation/screens/add_transaction_screen.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String homeName = 'home';

  static const String addTransaction = '/add-transaction';
  static const String addTransactionName = 'add-transaction';

  static const String analytics = '/analytics';
  static const String analyticsName = 'analytics';

  static const String filteredTransactions = '/transactions/:filter';
  static const String filteredTransactionsName = 'filtered-transactions';

  static const String transactionGroup = '/transactionGroup';
  static const String transactionGroupName = 'transaction-group';

  static const String transactionByGroup = '/transactionByGroup';
  static const String transactionByGroupName = 'transaction-by-group';
}

final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.homeName,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.addTransaction,
      name: AppRoutes.addTransactionName,
      builder: (context, state) {
        TransactionEntity? trans = (state.extra) as TransactionEntity?;
        return AddTransactionScreen(transactionEntity: trans);
      },
    ),
    GoRoute(
      path: AppRoutes.analytics,
      name: AppRoutes.analyticsName,
      builder: (context, state) => const AnalyticsScreen(),
    ),
    GoRoute(
      path: AppRoutes.filteredTransactions,
      name: AppRoutes.filteredTransactionsName,
      builder: (context, state) {
        final raw = state.pathParameters['filter'] ?? 'all';
        final filter = TransactionListFilter.values.firstWhere(
          (value) => value.name == raw,
          orElse: () => TransactionListFilter.all,
        );
        return FilteredTransactionsScreen(filter: filter);
      },
    ),
    GoRoute(
      path: AppRoutes.transactionGroup,
      name: AppRoutes.transactionGroupName,
      builder: (context, state) {
        return TransactionGroupScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.transactionByGroup,
      name: AppRoutes.transactionByGroupName,
      builder: (context, state) {
        TransactionGroupEntity tGroup = (state.extra) as TransactionGroupEntity;
        return TransactionsByGroupScreen(tGroup: tGroup);
      },
    ),
  ],
);
