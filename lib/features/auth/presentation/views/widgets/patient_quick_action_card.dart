// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:graduation_project/core/utils/app_styles.dart';

// class PatientQuickActionCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final Color gradientColor;
//   final String imageAsset;
//   final Color? iconColor;
//   final VoidCallback? onTap;

//   const PatientQuickActionCard({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.gradientColor,
//     required this.imageAsset,
//     this.iconColor,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 40),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(15),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [gradientColor, Colors.white],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: gradientColor.withOpacity(0.4),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       title,
//                       style: AppStyles.styleSemiBold18Dark.copyWith(
//                         color: Colors.white,
//                         fontSize: 20,
//                       ),
//                     ),
//                     SizedBox(height: 2),
//                     Text(
//                       subtitle,
//                       style: AppStyles.styleRegular14White.copyWith(
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SvgPicture.asset(
//                   imageAsset,
//                   height: 60,
//                   width: 60,
//                   colorFilter: iconColor != null
//                       ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
//                       : null,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class PatientQuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color gradientColor;
  final String imageAsset;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool isSvg;

  const PatientQuickActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gradientColor,
    required this.imageAsset,
    this.iconColor,
    this.onTap,
    this.isSvg = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientColor, Colors.white],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [
                BoxShadow(
                  color: gradientColor.withOpacity(0.4),
                  blurRadius: 8.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppStyles.styleSemiBold18Dark.copyWith(
                        color: Colors.white,
                        fontSize: 20.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppStyles.styleRegular14White.copyWith(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                isSvg
                ? SvgPicture.asset(
                    imageAsset,
                    height: 60.h,
                    width: 60.w,
                    colorFilter: iconColor != null
                        ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                        : null,
                  )
                : Image.asset(
                    imageAsset,
                    height: 60.h,
                    width: 60.w,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
