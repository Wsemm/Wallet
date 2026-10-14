import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet/features/transactionsGroup/data/repositories/transaction_group_repository_impl.dart';
import 'package:wallet/features/transactionsGroup/domain/repositories/transaction_group_repository.dart';
import 'package:wallet/features/transactionsGroup/presentation/bloc/transaction_group_bloc.dart';

import '../../features/home/presentation/home_widget/wallet_home_widget_sync.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/presentation/bloc/transaction_bloc.dart';
import '../database/app_database.dart';
import '../router/app_router.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core: Database / Local Storage
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Core: Navigation / Router
  sl.registerLazySingleton<GoRouter>(() => appRouter);
  sl.registerLazySingleton<WalletHomeWidgetSync>(
    () => WalletHomeWidgetSync(sl<GoRouter>()),
  );

  // Feature: Transactions - Data
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(sl<AppDatabase>()),
  );
  // Feature: Transactions Group - Data
  sl.registerLazySingleton<TransactionGroupRepository>(
    () => TransactionGroupRepositoryImpl(sl<AppDatabase>()),
  );

  // Feature: Transactions - Presentation (BLoC)
  sl.registerFactory<TransactionBloc>(
    () => TransactionBloc(sl<TransactionRepository>()),
  );
  // Feature: Transactions Group - Presentation (BLoC)
  sl.registerSingleton<TransactionGroupBloc>(
    TransactionGroupBloc(sl<TransactionGroupRepository>()),
  );
  // sl.registerFactory<TransactionGroupBloc>(
  //   () => TransactionGroupBloc(sl<TransactionGroupRepository>()),
  // );
}

Future<void> init() async => initDependencies();
