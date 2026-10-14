import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet/core/router/app_router.dart';
import 'package:wallet/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:wallet/features/transactionsGroup/domain/entities/transaction_group_entity.dart';
import 'package:wallet/features/transactionsGroup/presentation/bloc/transaction_group_bloc.dart';
import 'package:wallet/features/transactionsGroup/presentation/widgets/dialogs/delete_group_dialog.dart';
import 'package:wallet/features/transactionsGroup/presentation/widgets/dialogs/edit_group_dialog.dart';

enum _GroupAction { edit, delete }

class TransactionGroupCard extends StatefulWidget {
  const TransactionGroupCard({
    super.key,
    required this.group,
    required this.onLongPress,
    required this.isOnSelectMode,
    required this.isSelected,
    required this.onTap,
  });
  final TransactionGroupEntity group;
  final void Function(int id)? onLongPress;
  final bool isOnSelectMode;
  final bool isSelected;
  final ValueChanged<int> onTap;

  @override
  State<TransactionGroupCard> createState() => _TransactionGroupCardState();
}

class _TransactionGroupCardState extends State<TransactionGroupCard> {
  int countOfItems = 0;

  Future<void> _onEdit(BuildContext context) async {
    final result = await GroupNameDialog.show(
      context,
      initialName: widget.group.name,
      initialDesc: widget.group.description,
    );
    if (result == null || !context.mounted) return;

    context.read<TransactionGroupBloc>().add(
      UpdateTransactionGroupEvent(
        widget.group.copyWith(
          name: result.name,
          description: result.description,
        ),
      ),
    );
  }

  Future<void> _onDelete(BuildContext context) async {
    final id = widget.group.id;
    if (id == null) return;

    final confirmed = await ConfirmDeleteDialog.show(
      context,
      groupName: widget.group.name,
    );
    if (!confirmed || !context.mounted) return;

    context.read<TransactionGroupBloc>().add(DeleteTransactionGroupEvent(id));
  }

  void _onMenuSelected(BuildContext context, _GroupAction action) {
    switch (action) {
      case _GroupAction.edit:
        _onEdit(context);
      case _GroupAction.delete:
        _onDelete(context);
    }
  }

  getCountOfItems() {
    var trans = context.read<TransactionBloc>().state.transactions;

    setState(() {
      countOfItems = trans
          .where((element) => element.groupId == widget.group.id)
          .length;
    });
  }

  @override
  void initState() {
    getCountOfItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final description = widget.group.description?.trim();

    return Card(
      clipBehavior: Clip.antiAlias,
      color: widget.isSelected ? Colors.grey[300] : null,
      child: InkWell(
        onTap: () {
          widget.isOnSelectMode
              ? widget.onTap(widget.group.id!)
              : context.push(AppRoutes.transactionByGroup, extra: widget.group);
        },
        onLongPress: () {
          widget.onLongPress!(widget.group.id!);
        },

        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 4.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (widget.isOnSelectMode)
                    Checkbox(value: widget.isSelected, onChanged: (value) {})
                  else
                    PopupMenuButton<_GroupAction>(
                      tooltip: 'Group options',
                      onSelected: (action) => _onMenuSelected(context, action),
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: _GroupAction.edit,
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Rename'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        PopupMenuItem(
                          value: _GroupAction.delete,
                          child: ListTile(
                            leading: Icon(
                              Icons.delete_outline,
                              color: scheme.error,
                            ),
                            title: Text(
                              'Delete',
                              style: TextStyle(color: scheme.error),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 4.h),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Text(
                    (description == null || description.isEmpty)
                        ? 'No description'
                        : description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              Text("$countOfItems items"),
            ],
          ),
        ),
      ),
    );
  }
}
