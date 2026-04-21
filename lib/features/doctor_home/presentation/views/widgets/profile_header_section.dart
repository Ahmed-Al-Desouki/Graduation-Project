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
        // Center(
        //   child: Container(
        //     height: 170.h,
        //     width: 200.w,
        //     decoration: BoxDecoration(
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.black.withOpacity(0.15),
        //           blurRadius: 10,
        //           offset: const Offset(10, 10),
        //         ),
        //       ],
        //       borderRadius: BorderRadius.only(
        //         topLeft: Radius.circular(30.r),
        //         bottomRight: Radius.circular(30.r),
        //       ),
        //     ),
        //     child: ClipRRect(
        //       borderRadius: BorderRadius.only(
        //         topLeft: Radius.circular(30.r),
        //         bottomRight: Radius.circular(30.r),
        //       ),
        //       child: Image.asset(
        //         Assets.imagesDoctorAnalyzingData,
        //         height: 170.h,
        //         width: 200.w,
        //         fit: BoxFit.cover,
        //       ),
        //     ),
        //   ),
        // ),
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
