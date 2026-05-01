import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/booking/presentation/manager/appointments_center_cubit/appointment_center_cubit.dart';
import 'package:graduation_project/features/home/presentation/views/widgets/patient_appointment_Item.dart';

// class UpcomingAppointments extends StatelessWidget {
//   const UpcomingAppointments({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AppointmentsCenterCubit, AppointmentsCenterState>(
//       builder: (context, state) {
//         if (state is AppointmentsCenterLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (state is AppointmentsCenterSuccess) {
//           // 1. فلترة مواعيد المريض: اليوم + Pending
//           final now = DateTime.now();
//           final todaysPending =
//               state.appointments.where((app) {
//                 final isToday =
//                     app.appointmentDate.year == now.year &&
//                     app.appointmentDate.month == now.month &&
//                     app.appointmentDate.day == now.day;
//                 return isToday && app.status.toLowerCase() == 'pending';
//               }).toList();

//           // 2. لو مفيش مواعيد النهاردة مش هنعرض السكشن ده خالص أو نعرض Empty State
//           if (todaysPending.isEmpty) return const SizedBox();

//           // 3. عرض أول 3 مواعيد
//           final displayList = todaysPending.take(3).toList();

//           return Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 20,
//             ), // قللنا الـ Padding شوية للتحسين
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               margin: const EdgeInsets.only(bottom: 20),
//               decoration: _cardDecoration(),
//               child: Column(
//                 children: [
//                   _buildSectionHeader(context),
//                   ...displayList.map(
//                     (item) => PatientAppointmentItem(
//                       appointment: item,
//                       onTap: () => _navigateToDetails(context, item),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//         return const SizedBox();
//       },
//     );
//   }

//   // --- Helpers ---

//   Widget _buildNoAppointments() {
//     return const Padding(
//       padding: EdgeInsets.symmetric(vertical: 20),
//       child: Column(
//         children: [
//           Icon(Icons.event_available, color: Colors.grey, size: 40),
//           SizedBox(height: 8),
//           Text(
//             "No appointments for today",
//             style: TextStyle(color: Colors.grey, fontSize: 13),
//           ),
//         ],
//       ),
//     );
//   }

//   BoxDecoration _cardDecoration() => BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(12),
//     boxShadow: [
//       BoxShadow(
//         color: Colors.grey.withOpacity(0.15),
//         blurRadius: 8,
//         offset: const Offset(0, 4),
//       ),
//     ],
//   );

//   // داخل ملف patient_home_view.dart أو ملف الـ widgets الخاص به

//   Widget _buildSectionHeader(BuildContext context) => Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//     child: Row(
//       mainAxisAlignment:
//           MainAxisAlignment.spaceBetween, // عشان يوزع العنوان والزرار
//       children: [
//         const Text(
//           "Upcoming Appointments",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         // 💡 إضافة زرار View All
//         TextButton(
//           onPressed: () {
//             // الانتقال لصفحة الأجندة (التي تدعم دور المريض تلقائياً)
//             AppRouter.router.push(AppRouter.kAppointmentsCenter);
//           },
//           child: const Text(
//             "View All",
//             style: TextStyle(
//               color: Color(0xFF0852F3),
//               fontWeight: FontWeight.bold,
//               fontSize: 13,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );

//   void _navigateToDetails(BuildContext context, dynamic item) {
//     context.push(
//       AppRouter.kMedicalDetails,
//       extra: {
//         'appointmentId': item.appointmentId,
//         'patientId': item.patientId.toString(),
//         'patientName': item.patientName,
//         'doctorName': item.doctorName,
//         'status': item.status,
//         'patientNote': item.patientNotes,
//         'isReadOnly': true, // المريض دايماً ReadOnly
//       },
//     );
//   }
// }

class UpcomingAppointments extends StatelessWidget {
  const UpcomingAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentsCenterCubit, AppointmentsCenterState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                _buildSectionHeader(context),
                if (state is AppointmentsCenterLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is AppointmentsCenterSuccess)
                  _buildAppointmentsContent(context, state.appointments)
                else
                  _buildNoAppointments(), // الحالة الافتراضية عند الفشل أو عدم وجود بيانات
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsContent(
    BuildContext context,
    List<dynamic> appointments,
  ) {
    final now = DateTime.now();
    final todaysPending =
        appointments.where((app) {
          final isToday =
              app.appointmentDate.year == now.year &&
              app.appointmentDate.month == now.month &&
              app.appointmentDate.day == now.day;
          return isToday && app.status.toLowerCase() == 'pending';
        }).toList();

    if (todaysPending.isEmpty) {
      return _buildNoAppointments();
    }

    final displayList = todaysPending.take(3).toList();

    return Column(
      children:
          displayList
              .map(
                (item) => PatientAppointmentItem(
                  appointment: item,
                  onTap: () => _navigateToDetails(context, item),
                ),
              )
              .toList(),
    );
  }

  // --- Helpers ---

  Widget _buildNoAppointments() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available, color: Colors.grey, size: 40),
          SizedBox(height: 8),
          Text(
            "No appointments for today",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.15),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  Widget _buildSectionHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Upcoming Appointments",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            AppRouter.router.push(AppRouter.kAppointmentsCenter);
          },
          child: const Text(
            "View All",
            style: TextStyle(
              color: Color(0xFF0852F3),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );

  void _navigateToDetails(BuildContext context, dynamic item) {
    context.push(
      AppRouter.kMedicalDetails,
      extra: {
        'appointmentId': item.appointmentId,
        'patientId': item.patientId.toString(),
        'patientName': item.patientName,
        'doctorName': item.doctorName,
        'status': item.status,
        'patientNote': item.patientNotes,
        'isReadOnly': true,
      },
    );
  }
}
