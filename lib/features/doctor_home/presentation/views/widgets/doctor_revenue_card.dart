import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DoctorRevenueCard extends StatelessWidget {
  final String title;
  final String amount;
  final String percentage;
  final bool isIncrease;
  final IconData icon;
  final Color color;
  const DoctorRevenueCard({
    super.key,
    required this.title,
    required this.amount,
    required this.percentage,
    required this.isIncrease,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                amount,
                style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 2.h),
              Text(title, style: TextStyle(fontSize: 14.sp)),
            ],
          ),
          Spacer(flex: 1),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color:
                  isIncrease
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  isIncrease
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color:
                      isIncrease ? const Color(0xFF4CAF50) : Colors.redAccent,
                  size: 18.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  percentage,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
