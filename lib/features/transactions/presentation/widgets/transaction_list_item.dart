import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:wallet/core/database/tables/transactions_table.dart';
import 'package:wallet/features/transactions/domain/entities/transaction_entity.dart';
import 'package:wallet/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:wallet/features/transactionsGroup/presentation/bloc/transaction_group_bloc.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionEntity item;
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionListItem({
    super.key,
    required this.item,
    this.selectionMode = false,
    this.selected = false,
    this.onTap,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPeopleDebt = item.isPeopleDebt;
    TransactionGroupBloc groupBloc = context.read<TransactionGroupBloc>();
    TransactionBloc taBloc = context.read<TransactionBloc>();

    final (badgeColor, badgeIcon, sign) = switch (item.type) {
      TransactionType.income => (Colors.green, Icons.arrow_downward, '+'),
      TransactionType.expense => (Colors.red, Icons.arrow_upward, '-'),
      TransactionType.debt =>
        isPeopleDebt
            ? (Colors.blue, Icons.handshake, '+')
            : (Colors.orange, Icons.money_off, '-'),
    };

    final hour24 = item.createdAt.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final amPm = hour24 >= 12 ? 'PM' : 'AM';

    final dateStr =
        '${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')} ${hour12.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')} $amPm';

    final note = item.note?.trim();

    return BlocListener<TransactionGroupBloc, TransactionGroupState>(
      listener: (context, state) {
        if (state.status == TransactionGroupStatus.updated) {
          taBloc.add(LoadTransactionsEvent());
          log("updated group");
        }
      },
      child: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state.status == TransactionStatus.updated) {
            taBloc.add(LoadTransactionsEvent());
            log("updated trans");
          }
        },
        child: BlocBuilder<TransactionGroupBloc, TransactionGroupState>(
          builder: (context, state) {
            return Card(
              margin: EdgeInsets.only(bottom: 15.h),
              elevation: 1,
              color: selected
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.45)
                  : theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(
                  color: selected
                      ? theme.colorScheme.primary.withValues(alpha: 0.5)
                      : theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.35,
                        ),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Dismissible(
                onDismissed: (direction) {
                  if (item.isArchived == true) {
                    taBloc.add(
                      UpdateTransactionEvent(item.copyWith(isArchived: false)),
                    );
                  } else {
                    taBloc.add(
                      UpdateTransactionEvent(item.copyWith(isArchived: true)),
                    );
                  }
                },
                key: Key(item.id.toString()),
                background: Container(
                  color: item.isArchived == true ? Colors.red : Colors.green,
                  child: Center(
                    child: Text(
                      item.isArchived == true
                          ? "Remove from archive"
                          : "Add to archive",
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium!.copyWith(color: Colors.white),
                    ),
                  ),
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group header
                    if (item.groupName?.trim().isNotEmpty == true)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.35,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.folder_outlined,
                              size: 15.r,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                item.groupName!.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            Text(
                              'GROUP',
                              style: TextStyle(
                                fontSize: 9.sp,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Transaction content
                    ListTile(
                      onTap: onTap,
                      onLongPress: onLongPress,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 4.h,
                      ),
                      leading: selectionMode
                          ? Checkbox(
                              value: selected,
                              onChanged: (_) => onTap?.call(),
                            )
                          : CircleAvatar(
                              radius: 18.r,
                              backgroundColor: badgeColor.withValues(
                                alpha: 0.15,
                              ),
                              child: Icon(
                                badgeIcon,
                                size: 18.r,
                                color: badgeColor,
                              ),
                            ),
                      title: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 4.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              isPeopleDebt ? 'People Debt' : item.category,
                              style: TextStyle(fontSize: 10.sp),
                            ),
                          ),
                          if (note != null && note.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                note,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                item.amount.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: badgeColor,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          if (!selectionMode && item.id != null) ...[
                            SizedBox(width: 10.w),
                            Tooltip(
                              message: 'Edit',
                              child: GestureDetector(
                                onTap: onEdit,
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 18.r,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Tooltip(
                              message: 'Delete',
                              child: GestureDetector(
                                onTap: onDelete,
                                child: Icon(
                                  Icons.delete_outline,
                                  size: 18.r,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
