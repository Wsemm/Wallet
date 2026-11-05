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
  final bool? isArchived;

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
    this.isArchived,
  });

  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    late TransactionType type;
    switch (json["type"]) {
      case "income":
        type = TransactionType.income;
        break;
      case "debt":
        type = TransactionType.debt;
        break;
      case "expense":
        type = TransactionType.expense;
      default:
        type = TransactionType.income;
    }
    return TransactionEntity(
      title: json["title"],
      amount: double.parse(json["amount"].toString()),
      type: type,
      category: json["category"],
      createdAt: DateTime.now(),
      note: json["note"],
      isArchived: json["isArchived"],
    );
  }

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
    bool? isArchived,
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
      isArchived: isArchived ?? this.isArchived,
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
    isArchived,
  ];

  Map<String, dynamic> toJson(TransactionEntity item) {
    return {
      "id": item.id,
      "title": item.title,
      "amount": item.amount,
      "type": item.type.name,
      "category": item.category,
      "note": item.note,
      "createdAt": item.createdAt.toString(),
      "groupId": item.groupId,
      "groupName": item.groupName,
      "groupDesc": item.groupDesc,
      "isArchived": item.isArchived,
    };
  }
}
