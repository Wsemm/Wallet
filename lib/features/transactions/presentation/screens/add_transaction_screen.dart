import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';

import 'package:wallet/core/database/tables/transactions_table.dart';
import 'package:wallet/features/transactions/domain/entities/transaction_entity.dart';
import 'package:wallet/features/transactions/presentation/bloc/transaction_bloc.dart';

class AddTransactionScreen extends StatelessWidget {
  AddTransactionScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final ValueNotifier<String> _selectedTypeNotifier = ValueNotifier<String>('Expense');
  final ValueNotifier<bool> _isPeopleDebtNotifier = ValueNotifier<bool>(false);

  void _onSave(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text.trim();
      final amount = double.parse(_amountController.text.trim());
      final typeStr = _selectedTypeNotifier.value;

      final TransactionType type;
      final String category;

      switch (typeStr) {
        case 'Income':
          type = TransactionType.income;
          category = 'Income';
        case 'Debt':
          type = TransactionType.debt;
          category = _isPeopleDebtNotifier.value ? 'people_debt' : 'user_debt';
        case 'Expense':
        default:
          type = TransactionType.expense;
          category = 'Expense';
      }

      final transaction = TransactionEntity(
        title: title,
        amount: amount,
        type: type,
        category: category,
        createdAt: DateTime.now(),
      );

      context.read<TransactionBloc>().add(AddTransactionEvent(transaction));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Transaction',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Dropdown: Income / Expense / Debt
              ValueListenableBuilder<String>(
                valueListenable: _selectedTypeNotifier,
                builder: (context, currentType, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: currentType,
                        decoration: InputDecoration(
                          labelText: 'Transaction Type',
                          prefixIcon: Icon(
                            currentType == 'Income'
                                ? Icons.arrow_downward
                                : currentType == 'Expense'
                                    ? Icons.arrow_upward
                                    : Icons.account_balance_wallet,
                            color: currentType == 'Income'
                                ? Colors.green
                                : currentType == 'Expense'
                                    ? Colors.red
                                    : Colors.orange,
                            size: 22.r,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Income',
                            child: Text('Income'),
                          ),
                          DropdownMenuItem(
                            value: 'Expense',
                            child: Text('Expense'),
                          ),
                          DropdownMenuItem(
                            value: 'Debt',
                            child: Text('Debt'),
                          ),
                        ],
                        onChanged: (newValue) {
                          if (newValue != null) {
                            _selectedTypeNotifier.value = newValue;
                          }
                        },
                      ),
                      if (currentType == 'Debt') ...[
                        SizedBox(height: 12.h),
                        ValueListenableBuilder<bool>(
                          valueListenable: _isPeopleDebtNotifier,
                          builder: (context, isPeopleDebt, _) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: (isPeopleDebt ? Colors.blue : Colors.orange)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: (isPeopleDebt ? Colors.blue : Colors.orange)
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
                                      selected: !isPeopleDebt,
                                      selectedColor: Colors.orange.shade200,
                                      onSelected: (selected) {
                                        if (selected) {
                                          _isPeopleDebtNotifier.value = false;
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
                                      selected: isPeopleDebt,
                                      selectedColor: Colors.blue.shade200,
                                      onSelected: (selected) {
                                        if (selected) {
                                          _isPeopleDebtNotifier.value = true;
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  );
                },
              ),
              SizedBox(height: 18.h),

              // Title input
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

              // Amount input
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              SizedBox(height: 32.h),

              // Save Button
              FilledButton.icon(
                onPressed: () => _onSave(context),
                icon: Icon(Icons.save, size: 20.r),
                label: Text(
                  'Save Transaction',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
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
        ),
      ),
    );
  }
}
