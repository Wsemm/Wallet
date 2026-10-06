import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet/core/database/app_database.dart';
import 'package:wallet/core/di/injection.dart';
import 'package:wallet/core/router/app_router.dart';
import 'package:wallet/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:wallet/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:wallet/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:wallet/main.dart';

void main() {
  setUp(() async {
    await sl.reset();
    sl.registerLazySingleton<AppDatabase>(() => AppDatabase(NativeDatabase.memory()));
    sl.registerLazySingleton<GoRouter>(() => appRouter);
    sl.registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(sl<AppDatabase>()),
    );
    sl.registerFactory<TransactionBloc>(
      () => TransactionBloc(sl<TransactionRepository>()),
    );
  });

  tearDown(() async {
    await sl<AppDatabase>().close();
  });

  testWidgets('App launches and renders HomeScreen with summary and dashboard',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Wallet Dashboard'), findsOneWidget);
    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Debits'), findsOneWidget);
    expect(find.text('People debits from user'), findsOneWidget);

    // Unmount widget tree and flush any stream query timer
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
