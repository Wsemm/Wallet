import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:wallet/core/extinitions/time_format.dart';

import 'package:wallet/features/analytics/domain/analytics_period.dart';
import 'package:wallet/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:wallet/features/transactions/presentation/widgets/transaction_dialogs.dart';
import 'package:wallet/features/transactions/presentation/widgets/transaction_list_item.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  late final TabController _tabController;

  static const _ranges = AnalyticsRange.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _ranges.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  AnalyticsRange get _range => _ranges[_tabController.index];

  String _rangeNoun(AnalyticsRange range) => switch (range) {
    AnalyticsRange.day => 'today',
    AnalyticsRange.week => 'this week',
    AnalyticsRange.month => 'this month',
    AnalyticsRange.year => 'this year',
    AnalyticsRange.specfic => 'specfic',
  };

  String _previousNoun(AnalyticsRange range) => switch (range) {
    AnalyticsRange.day => 'yesterday',
    AnalyticsRange.week => 'last week',
    AnalyticsRange.month => 'last month',
    AnalyticsRange.year => 'last year',
    AnalyticsRange.specfic => 'last specfic',
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Day'),
            Tab(text: 'Week'),
            Tab(text: 'Month'),
            Tab(text: 'Year'),
            Tab(text: 'Specfic'),
          ],
        ),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          final snapshot = buildAnalyticsSnapshot(
            transactions: state.transactions,
            range: _range,
            specfic: _selectedDate,
          );

          return CustomScrollView(
            slivers: [
              if (AnalyticsRange.specfic == _range)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(
                                Duration(days: 365 * 50),
                              ),
                            ).then((value) {
                              if (value != null) {
                                setState(() {
                                  _selectedDate = value;
                                });
                              }
                            });
                          },
                          child: Row(
                            children: [
                              Text("Selecte Date:"),
                              SizedBox(width: 10.w),
                              Icon(Icons.date_range),
                            ],
                          ),
                        ),
                        Spacer(),
                        Text(_selectedDate.toString().toDateFormatted()),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AnalyticsTotalCard(
                          title: 'Income ${_rangeNoun(_range)}',
                          amount: snapshot.currentIncome,
                          color: Colors.green,
                          previousLabel:
                              'Income ${_previousNoun(_range)}: \$${snapshot.previousIncome.toStringAsFixed(2)}',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _AnalyticsTotalCard(
                          title: 'Expenses ${_rangeNoun(_range)}',
                          amount: snapshot.currentExpense,
                          color: Colors.red,
                          previousLabel:
                              'Expenses ${_previousNoun(_range)}: \$${snapshot.previousExpense.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (snapshot.groups.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No operations in this period',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                for (final group in snapshot.groups) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                      child: Text(
                        group.label,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = group.transactions[index];
                        return TransactionListItem(
                          item: item,
                          onEdit: () => showEditTransactionSheet(context, item),
                          onDelete: () =>
                              confirmDeleteTransaction(context, item),
                        );
                      }, childCount: group.transactions.length),
                    ),
                  ),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _AnalyticsTotalCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final String previousLabel;

  const _AnalyticsTotalCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.previousLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
            ),
            SizedBox(height: 6.h),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              previousLabel,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
