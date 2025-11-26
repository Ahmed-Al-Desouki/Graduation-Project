// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:graduation_project/core/utils/app_images.dart';
// import 'package:graduation_project/core/utils/app_styles.dart';

// class PatientHomeHeader extends StatelessWidget {
//   const PatientHomeHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 90,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFF00BCD4), Color(0xff66BB6A)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.only(left: 25,top: 15),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 30,
//                 backgroundColor: Colors.white,
//                 child: SvgPicture.asset(
//                   Assets.imagesHeartRate,
//                   height: 30,
//                   width: 30,
//                   colorFilter: const ColorFilter.mode(
//                     Color(0xff26A69A),
//                     BlendMode.srcIn,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Welcome UserName',
//                     style: AppStyles.styleSemiBold18Dark.copyWith(
//                       color: Colors.white,
//                       fontSize: 18,
//                     ),
//                   ),
//                   Text(
//                     'How are you feeling today?',
//                     style: AppStyles.styleRegular14Gray.copyWith(
//                       color: Colors.white70,
//                     ),
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               IconButton(
//                 icon: const Icon(Icons.notifications),
//                 color: Colors.white,
//                 iconSize: 28,
//                 onPressed: () {},
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class PatientHomeHeader extends StatelessWidget {
  const PatientHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00BCD4), Color(0xff66BB6A)],
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
          padding: EdgeInsets.only(left: 25.w, top: 15.h, right: 15.w),
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
                    Color(0xff26A69A),
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
                    'Welcome UserName',
                    style: AppStyles.styleSemiBold18Dark.copyWith(
                      color: Colors.white,
                      fontSize: 18.sp,
                    ),
                  ),
                  Text(
                    'How are you feeling today?',
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
