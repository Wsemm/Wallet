import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet/features/transactions/domain/entities/transaction_entity.dart';

import 'package:wallet/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:wallet/features/transactions/presentation/widgets/transaction_form.dart';
import 'package:wallet/features/transactionsGroup/presentation/bloc/transaction_group_bloc.dart';

class AddTransactionScreen extends StatelessWidget {
  final TransactionEntity? transactionEntity;
  const AddTransactionScreen({super.key, this.transactionEntity});

  @override
  Widget build(BuildContext context) {
    TransactionGroupBloc bloc = context.read<TransactionGroupBloc>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Transaction',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: TransactionForm(
          initial: transactionEntity,
          submitLabel: 'Save Transaction',
          onSubmit: (transaction) {
            context.read<TransactionBloc>().add(
              AddTransactionEvent(transaction),
            );
            context.pop();
          },
          onAddTransactionGroup: (transactionGroup) {
            bloc.add(AddTransactionGroupEvent(transactionGroup));
          },
        ),
      ),
    );
  }
}
