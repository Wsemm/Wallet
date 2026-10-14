import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:wallet/features/transactions/domain/entities/transaction_entity.dart';
import 'package:wallet/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:wallet/features/transactions/presentation/widgets/transaction_dialogs.dart';
import 'package:wallet/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:wallet/features/transactionsGroup/domain/entities/transaction_group_entity.dart';

class TransactionsByGroupScreen extends StatefulWidget {
  final TransactionGroupEntity tGroup;
  const TransactionsByGroupScreen({super.key, required this.tGroup});

  @override
  State<TransactionsByGroupScreen> createState() =>
      _TransactionsByGroupScreenState();
}

class _TransactionsByGroupScreenState extends State<TransactionsByGroupScreen> {
  final Set<int> _selectedIds = <int>{};
  List<TransactionEntity> transactions = [];
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

  double _selectedSum(List<TransactionEntity> transactions) {
    return transactions
        .where((t) => t.id != null && _selectedIds.contains(t.id))
        .fold(0.0, (sum, t) => sum + t.signedAmount);
  }

  double _totalSum(List<TransactionEntity> transactions) {
    return transactions
        .where((t) => t.id != null)
        .fold(0.0, (sum, t) => sum + t.signedAmount);
  }

  @override
  void initState() {
    matchGroupId();
    super.initState();
  }

  void matchGroupId() {
    var allTrans = context.read<TransactionBloc>().state.transactions;

    setState(() {
      transactions = allTrans.where((element) {
        return element.groupId == widget.tGroup.id;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: _selectionMode
            ? InkWell(
                onTap: () {
                  _exitSelection();
                },
                child: Icon(Icons.close),
              )
            : null,
        title: Text(
          "${widget.tGroup.name}   ${widget.tGroup.id}   ${transactions.length}",
        ),
      ),
      bottomNavigationBar: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          final sum = _selectionMode
              ? _selectedSum(transactions)
              : _totalSum(transactions);
          final sign = sum >= 0 ? '+' : '-';
          return Material(
            elevation: 8,
            color: colorScheme.surfaceContainerHigh,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_selectionMode ? "Selected" : ""} sum: $sign\$${sum.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_selectionMode)
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
      ),
      body: PopScope(
        canPop: !_selectionMode,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _selectionMode) {
            _exitSelection();
          }
        },
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = transactions[index];
                  final id = item.id;
                  return TransactionListItem(
                    item: item,
                    selectionMode: _selectionMode,
                    selected: id != null && _selectedIds.contains(id),
                    onLongPress: id == null ? null : () => _enterSelection(id),
                    onTap: _selectionMode
                        ? (id == null ? null : () => _toggleSelected(id))
                        : null,
                    onEdit: () => showEditTransactionSheet(context, item),
                    onDelete: () => confirmDeleteTransaction(context, item),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
