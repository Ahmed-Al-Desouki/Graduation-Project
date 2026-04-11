// import 'package:flutter/material.dart';
// import 'package:graduation_project/features/medical_history/domain/models/appointment_model.dart';
// import 'appointment_card.dart';

// class PastAppointmentsSection extends StatelessWidget {
//   const PastAppointmentsSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final List<AppointmentModel> appointments = [
//       AppointmentModel(
//         doctorName: "Dr. Michael Chen",
//         specialty: "Endocrinologist",
//         date: "Oct 15, 2023",
//         title: "Diabetes Follow-up",
//         description: "Routine check-up and medication adjustment",
//         duration: "45 minutes",
//         location: "Room 302",
//         imagePath: "https://i.pravatar.cc/150?img=11", // صورة تجريبية
//         cardColor: const Color(0xFF3B82F6), // أزرق
//       ),
//       // AppointmentModel(
//       //   doctorName: "Dr. Sarah Williams",
//       //   specialty: "Cardiologist",
//       //   date: "Sep 22, 2023",
//       //   title: "Hypertension Management",
//       //   description: "Blood pressure monitoring and medication review",
//       //   duration: "30 minutes",
//       //   location: "Cardiology Wing",
//       //   imagePath: "https://i.pravatar.cc/150?img=5",
//       //   cardColor: const Color(0xFFEF4444), // أحمر
//       // ),
//       // AppointmentModel(
//       //   doctorName: "Dr. James Rodriguez",
//       //   specialty: "Pulmonologist",
//       //   date: "Aug 10, 2023",
//       //   title: "Asthma Review",
//       //   description: "Lung function test and inhaler technique review",
//       //   duration: "60 minutes",
//       //   location: "Pulmonary Lab",
//       //   imagePath: "https://i.pravatar.cc/150?img=3",
//       //   cardColor: const Color(0xFF14B8A6), // تيل (Teal)
//       // ),
//     ];

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF3E8FF),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(
//                       Icons.calendar_month_rounded,
//                       color: Color(0xFF9333EA),
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     "Past Appointments",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                 ],
//               ),
//               TextButton(
//                 onPressed: () {},
//                 child: const Text(
//                   "View All",
//                   style: TextStyle(
//                     color: Color(0xFF2563EB),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),
//           ...appointments.map(
//             (appointment) => AppointmentCard(appointment: appointment),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/booking/domain/entities/appointment_full_details_entity.dart';
import 'package:graduation_project/features/booking/presentation/manager/appointments_center_cubit/appointment_center_cubit.dart';
import 'appointment_card.dart';

class PastAppointmentsSection extends StatelessWidget {
  const PastAppointmentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF9333EA),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Recent Visits", // غيرنا الاسم ليكون أدق
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // 🚀 الانتقال للأجندة الكاملة (Appointments Center)
                  context.push(AppRouter.kAppointmentsCenter);
                },
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 🔄 عرض المواعيد الحقيقية
          BlocBuilder<AppointmentsCenterCubit, AppointmentsCenterState>(
            builder: (context, state) {
              if (state is AppointmentsCenterLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AppointmentsCenterSuccess) {
                // عرض آخر ميعادين فقط في الهيستوري كـ "Recent"
                final recentAppointments = state.appointments.take(2).toList();

                if (recentAppointments.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No medical visits recorded yet.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Column(
                  children:
                      recentAppointments.map((appointment) {
                        return AppointmentCard(
                          appointment:
                              appointment, // سنقوم بتعديل الكارت ليستقبل الـ Entity
                        );
                      }).toList(),
                );
              }

              if (state is AppointmentsCenterFailure) {
                return Text("Error: ${state.errMessage}");
              }

              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
