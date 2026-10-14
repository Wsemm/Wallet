import 'package:equatable/equatable.dart';

import '../../../../core/database/tables/transactions_table.dart';

class TransactionEntity extends Equatable {
  final int? id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final String? note;
  final DateTime createdAt;
  final int? groupId;
  final String? groupName;
  final String? groupDesc;

  const TransactionEntity({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.note,
    this.groupId,
    this.groupName,
    this.groupDesc,
    required this.createdAt,
  });

  bool get isPeopleDebt =>
      type == TransactionType.debt && category == 'people_debt';

  /// Signed amount used for balance and multi-select totals.
  double get signedAmount {
    return switch (type) {
      TransactionType.income => amount,
      TransactionType.expense => -amount,
      TransactionType.debt => isPeopleDebt ? amount : -amount,
    };
  }

  TransactionEntity copyWith({
    int? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? category,
    String? note,
    bool clearNote = false,
    DateTime? createdAt,
    String? groupName,
    String? groupDesc,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      note: clearNote ? null : (note ?? this.note),
      createdAt: createdAt ?? this.createdAt,
      groupName: groupName ?? this.groupName,
      groupDesc: groupDesc ?? this.groupDesc,
      groupId: groupId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    amount,
    type,
    category,
    note,
    createdAt,
    groupId,
    groupName,
    groupDesc,
  ];
}
