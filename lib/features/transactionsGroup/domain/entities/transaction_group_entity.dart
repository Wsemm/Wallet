import 'package:equatable/equatable.dart';

class TransactionGroupEntity extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final DateTime createdAt;

  const TransactionGroupEntity({
    this.id,
    this.description,
    required this.name,
    required this.createdAt,
  });

  TransactionGroupEntity copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return TransactionGroupEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, description, createdAt];
}
