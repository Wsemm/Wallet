import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class EmptyHomeData extends StatelessWidget {
  const EmptyHomeData({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 56.r, color: Colors.grey.shade400),
            SizedBox(height: 12.h),
            Text(
              'No transactions recorded yet',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Tap the button below to add your first transaction.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
