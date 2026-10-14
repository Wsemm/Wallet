import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/features/transactions/presentation/bloc/transaction_bloc.dart';

Future<void> confirmDeleteSelectedTransactions(
  BuildContext context,
  Set<int> items,
) async {
  // final id = item.id;
  // if (id == null) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Delete transactions?'),
        content: Text(
          'This will permanently remove all the selected items. This action cannot be undone.',
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
  items.forEach(
    (element) =>
        context.read<TransactionBloc>().add(DeleteTransactionEvent(element)),
  );
}
