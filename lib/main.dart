import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet/core/app/theme/bloc/theme_bloc.dart';
import 'package:wallet/features/home/presentation/home_widget/wallet_home_widget_binder.dart';
import 'package:wallet/features/home/presentation/widgets/restart_widget.dart';
import 'package:wallet/features/transactionsGroup/presentation/bloc/transaction_group_bloc.dart'
    as group;
import 'core/di/injection.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(RestartWidget(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<TransactionBloc>()..add(const LoadTransactionsEvent()),
        ),
        BlocProvider(
          create: (_) =>
              sl<group.TransactionGroupBloc>()
                ..add(const group.LoadTransactionsGroupsEvent()),
        ),
        BlocProvider(create: (_) => ThemeBloc()..add(SetDefaultThemeEvent())),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return WalletHomeWidgetBinder(
            child: ScreenUtilPlusInit(
              designSize: const Size(375, 812),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return MaterialApp.router(
                  scaffoldMessengerKey: rootScaffoldMessengerKey,
                  title: 'Wallet App',
                  debugShowCheckedModeBanner: false,
                  themeMode: (state as ThemeInitial).themeMode,
                  theme: ThemeData(
                    useMaterial3: true,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.deepPurple,
                      brightness: Brightness.light,
                    ),
                  ),
                  darkTheme: ThemeData(
                    useMaterial3: true,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.deepPurple,
                      brightness: Brightness.dark,
                    ),
                  ),
                  routerConfig: sl<GoRouter>(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
