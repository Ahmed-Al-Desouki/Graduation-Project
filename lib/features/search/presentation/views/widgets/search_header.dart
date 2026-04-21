import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/app_images.dart';

class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF22C57E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30.r),
            child: Image.asset(
              Assets.imagesFindYourDoctor,
              height: 100.h,
              width: 100.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            "Find a Specialist",
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "Connect with the right doctor for your needs",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
