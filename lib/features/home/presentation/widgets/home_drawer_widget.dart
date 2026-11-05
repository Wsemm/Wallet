import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet/core/app/helper/cache_helper.dart';
import 'package:wallet/core/app/helper/restart_function.dart';
import 'package:wallet/core/app/theme/bloc/theme_bloc.dart';
import 'package:wallet/core/services/local/export_excel_service.dart';
import 'package:wallet/features/home/presentation/screens/voice_control_screen.dart';
import 'package:wallet/features/transactions/presentation/bloc/transaction_bloc.dart';

class HomeDrawerWidget extends StatelessWidget {
  const HomeDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Builder(
          builder: (BuildContext innerContext) {
            final theme = Theme.of(innerContext);

            return Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 24.h,
                    horizontal: 12.w,
                  ),
                  width: 280
                      .w, // Slightly widened to safely fit structured text fields
                  color: theme
                      .colorScheme
                      .surfaceContainerLow, // Modern M3 background container token
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Segment
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 16.h,
                          left: 8.w,
                          right: 8.w,
                        ),
                        child: Text(
                          "Settings",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),

                      // 1. Theme Configuration Card
                      Card(
                        elevation: 0,
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                        margin: EdgeInsets.symmetric(vertical: 6.h),
                        child: ListTile(
                          leading: const Icon(Icons.palette_outlined),
                          title: const Text("Theme"),
                          subtitle: const Text("Dark Mode"),
                          trailing: Transform.scale(
                            scale: 0.8,
                            child: Switch.adaptive(
                              value:
                                  CacheHelper().getData(key: "theme") ?? false,
                              onChanged: (value) {
                                innerContext.read<ThemeBloc>().add(
                                  ChangeThemeEvent(themeValue: value),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // 2. Data Management (Export) Card
                      Card(
                        elevation: 0,
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                        margin: EdgeInsets.symmetric(vertical: 6.h),
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.ios_share_outlined),
                                  SizedBox(width: 12.w),
                                  Text(
                                    "Data Storage",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.file_download_outlined,
                                    size: 18,
                                  ),
                                  label: const Text("Export to Excel file"),
                                  onPressed: () async {
                                    var state = innerContext
                                        .read<TransactionBloc>()
                                        .state;
                                    exportToExcel(
                                      context: innerContext,
                                      data: state.transactions
                                          .map((e) => e.toJson(e))
                                          .toList(),
                                      summary: [
                                        {
                                          "totalIncome": state.totalIncome,
                                          "totalExpense": state.totalExpense,
                                          "totalDebits": state.totalDebits,
                                          "totalBalance": state.totalBalance,
                                          "totalPeopleDebits":
                                              state.totalPeopleDebits,
                                        },
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 3. AI Assistance Card
                      Card(
                        elevation: 0,
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                        margin: EdgeInsets.symmetric(vertical: 6.h),
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome_outlined),
                                  SizedBox(width: 12.w),
                                  Text(
                                    "AI Support",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.tonalIcon(
                                  icon: const Icon(
                                    Icons.mic_none_rounded,
                                    size: 18,
                                  ),
                                  label: const Text("Order action by voice"),
                                  onPressed: () async {
                                    Navigator.of(innerContext).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const VoiceControlScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // 4. Dangerous Actions Segment (Destructive Bottom Button)
                      Divider(color: theme.colorScheme.outlineVariant),
                      SizedBox(height: 8.h),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          icon: const Icon(Icons.delete_forever_outlined),
                          label: const Text("Delete Database"),
                          onPressed: () async {
                            bool? confirmDelete = await showDialog<bool>(
                              context: innerContext,
                              builder: (context) => AlertDialog(
                                icon: Icon(
                                  Icons.warning_amber_rounded,
                                  color: theme.colorScheme.error,
                                  size: 36,
                                ),
                                title: const Text("Delete Database?"),
                                content: const Text(
                                  "Are you sure you need to delete the database? This action cannot be undone.",
                                  textAlign: TextAlign.center,
                                ),
                                actionsAlignment: MainAxisAlignment.spaceEvenly,
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("Cancel"),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: theme.colorScheme.error,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text("Yes, Delete"),
                                  ),
                                ],
                              ),
                            );
                            if (confirmDelete == true && innerContext.mounted) {
                              performFullAppReset(innerContext);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => context.pop(),
                    child: Container(color: Colors.transparent, height: 1.sh),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
