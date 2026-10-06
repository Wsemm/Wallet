import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/transactions/presentation/screens/add_transaction_screen.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String homeName = 'home';

  static const String addTransaction = '/add-transaction';
  static const String addTransactionName = 'add-transaction';
}

final GoRouter appRouter = GoRouter(
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
      builder: (context, state) => AddTransactionScreen(),
    ),
  ],
);
