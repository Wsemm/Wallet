import 'package:drift/drift.dart';

enum TransactionType {
  income,
  expense,
  debt,
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get type => textEnum<TransactionType>()();
  TextColumn get category => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
