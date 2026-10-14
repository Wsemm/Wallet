import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:wallet/features/transactions/domain/entities/transaction_entity.dart';
import 'package:wallet/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:wallet/features/transactions/presentation/widgets/transaction_form.dart';
import 'package:wallet/features/transactionsGroup/presentation/bloc/transaction_group_bloc.dart';

Future<void> showEditTransactionSheet(
  BuildContext context,
  TransactionEntity item,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 8.h,
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + 20.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Transaction',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              TransactionForm(
                initial: item,
                submitLabel: 'Save changes',
                onSubmit: (updated) {
                  context.read<TransactionBloc>().add(
                    UpdateTransactionEvent(updated),
                  );
                  Navigator.of(sheetContext).pop();
                },
                onAddTransactionGroup: (transactionGroup) {
                  context.read<TransactionGroupBloc>().add(
                    AddTransactionGroupEvent(transactionGroup),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> confirmDeleteTransaction(
  BuildContext context,
  TransactionEntity item,
) async {
  final id = item.id;
  if (id == null) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text(
          'This will permanently remove "${item.title}". This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;
  if (!context.mounted) return;
  context.read<TransactionBloc>().add(DeleteTransactionEvent(id));
}
