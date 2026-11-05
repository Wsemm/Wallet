import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:wallet/features/transactions/domain/entities/transaction_filter.dart';
import 'package:wallet/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:wallet/features/transactions/presentation/widgets/transaction_dialogs.dart';
import 'package:wallet/features/transactions/presentation/widgets/transaction_list_item.dart';

class FilteredTransactionsScreen extends StatefulWidget {
  final TransactionListFilter filter;

  const FilteredTransactionsScreen({super.key, required this.filter});

  @override
  State<FilteredTransactionsScreen> createState() =>
      _FilteredTransactionsScreenState();
}

class _FilteredTransactionsScreenState
    extends State<FilteredTransactionsScreen> {
  bool showArchive = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.filter.title,
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            children: [
              Text("Show archived"),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: showArchive,
                  onChanged: (value) => setState(() {
                    showArchive = value;
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          final filteredItems = state.transactions.where(
            (element) => element.isArchived != true,
          );
          final items = showArchive
              ? state.transactions.where(widget.filter.matches).toList()
              : filteredItems.where(widget.filter.matches).toList();

          if (items.isEmpty) {
            return Center(
              child: Text(
                'No operations in this view yet',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return TransactionListItem(
                item: item,
                onEdit: () => showEditTransactionSheet(context, item),
                onDelete: () => confirmDeleteTransaction(context, item),
              );
            },
          );
        },
      ),
    );
  }
}
