// import 'package:flutter/widgets.dart';
// import 'package:graduation_project/core/utils/app_images.dart';
// import 'package:graduation_project/core/utils/app_styles.dart';
// import 'package:graduation_project/features/auth/presentation/views/widgets/trash/features_container.dart';

// class AvailableFeatures extends StatelessWidget {
//   const AvailableFeatures({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 25),
//           child: Text(
//             "What you'll get",
//             style: AppStyles.styleSemiBold18Dark.copyWith(fontSize: 25),
//           ),
//         ),
//         SizedBox(height: 20),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 25),
//           child: GridView.count(
//             crossAxisCount: 2,
//             childAspectRatio: 1.5,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisSpacing: 18.0,
//             mainAxisSpacing: 18.0,
//             shrinkWrap:
//                 true,
//             children: const <Widget>[
//               FeaturesContainer(
//                 icon: Assets.imagesShieldHeartSolidFull,
//                 title: 'Secure Platform',
//                 subtitle: 'HIPAA compliant\n\t\t\t\t\t\t\tsecurity',
//                 iconColor: Color(0xFF2563EB),
//                 backgroundColor: Color(0xFFDBEAFE),
//               ),
//               FeaturesContainer(
//                 icon: Assets.imagesClock,
//                 title: '24/7 Access',
//                 subtitle: 'Available anytime',
//                 iconColor: Color(0xFF16A34A),
//                 backgroundColor: Color(0xFFDCFCE7),
//               ),
//               FeaturesContainer(
//                 icon: Assets.imagesVideo,
//                 title: 'Telemedicine',
//                 subtitle: 'Video consultations',
//                 iconColor: Color(0xFF9333EA),
//                 backgroundColor: Color(0xFFF3E8FF),
//               ),
//               FeaturesContainer(
//                 icon: Assets.imagesMobile,
//                 title: 'Mobile First',
//                 subtitle: 'Optimized for mobile',
//                 iconColor: Color(0xFFEE712E),
//                 backgroundColor: Color(0xFFFFEDD5),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
