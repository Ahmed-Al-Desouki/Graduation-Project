// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart'; 
// import 'package:graduation_project/core/utils/app_images.dart';
// import 'package:graduation_project/core/utils/app_router.dart';
// import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
// import 'package:graduation_project/core/widgets/tutorial_tooltip_widget.dart';
// import 'package:graduation_project/features/auth/presentation/views/widgets/next_reminder_card.dart';
// import 'package:graduation_project/features/auth/presentation/views/widgets/patient_home_header.dart';
// import 'package:graduation_project/features/auth/presentation/views/widgets/patient_quick_action_card.dart';
// import 'package:graduation_project/features/auth/presentation/views/widgets/upcoming_appointments.dart';
// import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:showcaseview/showcaseview.dart';

// class PatientHomeView extends StatefulWidget {
//   const PatientHomeView({super.key});
//   @override
//   State<PatientHomeView> createState() => _PatientHomeViewState();
// }

// class _PatientHomeViewState extends State<PatientHomeView> {
//   final GlobalKey _notificationKey = GlobalKey();
//   final GlobalKey _searchDoctorKey = GlobalKey();
//   final GlobalKey _remindersKey = GlobalKey();
//   final GlobalKey _historyKey = GlobalKey();

//   final int totalSteps = 4;

//   @override
//   void initState() {
//     super.initState();
//     AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
//       if (!isAllowed) {
//         AwesomeNotifications().requestPermissionToSendNotifications();
//       }
//     });
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final patientId =
//           await SecureStorageHelper.getUserId(); // إضافة await هنا
//       if (patientId != null && mounted) {
//         context.read<ReminderCubit>().getUpcomingReminders(
//           patientId: patientId,
//         );
//         context.read<ReminderCubit>().syncOfflineActions();
//       }
//     });
//   }

//   void _checkAndStartShowcase(BuildContext localContext) async {
//     String? userId = await SecureStorageHelper.getUserId();
//     if (userId != null) {
//       var box =
//           Hive.isBoxOpen('settings')
//               ? Hive.box('settings')
//               : await Hive.openBox('settings');
//       String key = 'home_tutorial_shown_$userId';
//       bool isShown = box.get(key, defaultValue: false);

//       if (!isShown) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           ShowCaseWidget.of(localContext).startShowCase([
//             _notificationKey,
//             _searchDoctorKey,
//             _remindersKey,
//             _historyKey,
//           ]);
//         });
//         await box.put(key, true);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ShowCaseWidget(
//       autoPlay: false,
//       enableAutoScroll: true,
//       blurValue: 1,
//       builder: (context) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _checkAndStartShowcase(context);
//         });

//         return Scaffold(
//           backgroundColor: const Color(0xffE8F7F2),
//           body: SingleChildScrollView(
//             padding: EdgeInsets.only(bottom: 20.h),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // --- 1. Header & Notifications ---
//                 PatientHomeHeader(
//                   notificationWidget: Showcase.withWidget(
//                     key: _notificationKey,
//                     height: null,
//                     width: 270.w,
//                     tooltipPosition: TooltipPosition.bottom,
//                     targetPadding: EdgeInsets.all(5.r),
//                     container: TutorialTooltipWidget(
//                       title: 'Notifications',
//                       description:
//                           'Check your reminders and appointment updates here.',
//                       currentStep: 1,
//                       totalSteps: totalSteps,
//                       onNext: () => ShowCaseWidget.of(context).next(),
//                       onSkip: () => ShowCaseWidget.of(context).dismiss(),
//                     ),
//                     child: IconButton(
//                       icon: const Icon(Icons.notifications),
//                       color: Colors.white,
//                       iconSize: 28.sp,
//                       onPressed: () {},
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: 20.h),
//                 const UpcomingAppointments(),
//                 const NextReminderCard(),
//                 SizedBox(height: 30.h),

//                 // --- 2. Search Doctor ---
//                 Showcase.withWidget(
//                   key: _searchDoctorKey,
//                   height: null, 
//                   width: 270.w, 
//                   targetPadding: EdgeInsets.symmetric(
//                     vertical: 5.h,
//                     horizontal: 5.w,
//                   ),
//                   tooltipPosition: TooltipPosition.top, 
//                   container: TutorialTooltipWidget(
//                     currentStep: 2,
//                     totalSteps: totalSteps,
//                     title: 'Find a Doctor',
//                     description:
//                         'Book appointments with top specialists easily from here.',
//                     onNext: () => ShowCaseWidget.of(context).next(),
//                     onSkip: () => ShowCaseWidget.of(context).dismiss(),
//                   ),
//                   child: PatientQuickActionCard(
//                     onTap: () {},
//                     title: 'Search for Doctors',
//                     subtitle: 'Schedule with your doctor',
//                     gradientColor: const Color(0xFF9333EA),
//                     imageAsset: Assets.imagesClipartDoctorPerson1,
//                     isSvg: false,
//                   ),
//                 ),

//                 SizedBox(height: 20.h),

//                 Showcase.withWidget(
//                   key: _remindersKey,
//                   height: null,
//                   width: 270.w, 
//                   targetPadding: EdgeInsets.symmetric(
//                     vertical: 5.h,
//                     horizontal: 5.w,
//                   ),
//                   tooltipPosition: TooltipPosition.top,
//                   container: TutorialTooltipWidget(
//                     currentStep: 3,
//                     totalSteps: totalSteps,
//                     title: 'Medicine Reminders',
//                     description:
//                         'Track your medications and never miss a dose.',
//                     onNext: () => ShowCaseWidget.of(context).next(),
//                     onSkip: () => ShowCaseWidget.of(context).dismiss(),
//                   ),
//                   child: PatientQuickActionCard(
//                     onTap: () {
//                       AppRouter.router.go(AppRouter.kReminder);
//                     },
//                     title: 'Reminders',
//                     subtitle: 'Update your Reminders',
//                     gradientColor: const Color.fromARGB(255, 8, 82, 243),
//                     imageAsset: Assets.imagesReminderSvgrepoCom,
//                     iconColor: const Color.fromARGB(255, 8, 82, 243),
//                   ),
//                 ),

//                 SizedBox(height: 20.h),

//                 Showcase.withWidget(
//                   key: _historyKey,
//                   height: null, 
//                   width: 270.w, 
//                   targetPadding: EdgeInsets.symmetric(
//                     vertical: 5.h,
//                     horizontal: 5.w,
//                   ),
//                   tooltipPosition: TooltipPosition.top,
//                   container: TutorialTooltipWidget(
//                     currentStep: 4,
//                     totalSteps: totalSteps,
//                     title: 'Medical History',
//                     description:
//                         'Access all your past prescriptions and reports.',
//                     onNext: () {
//                       ShowCaseWidget.of(context).dismiss();
//                     },
//                     onSkip: () => ShowCaseWidget.of(context).dismiss(),
//                   ),
//                   child: PatientQuickActionCard(
//                     onTap: () {
//                       AppRouter.router.go(AppRouter.kMedicalHistory);
//                     },
//                     title: 'Medical History',
//                     subtitle: 'View your health history',
//                     gradientColor: const Color.fromARGB(255, 35, 184, 42),
//                     imageAsset: Assets.imagesMedicalRecordsSvgrepoCom,
//                   ),
//                 ),

//                 // SizedBox(height: 20.h),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
