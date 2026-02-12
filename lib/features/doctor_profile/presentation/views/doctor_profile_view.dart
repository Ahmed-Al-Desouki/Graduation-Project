import 'package:flutter/material.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/about_me_section.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/achievements_section.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/doctor_profile_drawer.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/info_section.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/doctor_profile_header.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/services_pricing_section.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/working_hours_section.dart';

class DoctorProfileView extends StatefulWidget {
  const DoctorProfileView({super.key});

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey infoKey = GlobalKey();
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey achievementsKey = GlobalKey();
  final GlobalKey hoursKey = GlobalKey();
  final GlobalKey servicesKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xfffaf0ff),

      endDrawer: DoctorProfileDrawer(
        onScrollToSection: (key) {
          Navigator.pop(context);
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        infoKey: infoKey,
        aboutKey: aboutKey,
        achievementsKey: achievementsKey,
        hoursKey: hoursKey,
        servicesKey: servicesKey,
      ),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu_open_rounded,
              color: Color(0xFF111827),
              size: 28,
            ),
            onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            DoctorProfileHeader(),
            const SizedBox(height: 15),

            Container(key: infoKey, child: InfoSection()),
            const SizedBox(height: 15),

            Container(key: aboutKey, child: AboutMeSection()),
            const SizedBox(height: 15),

            Container(key: achievementsKey, child: AchievementsSection()),
            const SizedBox(height: 15),

            Container(key: hoursKey, child: WorkingHoursSection()),
            const SizedBox(height: 15),

            Container(key: servicesKey, child: ServicesPricingSection()),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/about_me_section.dart';
// import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/achievements_section.dart';
// import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/info_section.dart';
// import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/doctor_profile_header.dart';
// import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/services_pricing_section.dart';
// import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/working_hours_section.dart';

// class DoctorProfileView extends StatelessWidget {
//   const DoctorProfileView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfffaf0ff),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () {},
//         ),
//         title: Text(
//           "Profile",
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 20.sp,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.favorite, color: Colors.grey),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: const Icon(Icons.share, color: Colors.grey),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             DoctorProfileHeader(),
//             SizedBox(height: 15),
//             InfoSection(),
//             SizedBox(height: 15),
//             AboutMeSection(),
//             SizedBox(height: 15),
//             AchievementsSection(),
//             SizedBox(height: 15),
//             WorkingHoursSection(),
//             SizedBox(height: 15),
//             ServicesPricingSection(),
//             SizedBox(height: 15),
//           ],
//         ),
//       ),
//     );
//   }
// }
