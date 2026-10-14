import '../../../../core/database/tables/transactions_table.dart';
import '../../transactions/domain/entities/transaction_entity.dart';

enum AnalyticsRange { day, week, month, year, specfic }

class DateWindow {
  const DateWindow({required this.start, required this.endExclusive});

  final DateTime start;
  final DateTime endExclusive;

  bool contains(DateTime date) {
    return !date.isBefore(start) && date.isBefore(endExclusive);
  }
}

class AnalyticsGroup {
  const AnalyticsGroup({required this.label, required this.transactions});

  final String label;
  final List<TransactionEntity> transactions;
}

class AnalyticsSnapshot {
  const AnalyticsSnapshot({
    required this.range,
    required this.current,
    required this.previous,
    required this.currentIncome,
    required this.currentExpense,
    required this.previousIncome,
    required this.previousExpense,
    required this.groups,
  });

  final AnalyticsRange range;
  final DateWindow current;
  final DateWindow previous;
  final double currentIncome;
  final double currentExpense;
  final double previousIncome;
  final double previousExpense;
  final List<AnalyticsGroup> groups;
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _mondayOf(DateTime date) {
  final day = _dateOnly(date);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

DateWindow currentWindow(AnalyticsRange range, DateTime now) {
  final today = _dateOnly(now);
  return switch (range) {
    AnalyticsRange.day => DateWindow(
      start: today,
      endExclusive: today.add(const Duration(days: 1)),
    ),
    AnalyticsRange.week => DateWindow(
      start: _mondayOf(today),
      endExclusive: _mondayOf(today).add(const Duration(days: 7)),
    ),
    AnalyticsRange.month => DateWindow(
      start: DateTime(today.year, today.month),
      endExclusive: DateTime(today.year, today.month + 1),
    ),
    AnalyticsRange.year => DateWindow(
      start: DateTime(today.year),
      endExclusive: DateTime(today.year + 1),
    ),
    AnalyticsRange.specfic => DateWindow(start: now, endExclusive: now),
  };
}

DateWindow previousWindow(AnalyticsRange range, DateWindow current) {
  return switch (range) {
    AnalyticsRange.day => DateWindow(
      start: current.start.subtract(const Duration(days: 1)),
      endExclusive: current.start,
    ),
    AnalyticsRange.week => DateWindow(
      start: current.start.subtract(const Duration(days: 7)),
      endExclusive: current.start,
    ),
    AnalyticsRange.month => DateWindow(
      start: DateTime(current.start.year, current.start.month - 1),
      endExclusive: current.start,
    ),
    AnalyticsRange.year => DateWindow(
      start: DateTime(current.start.year - 1),
      endExclusive: current.start,
    ),
    AnalyticsRange.specfic => DateWindow(
      start: current.start,
      endExclusive: current.endExclusive,
    ),
  };
}

double _sumByType(List<TransactionEntity> items, TransactionType type) {
  return items
      .where((t) => t.type == type)
      .fold(0.0, (sum, t) => sum + t.amount);
}

String _twoDigits(int n) => n.toString().padLeft(2, '0');

String _groupLabel(AnalyticsRange range, DateTime date) {
  return switch (range) {
    AnalyticsRange.day => '${_twoDigits(date.hour)}:00',
    AnalyticsRange.week || AnalyticsRange.month =>
      '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}',
    AnalyticsRange.year => '${date.year}-${_twoDigits(date.month)}',
    AnalyticsRange.specfic =>
      '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}',
  };
}

String _groupKey(AnalyticsRange range, DateTime date) {
  return switch (range) {
    AnalyticsRange.day => '${date.year}-${date.month}-${date.day}-${date.hour}',
    AnalyticsRange.week ||
    AnalyticsRange.month => '${date.year}-${date.month}-${date.day}',
    AnalyticsRange.year => '${date.year}-${date.month}',
    AnalyticsRange.specfic =>
      '${date.year}-${date.month}-${date.day}-${date.hour}',
  };
}

AnalyticsSnapshot buildAnalyticsSnapshot({
  required List<TransactionEntity> transactions,
  required AnalyticsRange range,
  DateTime? now,
  DateTime? specfic,
}) {
  final current = currentWindow(range, now ?? DateTime.now());
  final previous = previousWindow(range, current);

  var currentItems = transactions
      .where((t) => current.contains(t.createdAt))
      .toList();
  var previousItems = transactions
      .where((t) => previous.contains(t.createdAt))
      .toList();

  if (range == AnalyticsRange.specfic) {
    currentItems = transactions
        .where(
          (t) =>
              (specfic!.day == t.createdAt.day) &&
              (specfic!.month == t.createdAt.month) &&
              (specfic!.year == t.createdAt.year),
        )
        .toList();
    // previousItems = transactions
    //     .where((t) => previous.contains(t.createdAt))
    //     .toList();
  }

  final grouped = <String, List<TransactionEntity>>{};
  for (final item in currentItems) {
    grouped.putIfAbsent(_groupKey(range, item.createdAt), () => []).add(item);
  }

  final groups =
      grouped.entries
          .map(
            (entry) => AnalyticsGroup(
              label: _groupLabel(range, entry.value.first.createdAt),
              transactions: entry.value,
            ),
          )
          .toList()
        ..sort(
          (a, b) => b.transactions.first.createdAt.compareTo(
            a.transactions.first.createdAt,
          ),
        );

  return AnalyticsSnapshot(
    range: range,
    current: current,
    previous: previous,
    currentIncome: _sumByType(currentItems, TransactionType.income),
    currentExpense: _sumByType(currentItems, TransactionType.expense),
    previousIncome: _sumByType(previousItems, TransactionType.income),
    previousExpense: _sumByType(previousItems, TransactionType.expense),
    groups: groups,
  );
}
