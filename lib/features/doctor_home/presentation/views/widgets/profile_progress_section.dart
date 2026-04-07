// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class ProfileProgressSection extends StatelessWidget {
//   final int currentStep;
//   final int totalSteps;
//   const ProfileProgressSection({
//     super.key,
//     required this.currentStep,
//     required this.totalSteps,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "Step $currentStep of $totalSteps",
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFF1F2937),
//               ),
//             ),
//             Text(
//               "PROGRESS: ${(currentStep / totalSteps * 100).toInt()}%",
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 color: const Color(0xFF6B7280),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),

//         SizedBox(height: 8.h),

//         // Progress Bar
//         ClipRRect(
//           borderRadius: BorderRadius.circular(10),
//           child: LinearProgressIndicator(
//             value: currentStep / totalSteps,
//             backgroundColor: const Color(0xFFE5E7EB),
//             valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1B5E8C)),
//             minHeight: 8.h,
//           ),
//         ),
//       ],
//     );
//   }
// }
