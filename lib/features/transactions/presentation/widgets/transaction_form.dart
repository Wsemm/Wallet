import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:wallet/core/database/app_database.dart';
import 'package:wallet/features/transactions/domain/entities/transaction_entity.dart';
import 'package:wallet/features/transactionsGroup/domain/entities/transaction_group_entity.dart';
import 'package:wallet/features/transactionsGroup/presentation/bloc/transaction_group_bloc.dart';

class TransactionForm extends StatefulWidget {
  final TransactionEntity? initial;
  final String submitLabel;
  final ValueChanged<TransactionEntity> onSubmit;
  final ValueChanged<TransactionGroupEntity>? onAddTransactionGroup;

  const TransactionForm({
    super.key,
    this.initial,
    this.onAddTransactionGroup,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late String _selectedType;
  late bool _isPeopleDebt;
  int? _selectedGroupId; // Nullable to store selected group ID
  List<TransactionsGroupsTableData> _groups = []; // Populated from database

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _amountController = TextEditingController(
      text: initial == null ? '' : initial.amount.toStringAsFixed(2),
    );
    _noteController = TextEditingController(text: initial?.note ?? '');
    _selectedType = switch (initial?.type) {
      TransactionType.income => 'Income',
      TransactionType.debt => 'Debt',
      TransactionType.expense || null => 'Expense',
    };
    _selectedGroupId = initial?.groupId; // Nullable to store selected group ID

    _isPeopleDebt = initial?.isPeopleDebt ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final TransactionType type;
    final String category;
    switch (_selectedType) {
      case 'Income':
        type = TransactionType.income;
        category = 'Income';
      case 'Debt':
        type = TransactionType.debt;
        category = _isPeopleDebt ? 'people_debt' : 'user_debt';
      case 'Expense':
      default:
        type = TransactionType.expense;
        category = 'Expense';
    }

    final note = _noteController.text.trim();
    widget.onSubmit(
      TransactionEntity(
        id: widget.initial?.id,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        type: type,
        category: category,
        note: note.isEmpty ? null : note,
        createdAt: widget.initial?.createdAt ?? DateTime.now(),
        groupId: _selectedGroupId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionGroupBloc, TransactionGroupState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int?>(
                initialValue: _selectedGroupId,
                decoration: InputDecoration(
                  labelText: 'Group (Optional)',
                  prefixIcon: Icon(
                    Icons.folder_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 22.r,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                items: [
                  // 1. First Item: Create New Group Action
                  DropdownMenuItem<int?>(
                    value: -1, // Unique marker value for creation
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).primaryColor,
                          size: 20.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Create New Group',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 2. List fetched groups dynamically
                  ...state.transactionsGroups.map(
                    (group) => DropdownMenuItem<int?>(
                      value: group.id,
                      child: Text(group.name),
                    ),
                  ),
                ],
                onChanged: (value) async {
                  if (value == -1) {
                    // User tapped "Create New Group"
                    await _showCreateGroupDialog();
                  } else {
                    // User selected an existing group
                    setState(() => _selectedGroupId = value);
                  }
                },
              ),
              SizedBox(height: 20.h),

              DropdownButtonFormField<String>(
                key: ValueKey(_selectedType),
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Transaction Type',
                  prefixIcon: Icon(
                    _selectedType == 'Income'
                        ? Icons.arrow_downward
                        : _selectedType == 'Expense'
                        ? Icons.arrow_upward
                        : Icons.account_balance_wallet,
                    color: _selectedType == 'Income'
                        ? Colors.green
                        : _selectedType == 'Expense'
                        ? Colors.red
                        : Colors.orange,
                    size: 22.r,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Income', child: Text('Income')),
                  DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                  DropdownMenuItem(value: 'Debt', child: Text('Debt')),
                ],
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() => _selectedType = newValue);
                  }
                },
              ),

              if (_selectedType == 'Debt') ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: (_isPeopleDebt ? Colors.blue : Colors.orange)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: (_isPeopleDebt ? Colors.blue : Colors.orange)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text(
                            'Debits (I owe)',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          selected: !_isPeopleDebt,
                          selectedColor: Colors.orange.shade200,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _isPeopleDebt = false);
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ChoiceChip(
                          label: Text(
                            'People debits (Owed to me)',
                            style: TextStyle(fontSize: 11.sp),
                          ),
                          selected: _isPeopleDebt,
                          selectedColor: Colors.blue.shade200,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _isPeopleDebt = true);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 18.h),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Salary, Grocery, Loan',
                  prefixIcon: Icon(Icons.description, size: 20.r),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 18.h),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money, size: 20.r),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),
              SizedBox(height: 18.h),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'Add a custom note',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40.h),
                    child: Icon(Icons.notes, size: 20.r),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              FilledButton.icon(
                onPressed: _onSave,
                icon: Icon(Icons.save, size: 20.r),
                label: Text(
                  widget.submitLabel,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCreateGroupDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    final String? groupName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 25.h),
            TextField(
              controller: descController,
              autofocus: false,
              decoration: const InputDecoration(
                labelText: 'Group Description',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (groupName != null && groupName.isNotEmpty) {
      // 1. Insert group into database
      widget.onAddTransactionGroup!(
        TransactionGroupEntity(
          name: groupName,
          description: descController.text.trim(),
          createdAt: widget.initial?.createdAt ?? DateTime.now(),
        ),
      );

      // // 2. Fetch updated groups and set newly created group as selected
      // final updatedGroups = await db.select(db.transactionsGroupsTable).get();
      // setState(() {
      //   _groups = updatedGroups;
      //   _selectedGroupId = newGroupId;
      // });
    }
  }
}
