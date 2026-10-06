import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';

import 'package:wallet/core/database/tables/transactions_table.dart';
import 'package:wallet/core/router/app_router.dart';
import 'package:wallet/features/transactions/domain/entities/transaction_entity.dart';
import 'package:wallet/features/transactions/presentation/bloc/transaction_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wallet Dashboard',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state.status == TransactionStatus.loading &&
              state.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == TransactionStatus.error &&
              state.transactions.isEmpty) {
            return Center(
              child: Text(
                state.errorMessage ?? 'An error occurred',
                style: TextStyle(fontSize: 16.sp, color: colorScheme.error),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Summary Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
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
                          Divider(height: 24.h),
                          // First row: Income & Expense
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryMetric(
                                  label: 'Income',
                                  amount:
                                      '+\$${state.totalIncome.toStringAsFixed(2)}',
                                  color: Colors.green,
                                  icon: Icons.arrow_downward,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: _buildSummaryMetric(
                                  label: 'Expense',
                                  amount:
                                      '-\$${state.totalExpense.toStringAsFixed(2)}',
                                  color: Colors.red,
                                  icon: Icons.arrow_upward,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          // Second row: Debits & People debits from user
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryMetric(
                                  label: 'Debits',
                                  amount:
                                      '\$${state.totalDebits.toStringAsFixed(2)}',
                                  color: Colors.orange,
                                  icon: Icons.money_off,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: _buildSummaryMetric(
                                  label: 'People debits from user',
                                  amount:
                                      '\$${state.totalPeopleDebits.toStringAsFixed(2)}',
                                  color: Colors.blue,
                                  icon: Icons.handshake,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Transaction List Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transactions',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${state.transactions.length} items',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Transaction Items / Empty State
              if (state.transactions.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 32.h,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 56.r,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No transactions recorded yet',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Tap the button below to add your first transaction.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = state.transactions[index];
                      return _buildTransactionItem(context, item);
                    }, childCount: state.transactions.length),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addTransaction),
        icon: Icon(Icons.add, size: 20.r),
        label: Text('Add Transaction', style: TextStyle(fontSize: 14.sp)),
      ),
    );
  }

  Widget _buildSummaryMetric({
    required String label,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14.r,
            backgroundColor: color.withValues(alpha: 0.18),
            child: Icon(icon, size: 14.r, color: color),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, TransactionEntity item) {
    final theme = Theme.of(context);
    final isPeopleDebt =
        item.type == TransactionType.debt && item.category == 'people_debt';

    final (badgeColor, badgeIcon, sign) = switch (item.type) {
      TransactionType.income => (Colors.green, Icons.arrow_downward, '+'),
      TransactionType.expense => (Colors.red, Icons.arrow_upward, '-'),
      TransactionType.debt =>
        isPeopleDebt
            ? (Colors.blue, Icons.handshake, '+')
            : (Colors.orange, Icons.money_off, '-'),
    };

    final dateStr =
        '${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')} ${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
        leading: CircleAvatar(
          radius: 18.r,
          backgroundColor: badgeColor.withValues(alpha: 0.15),
          child: Icon(badgeIcon, size: 18.r, color: badgeColor),
        ),
        title: Text(
          item.title,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Container(
              margin: EdgeInsets.only(top: 4.h, right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                isPeopleDebt ? 'People Debt' : item.category,
                style: TextStyle(fontSize: 10.sp),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 30.h,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$sign\$${item.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                  if (item.id != null)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20.r,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        context.read<TransactionBloc>().add(
                          DeleteTransactionEvent(item.id!),
                        );
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                dateStr,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
