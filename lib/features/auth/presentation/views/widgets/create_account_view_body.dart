import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/create_account_header.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/doctor_option_card.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/patient_option_card.dart';

class CreateAccountViewBody extends StatelessWidget {
  const CreateAccountViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CreateAccountHeader(
                  title: 'MedConnect',
                  subtitle: 'Your Healthcare Companion',
                  gradientColors: [Color(0xFF6A80DA), Color(0xFF754EA6)],
                  imagePath: Assets.imagesUserDoctor,
                ),
              ],
            ),
            SizedBox(height: 25.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.r),
                  child: Image.asset(
                    Assets.imagesPatient,
                    height: 120.h,
                    width: 120.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10.w),
                Column(
                  children: [
                    Text(
                      'Create your account',
                      style: AppStyles.styleSemiBold18Dark.copyWith(
                        fontSize: 25.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text.rich(
                      TextSpan(
                        text: 'Join thousands of users who trust\n',
                        style: AppStyles.styleRegular14Gray.copyWith(
                        fontSize: 12.sp,
                      ),
                        children: [
                          TextSpan(
                            text: 'MedConnect',
                            style: AppStyles.styleRegular14Gray.copyWith(
                        fontSize: 12.sp,
                      ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Choose your account type to get started',
                      style: AppStyles.styleRegular14Gray.copyWith(
                        fontSize: 12.sp,
                      ),
                      
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [PatientOptionCard(), DoctorOptionCard()],
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
                  style: AppStyles.styleRegular12Gray,
                ),
                TextButton(
                  onPressed: () {
                    final router = GoRouter.of(context);
                    if (router.canPop()) {
                      router.pop();
                    } else {
                      router.go(AppRouter.kLogin);
                    }
                  },
                  child: Text('Sign in', style: AppStyles.styleMedium12Blue),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              '© 2024 MediConnect. All rights reserved.',
              style: AppStyles.styleRegular12Gray,
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
