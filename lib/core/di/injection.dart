import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

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

  // Feature: Transactions - Data
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(sl<AppDatabase>()),
  );

  // Feature: Transactions - Presentation (BLoC)
  sl.registerFactory<TransactionBloc>(
    () => TransactionBloc(sl<TransactionRepository>()),
  );
}

Future<void> init() async => initDependencies();
