part of '../screens/transaction_group_screen.dart';

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 64.sp,
              color: theme.colorScheme.outline,
            ),
            SizedBox(height: 16.h),
            Text('No groups yet', style: theme.textTheme.titleMedium),
            SizedBox(height: 8.h),
            Text(
              'Create a group to organize your transactions.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
