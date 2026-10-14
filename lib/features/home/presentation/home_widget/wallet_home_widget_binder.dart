import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/core/di/injection.dart';
import 'package:wallet/features/home/presentation/home_widget/wallet_home_widget_sync.dart';
import 'package:wallet/features/transactions/presentation/bloc/transaction_bloc.dart';

class WalletHomeWidgetBinder extends StatefulWidget {
  const WalletHomeWidgetBinder({super.key, required this.child});

  final Widget child;

  @override
  State<WalletHomeWidgetBinder> createState() => _WalletHomeWidgetBinderState();
}

class _WalletHomeWidgetBinderState extends State<WalletHomeWidgetBinder> {
  late final WalletHomeWidgetSync _sync;

  @override
  void initState() {
    super.initState();
    _sync = sl<WalletHomeWidgetSync>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sync.attachLaunchHandling();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (previous, current) =>
          previous.transactions != current.transactions ||
          previous.status != current.status,
      listener: (context, state) {
        _sync.syncFromTransactionState(state);
      },
      child: widget.child,
    );
  }
}
