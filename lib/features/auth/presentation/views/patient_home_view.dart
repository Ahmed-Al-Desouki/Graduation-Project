import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/next_reminder_card.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/patient_home_header.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/patient_quick_action_card.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/upcoming_appointments.dart';

class PatientHomeView extends StatelessWidget {
  const PatientHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE8F7F2),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PatientHomeHeader(),
            SizedBox(height: 20.h),
            const UpcomingAppointments(),
            const NextReminderCard(),
            SizedBox(height: 30.h),
            Padding(
              padding: EdgeInsets.only(left: 30.w),
              child: Text(
                'Quick Actions',
                style: AppStyles.styleBold20Dark, 
              ),
            ),
            SizedBox(height: 10.h),
            PatientQuickActionCard(
              onTap: () {},
              title: 'Search for Doctors',
              subtitle: 'Schedule with your doctor',
              gradientColor: const Color(0xFF9333EA),
              imageAsset: Assets.imagesClipartDoctorPerson1,
            ),
            SizedBox(height: 20.h),
            PatientQuickActionCard(
              onTap: () {
                AppRouter.router.go(AppRouter.kReminder);
              },
              title: 'Reminders',
              subtitle: 'Update your Reminders',
              gradientColor: const Color.fromARGB(255, 8, 82, 243),
              imageAsset: Assets.imagesReminderSvgrepoCom,
              iconColor: const Color.fromARGB(255, 8, 82, 243),
            ),
            SizedBox(height: 20.h),
            PatientQuickActionCard(
              onTap: () {
                AppRouter.router.go(AppRouter.kMedicalHistory);
              },
              title: 'Medical History',
              subtitle: 'View your health history',
              gradientColor: const Color.fromARGB(255, 35, 184, 42),
              imageAsset: Assets.imagesMedicalRecordsSvgrepoCom,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}