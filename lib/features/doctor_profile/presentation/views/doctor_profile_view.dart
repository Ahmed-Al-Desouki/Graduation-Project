import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_state.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/doctor_profile_drawer.dart';
import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/doctor_profile_view_body.dart';

class DoctorProfileView extends StatefulWidget {
  const DoctorProfileView({super.key});

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _infoKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _verificationKey = GlobalKey();
  final GlobalKey _achievementsKey = GlobalKey();
  final GlobalKey _hoursKey = GlobalKey();
  final GlobalKey _reviewsKey = GlobalKey();
  final GlobalKey _servicesKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    Navigator.pop(context);
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DoctorRealProfileCubit>()..getDoctorProfile(),
      child: BlocBuilder<DoctorRealProfileCubit, DoctorRealProfileState>(
        buildWhen:
            (previous, current) =>
                current is DoctorProfileLoading ||
                current is DoctorProfileSuccess ||
                current is DoctorProfileFailure,
        builder: (context, state) {
          final profileImageUrl =
              state is DoctorProfileSuccess
                  ? state.profile.profileImageUrl
                  : null;
          final doctorName =
              state is DoctorProfileSuccess
                  ? state.profile.fullName
                  : 'Loading...';

          return Scaffold(
            key: scaffoldKey,
            backgroundColor: const Color(0xfffaf0ff),
            endDrawer: DoctorProfileDrawer(
              onScrollToSection: _scrollToSection,
              doctorName: doctorName,
              profileImageUrl: profileImageUrl,
              infoKey: _infoKey,
              aboutKey: _aboutKey,
              verificationKey: _verificationKey,
              achievementsKey: _achievementsKey,
              hoursKey: _hoursKey,
              reviewsKey: _reviewsKey,
              servicesKey: _servicesKey,
            ),

            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                "Profile",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
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
            body: DoctorProfileViewBody(
              scrollController: _scrollController,
              infoKey: _infoKey,
              verificationKey: _verificationKey,
              aboutKey: _aboutKey,
              achievementsKey: _achievementsKey,
              hoursKey: _hoursKey,
              reviewsKey: _reviewsKey,
              servicesKey: _servicesKey,
            ),
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graduation_project/core/utils/helper/service_locator.dart';
// import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_cubit.dart';
// import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_state.dart';
// import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/doctor_profile_drawer.dart';
// import 'package:graduation_project/features/doctor_profile/presentation/views/widgets/doctor_profile_view_body.dart';

// class DoctorProfileView extends StatefulWidget {
//   const DoctorProfileView({super.key});

//   @override
//   State<DoctorProfileView> createState() => _DoctorProfileViewState();
// }

// class _DoctorProfileViewState extends State<DoctorProfileView> {
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//   final ScrollController _scrollController = ScrollController();
//   final GlobalKey _infoKey = GlobalKey();
//   final GlobalKey _aboutKey = GlobalKey();
//   final GlobalKey _verificationKey = GlobalKey();
//   final GlobalKey _achievementsKey = GlobalKey();
//   final GlobalKey _hoursKey = GlobalKey();
//   final GlobalKey _reviewsKey = GlobalKey();
//   final GlobalKey _servicesKey = GlobalKey();

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _scrollToSection(GlobalKey key) {
//     Navigator.pop(context);
//     if (key.currentContext != null) {
//       Scrollable.ensureVisible(
//         key.currentContext!,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => getIt<DoctorRealProfileCubit>()..getDoctorProfile(),
//       child: BlocBuilder<DoctorRealProfileCubit, DoctorRealProfileState>(
//         builder: (context, state) {
//           final profileImageUrl =
//               state is DoctorProfileSuccess
//                   ? state.profile.profileImageUrl
//                   : null;
//           final doctorName =
//               state is DoctorProfileSuccess
//                   ? state.profile.fullName
//                   : 'Loading...';

//           return Scaffold(
//             key: scaffoldKey,
//             backgroundColor: const Color(0xfffaf0ff),
//             endDrawer: DoctorProfileDrawer(
//               onScrollToSection: _scrollToSection,
//               doctorName: doctorName,
//               profileImageUrl: profileImageUrl,
//               infoKey: _infoKey,
//               aboutKey: _aboutKey,
//               verificationKey: _verificationKey,
//               achievementsKey: _achievementsKey,
//               hoursKey: _hoursKey,
//               reviewsKey: _reviewsKey,
//               servicesKey: _servicesKey,
//             ),

//             appBar: AppBar(
//               backgroundColor: Colors.white,
//               elevation: 0,
//               title: const Text(
//                 "Profile",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               centerTitle: true,
//               actions: [
//                 IconButton(
//                   icon: const Icon(
//                     Icons.menu_open_rounded,
//                     color: Color(0xFF111827),
//                     size: 28,
//                   ),
//                   onPressed: () => scaffoldKey.currentState?.openEndDrawer(),
//                 ),
//               ],
//             ),
//             body: DoctorProfileViewBody(
//               scrollController: _scrollController,
//               infoKey: _infoKey,
//               verificationKey: _verificationKey,
//               aboutKey: _aboutKey,
//               achievementsKey: _achievementsKey,
//               hoursKey: _hoursKey,
//               reviewsKey: _reviewsKey,
//               servicesKey: _servicesKey,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
