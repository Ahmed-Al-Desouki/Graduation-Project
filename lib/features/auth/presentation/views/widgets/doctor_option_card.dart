import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class DoctorOptionCard extends StatelessWidget {
  const DoctorOptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => AppRouter.router.go(AppRouter.kRegisterAsDoctor),
      child: Container(
        width: 0.48.sw,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: Color.fromARGB(255, 216, 187, 247),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25.r),
                child: Image.asset(
                  Assets.imagesDoctor,
                  height: 80.h,
                  width: 80.h,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "I'm a Doctor",
                style: AppStyles.styleSemiBold18Dark.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Manage patients,\nconsultations & practice',
                textAlign: TextAlign.center,
                style: AppStyles.styleRegular14Gray,
              ),
              SizedBox(height: 15.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.r),
                  color: const Color(0xFFF3E8FF),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      Assets.imagesStethoscope,
                      height: 20.h,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF9333EA),
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Practice Management',
                      style: AppStyles.styleMedium12Purple.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
