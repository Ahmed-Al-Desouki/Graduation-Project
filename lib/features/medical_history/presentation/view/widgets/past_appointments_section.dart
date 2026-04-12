import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/booking/domain/entities/appointment_full_details_entity.dart';
import 'package:graduation_project/features/booking/presentation/manager/appointments_center_cubit/appointment_center_cubit.dart';
import 'appointment_card.dart';

// class PastAppointmentsSection extends StatelessWidget {
//   final List<AppointmentFullDetailsEntity> appointments;
//   const PastAppointmentsSection({super.key, required this.appointments});

//   @override
//   Widget build(BuildContext context) {
//     // if (appointments != null) {
//     //   context.read<AppointmentsCenterCubit>().loadPreFetchedAppointments(
//     //     appointments!,
//     //   );
//     // }
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<AppointmentsCenterCubit>().loadPreFetchedAppointments(
//         appointments,
//       );
//     });
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
//           // Header Section
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
//                     "Recent Visits", // غيرنا الاسم ليكون أدق
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                 ],
//               ),
//               TextButton(
//                 onPressed: () {
//                   // 🚀 الانتقال للأجندة الكاملة (Appointments Center)
//                   // context.push(AppRouter.kAppointmentsCenter);
//                   context.push(
//                     AppRouter.kAppointmentsCenter,
//                     extra: {'initialAppointments': appointments},
//                   );
//                 },
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

//           // 🔄 عرض المواعيد الحقيقية
//           BlocBuilder<AppointmentsCenterCubit, AppointmentsCenterState>(
//             builder: (context, state) {
//               if (state is AppointmentsCenterLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (state is AppointmentsCenterSuccess) {
//                 // عرض آخر ميعادين فقط في الهيستوري كـ "Recent"
//                 final recentAppointments = state.appointments.take(2).toList();

//                 if (recentAppointments.isEmpty) {
//                   return const Center(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(vertical: 20),
//                       child: Text(
//                         "No medical visits recorded yet.",
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ),
//                   );
//                 }

//                 return Column(
//                   children:
//                       recentAppointments.map((appointment) {
//                         return AppointmentCard(
//                           appointment:
//                               appointment, // سنقوم بتعديل الكارت ليستقبل الـ Entity
//                         );
//                       }).toList(),
//                 );
//               }

//               if (state is AppointmentsCenterFailure) {
//                 return Text("Error: ${state.errMessage}");
//               }

//               return const SizedBox();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// ... الأنبورتات موجودة ...

class PastAppointmentsSection extends StatelessWidget {
  final List<AppointmentFullDetailsEntity> appointments;
  // 👈 ضفنا الـ isDoctorView عشان نتحكم في شكل الكارت لو محتاجين
  final bool isDoctorView;

  const PastAppointmentsSection({
    super.key,
    required this.appointments,
    required this.isDoctorView,
  });

  @override
  Widget build(BuildContext context) {
    // 🚀 حقن الداتا في الكيوبت فوراً أول ما السكشن يتبني
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        if (isDoctorView) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AppointmentsCenterCubit>().loadPreFetchedAppointments(
              appointments,
            );
          });
        }
      }
    });

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderTitle(),
              TextButton(
                onPressed: () {
                  // 🚀 نبعت المواعيد لصفحة الأجندة عشان ما تناديش السيرفر وتجيب 403
                  context.push(
                    AppRouter.kAppointmentsCenter,
                    extra:
                        isDoctorView
                            ? {'initialAppointments': appointments}
                            : null,
                  );
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

          BlocBuilder<AppointmentsCenterCubit, AppointmentsCenterState>(
            builder: (context, state) {
              if (state is AppointmentsCenterSuccess) {
                // عرض أحدث ميعادين فقط في الواجهة الرئيسية للهيستوري
                final recent = state.appointments.take(2).toList();

                if (recent.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No medical visits recorded.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Column(
                  children:
                      recent.map((appointment) {
                        return AppointmentCard(
                          appointment: appointment,
                          // 🩺 في الهيستوري، إحنا دايماً بنعرض "مين الدكتور اللي عالج"
                          // فبنخلي isDoctorView: false دايماً للكارت عشان يظهر اسم الدكتور
                          isDoctorViewInHistory: false,
                        );
                      }).toList(),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return Row(
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
          "Recent Visits",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
