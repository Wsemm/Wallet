import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet/core/router/app_router.dart';
import 'package:wallet/features/home/presentation/screens/home_screen.dart';
import 'package:wallet/features/transactions/domain/entities/transaction_filter.dart';
import 'package:wallet/features/transactions/presentation/bloc/transaction_bloc.dart';

class TotalBalanceWidget extends StatelessWidget {
  const TotalBalanceWidget({
    super.key,
    required this._selectionMode,
    required this.colorScheme,
  });

  final bool _selectionMode;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: _selectionMode
                        ? null
                        : () => context.pushNamed(
                            AppRoutes.filteredTransactionsName,
                            pathParameters: {
                              'filter': TransactionListFilter.all.name,
                            },
                          ),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Balance',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '\$${state.totalBalance.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: state.totalBalance >= 0
                                  ? colorScheme.primary
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryMetric(
                          label: 'Income',
                          amount: '+\$${state.totalIncome.toStringAsFixed(2)}',
                          color: Colors.green,
                          icon: Icons.arrow_downward,
                          onTap: _selectionMode
                              ? null
                              : () => context.pushNamed(
                                  AppRoutes.filteredTransactionsName,
                                  pathParameters: {
                                    'filter': TransactionListFilter.income.name,
                                  },
                                ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: SummaryMetric(
                          label: 'Expense',
                          amount: '-\$${state.totalExpense.toStringAsFixed(2)}',
                          color: Colors.red,
                          icon: Icons.arrow_upward,
                          onTap: _selectionMode
                              ? null
                              : () => context.pushNamed(
                                  AppRoutes.filteredTransactionsName,
                                  pathParameters: {
                                    'filter':
                                        TransactionListFilter.expense.name,
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryMetric(
                          label: 'Debits',
                          amount: '\$${state.totalDebits.toStringAsFixed(2)}',
                          color: Colors.orange,
                          icon: Icons.money_off,
                          onTap: _selectionMode
                              ? null
                              : () => context.pushNamed(
                                  AppRoutes.filteredTransactionsName,
                                  pathParameters: {
                                    'filter': TransactionListFilter.debt.name,
                                  },
                                ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: SummaryMetric(
                          label: 'People debits from user',
                          amount:
                              '\$${state.totalPeopleDebits.toStringAsFixed(2)}',
                          color: Colors.blue,
                          icon: Icons.handshake,
                          onTap: _selectionMode
                              ? null
                              : () => context.pushNamed(
                                  AppRoutes.filteredTransactionsName,
                                  pathParameters: {
                                    'filter':
                                        TransactionListFilter.peopleDebt.name,
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
