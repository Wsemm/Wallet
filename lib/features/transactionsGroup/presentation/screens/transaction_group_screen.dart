import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:wallet/features/transactionsGroup/domain/entities/transaction_group_entity.dart';
import 'package:wallet/features/transactionsGroup/presentation/bloc/transaction_group_bloc.dart';
import 'package:wallet/features/transactionsGroup/presentation/widgets/dialogs/edit_group_dialog.dart';
import 'package:wallet/features/transactionsGroup/presentation/widgets/transaction_group_card.dart';

part '../widgets/transaction_group_empty.dart';

class TransactionGroupScreen extends StatefulWidget {
  const TransactionGroupScreen({super.key});

  @override
  State<TransactionGroupScreen> createState() => _TransactionGroupScreenState();
}

class _TransactionGroupScreenState extends State<TransactionGroupScreen> {
  Set<int> selectedIds = {};
  bool isOnSelectMode = false;
  Future<void> _onAddPressed(BuildContext context) async {
    final result = await GroupNameDialog.show(context);
    if (result == null || !context.mounted) return; // cancelled

    context.read<TransactionGroupBloc>().add(
      AddTransactionGroupEvent(
        TransactionGroupEntity(
          name: result.name,
          description: result.description,
          createdAt: DateTime.now(),
        ),
      ),
    );
  }

  void Function()? onLongPress(int value) {
    setState(() {
      selectedIds.add(value);
      isOnSelectMode = true;
    });
  }

  void Function()? exitSelectionMode() {
    setState(() {
      isOnSelectMode = false;
      selectedIds.clear();
    });
  }

  void Function()? onTap(int value) {
    setState(() {
      if (selectedIds.contains(value)) {
        selectedIds.remove(value);
      } else {
        selectedIds.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: isOnSelectMode
            ? InkWell(onTap: exitSelectionMode, child: Icon(Icons.close))
            : null,
        actions: [
          if (isOnSelectMode)
            InkWell(
              onTap: () {
                for (var element in selectedIds) {
                  context.read<TransactionGroupBloc>().add(
                    DeleteTransactionGroupEvent(element),
                  );
                }
              },
              child: Icon(Icons.delete_outline, color: Colors.red),
            ),
        ],
        title: const Text('Transaction groups'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onAddPressed(context),
        icon: const Icon(Icons.add),
        label: const Text('New group'),
      ),
      body: BlocBuilder<TransactionGroupBloc, TransactionGroupState>(
        // Rebuild only when the list itself changes.
        buildWhen: (prev, curr) =>
            prev.transactionsGroups != curr.transactionsGroups,
        builder: (context, state) {
          final groups = state.transactionsGroups;

          if (groups.isEmpty) return const _EmptyState();

          return GridView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 96.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.05,
            ),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              bool isSelected = selectedIds.contains(group.id);
              return TransactionGroupCard(
                isSelected: isSelected,
                onTap: onTap,
                onLongPress: onLongPress,
                isOnSelectMode: isOnSelectMode,
                key: ValueKey(group.id),
                group: group,
              );
            },
          );
        },
      ),
    );
  }
}
