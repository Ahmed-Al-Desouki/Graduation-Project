import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/doctor_appointments_card.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/doctor_home_header.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/doctor_revenue_card.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/doctor_stat_card.dart';
import 'package:graduation_project/features/home/presentation/views/widgets/quick_action_card.dart';

class DoctorHomeView extends StatefulWidget {
  const DoctorHomeView({super.key});

  @override
  State<DoctorHomeView> createState() => _DoctorHomeViewState();
}

class _DoctorHomeViewState extends State<DoctorHomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffaf0ff),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DoctorHomeHeader(),
            SizedBox(height: 20.h),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Appointments",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to past appointments screen
                      AppRouter.router.push(AppRouter.kAppointmentsCenter);
                    },
                    child: Text(
                      "View All",
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            ListView(
              padding: EdgeInsets.symmetric(horizontal: 25),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                DoctorAppointmentsCard(
                  patientName: "Michael Chen",
                  time: "09:30 AM",
                  type: "Consultation",
                  status: "Upcoming",
                  statusColor: Color(0xFF1B4E8C),
                  image: Assets.imagesHeartRate,
                ),
                DoctorAppointmentsCard(
                  patientName: "Lisa Rodriguez",
                  time: "11:00 AM",
                  type: "General Checkup",
                  status: "Confirmed",
                  statusColor: Color(0xFF4CAF50),
                  image: Assets.imagesHeartRate,
                ),
                DoctorAppointmentsCard(
                  patientName: "John Steve",
                  time: "01:15 PM",
                  type: "Surgery Follow-up",
                  status: "Waiting",
                  statusColor: Colors.red,
                  image: Assets.imagesHeartRate,
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "Quick Stats",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DoctorStatCard(
                          title: "Total \nPatients",
                          value: "1,505",
                          icon: Icons.groups_rounded,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: DoctorStatCard(
                          title: "Avg \nRating",
                          value: "4.8",
                          icon: Icons.star_rounded,
                          color: Colors.yellow.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  DoctorRevenueCard(
                    title: "Monthly Revenue",
                    amount: "\$12,450",
                    percentage: "15%",
                    isIncrease: true,
                    icon: Icons.attach_money_rounded,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            QuickActionCard(
              title: 'Appointment Center',
              subtitle: 'Check your Appointments',
              gradientColor: const Color(0xFF9333EA),
              imageAsset: Assets.imagesSchedule,
              isSvg: false,
              onTap: () {
                // Navigate to past appointments screen
                AppRouter.router.push(AppRouter.kDoctorSchedule);
              },
            ),
            SizedBox(height: 20.h),
            QuickActionCard(
              title: 'Reminders',
              subtitle: 'Update your Reminders',
              iconColor: const Color(0xFF0852F3),
              gradientColor: const Color(0xFF0852F3),
              imageAsset: Assets.imagesReminderSvgrepoCom,
            ),
          ],
        ),
      ),
    );
  }
}
