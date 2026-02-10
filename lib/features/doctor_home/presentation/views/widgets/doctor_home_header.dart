import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class DoctorHomeHeader extends StatelessWidget {
  const DoctorHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A80DA), Color(0xFF754EA6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 25.w, top: 25.h, right: 15.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 33.r,
                backgroundColor: Colors.white,
                child: SvgPicture.asset(
                  Assets.imagesHeartRate,
                  height: 35.h,
                  width: 35.w,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF754EA6),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. UserName',
                    style: AppStyles.styleSemiBold18Dark.copyWith(
                      color: Colors.white,
                      fontSize: 18.sp,
                    ),
                  ),
                  Text(
                    'Cardiologist',
                    style: AppStyles.styleRegular14Gray.copyWith(
                      color: Colors.white70,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.notifications),
                color: Colors.white,
                iconSize: 28.sp,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
