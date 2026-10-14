import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet/core/router/app_router.dart';
import 'package:wallet/features/home/presentation/widgets/dialogs/confirm_delte_all_dialog.dart';
import 'package:wallet/features/home/presentation/widgets/empty_home_widget.dart';
import 'package:wallet/features/home/presentation/widgets/total_balance_widget.dart';
import 'package:wallet/features/transactions/domain/entities/transaction_entity.dart';
import 'package:wallet/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:wallet/features/transactions/presentation/widgets/transaction_dialogs.dart';
import 'package:wallet/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:wallet/features/transactionsGroup/presentation/bloc/transaction_group_bloc.dart';

part '../widgets/sumtrice_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<int> _selectedIds = <int>{};
  bool _selectionMode = false;

  void _enterSelection(int id) {
    setState(() {
      _selectionMode = true;
      _selectedIds
        ..clear()
        ..add(id);
    });
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelected(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _selectionMode = false;
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void deleteSelectedItems() {
    confirmDeleteSelectedTransactions(context, _selectedIds);
  }

  double _selectedSum(List<TransactionEntity> transactions) {
    return transactions
        .where((t) => t.id != null && _selectedIds.contains(t.id))
        .fold(0.0, (sum, t) => sum + t.signedAmount);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_selectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectionMode) {
          _exitSelection();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _selectionMode
                ? '${_selectedIds.length} selected'
                : 'Wallet Dashboard',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: _selectionMode
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _exitSelection,
                )
              : null,
          actions: [
            if (!_selectionMode)
              IconButton(
                tooltip: 'Analytics',
                icon: const Icon(Icons.analytics_outlined),
                onPressed: () => context.push(AppRoutes.analytics),
              ),
            if (!_selectionMode)
              IconButton(
                tooltip: 'Analytics',
                icon: const Icon(Icons.folder_outlined),
                onPressed: () => context.push(AppRoutes.transactionGroup),
              ),
            if (_selectionMode)
              IconButton(
                tooltip: 'Delete selected',
                icon: const Icon(Icons.delete_outline_sharp, color: Colors.red),
                onPressed: () => deleteSelectedItems(),
              ),
          ],
        ),
        body: BlocBuilder<TransactionGroupBloc, TransactionGroupState>(
          builder: (context, state) {
            return BlocBuilder<TransactionBloc, TransactionState>(
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
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: colorScheme.error,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<TransactionBloc>().add(
                      LoadTransactionsEvent(),
                    );
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: TotalBalanceWidget(
                          selectionMode: _selectionMode,
                          colorScheme: colorScheme,
                        ),
                      ),
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
                      if (state.transactions.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyHomeData(),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            16.w,
                            4.h,
                            16.w,
                            _selectionMode ? 88.h : 55.h,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final item = state.transactions[index];
                              final id = item.id;
                              return TransactionListItem(
                                item: item,
                                selectionMode: _selectionMode,
                                selected:
                                    id != null && _selectedIds.contains(id),
                                onLongPress: id == null
                                    ? null
                                    : () => _enterSelection(id),
                                onTap: _selectionMode
                                    ? (id == null
                                          ? null
                                          : () => _toggleSelected(id))
                                    : null,
                                onEdit: () =>
                                    showEditTransactionSheet(context, item),
                                onDelete: () =>
                                    confirmDeleteTransaction(context, item),
                              );
                            }, childCount: state.transactions.length),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        bottomNavigationBar: _selectionMode
            ? BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  final sum = _selectedSum(state.transactions);
                  final sign = sum >= 0 ? '+' : '-';
                  return Material(
                    elevation: 8,
                    color: colorScheme.surfaceContainerHigh,
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Selected sum: $sign\$${sum.abs().toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _exitSelection,
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : null,
        floatingActionButton: _selectionMode
            ? null
            : FloatingActionButton.extended(
                onPressed: () => context.push(AppRoutes.addTransaction),
                icon: Icon(Icons.add, size: 20.r),
                label: Text(
                  'Add Transaction',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
      ),
    );
  }
}
