import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Lottie.asset(
            'assets/lottie/Doctor Profile Completion.json',
            height: 220.h,
          ),
        ),

        Text(
          "Let's build your\nprofile!",
          style: TextStyle(
            fontSize: 30.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B5E8C),
          ),
        ),
        SizedBox(height: 10.h),

        Text(
          "Complete your professional details to unlock appointments and connect with patients.",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
