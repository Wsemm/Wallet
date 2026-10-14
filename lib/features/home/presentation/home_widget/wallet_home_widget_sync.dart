import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'package:wallet/core/router/app_router.dart';
import 'package:wallet/features/transactions/presentation/bloc/transaction_state.dart';

class WalletHomeWidgetSync {
  WalletHomeWidgetSync(this._router);

  static const String androidName = 'CustomHomeWidget';
  static const String qualifiedAndroidName =
      'com.example.wallet.CustomHomeWidget';
  static const String _addTransactionHost = 'add-transaction';

  static const String totalBalanceKey = 'total_balance';
  static const String totalIncomeKey = 'total_income';
  static const String totalExpenseKey = 'total_expense';
  static const String totalDebitsKey = 'total_debits';
  static const String totalPeopleDebitsKey = 'total_people_debits';

  final GoRouter _router;
  StreamSubscription<Uri?>? _clickSubscription;

  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  Future<void> attachLaunchHandling() async {
    if (!_isAndroid) {
      return;
    }
    await _clickSubscription?.cancel();
    final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    await _openFromUri(initialUri);
    _clickSubscription = HomeWidget.widgetClicked.listen(_openFromUri);
  }

  Future<void> syncFromTransactionState(TransactionState state) async {
    if (!_isAndroid) {
      return;
    }
    await HomeWidget.saveWidgetData<String>(
      totalBalanceKey,
      '\$${state.totalBalance.toStringAsFixed(2)}',
    );
    await HomeWidget.saveWidgetData<String>(
      totalIncomeKey,
      '+\$${state.totalIncome.toStringAsFixed(2)}',
    );
    await HomeWidget.saveWidgetData<String>(
      totalExpenseKey,
      '-\$${state.totalExpense.toStringAsFixed(2)}',
    );
    await HomeWidget.saveWidgetData<String>(
      totalDebitsKey,
      '\$${state.totalDebits.toStringAsFixed(2)}',
    );
    await HomeWidget.saveWidgetData<String>(
      totalPeopleDebitsKey,
      '\$${state.totalPeopleDebits.toStringAsFixed(2)}',
    );
    await HomeWidget.updateWidget(
      name: androidName,
      androidName: androidName,
      qualifiedAndroidName: qualifiedAndroidName,
    );
  }

  Future<void> _openFromUri(Uri? uri) async {
    if (uri == null || uri.host != _addTransactionHost) {
      return;
    }
    final currentPath = _router.routerDelegate.currentConfiguration.uri.path;
    if (currentPath == AppRoutes.addTransaction) {
      return;
    }
    _router.push(AppRoutes.addTransaction);
  }

  Future<void> dispose() async {
    await _clickSubscription?.cancel();
    _clickSubscription = null;
  }
}
