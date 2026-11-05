import 'package:drift/drift.dart';
import 'package:wallet/core/database/tables/transactions_group_table.dart';

enum TransactionType { income, expense, debt }

class TransactionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get type => textEnum<TransactionType>()();
  TextColumn get category => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isArchived => boolean().nullable()();
  // Foreign Key referencing GroupsTable
  IntColumn get groupId => integer().nullable().references(
    TransactionsGroupsTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
}
