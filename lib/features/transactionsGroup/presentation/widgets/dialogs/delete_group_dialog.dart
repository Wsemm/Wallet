import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  const ConfirmDeleteDialog({super.key, required this.groupName});

  final String groupName;

  static Future<bool> show(
    BuildContext context, {
    required String groupName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(groupName: groupName),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Delete group?'),
      content: Text('"$groupName" will be deleted. This can\'t be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
