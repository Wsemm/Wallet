import 'package:equatable/equatable.dart';

import '../../../../core/database/tables/transactions_table.dart';

class TransactionEntity extends Equatable {
  final int? id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime createdAt;

  const TransactionEntity({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, amount, type, category, createdAt];
}
