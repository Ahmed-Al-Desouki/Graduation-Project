import 'package:flutter/material.dart';
import 'package:graduation_project/features/booking/domain/entities/appointment_full_details_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/AppointmentListItem.dart';

// class AppointmentCard extends StatelessWidget {
//   final AppointmentFullDetailsEntity appointment;

//   const AppointmentCard({super.key, required this.appointment});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap:
//           () => context.push(
//             AppRouter.kMedicalDetails,
//             extra: {
//               'appointmentId': appointment.appointmentId,
//               'patientName': appointment.patientName,
//               'status': appointment.status,
//               'patientId': appointment.patientId.toString(),
//               'isReadOnly': true,
//             },
//           ),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.grey.shade100),
//         ),
//         child: Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
//               child: const Icon(Icons.person, color: Color(0xFF2563EB)),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     appointment.doctorName,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 4),
//                   // ✅ عرض الحالة بشكل ملون تحت الاسم
//                   _buildStatusText(appointment.status),
//                 ],
//               ),
//             ),
//             // ✅ إضافة السهم اللي طلبته
//             const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusText(String status) {
//     Color color = status.toLowerCase() == 'pending' ? Colors.blue : Colors.red;
//     if (status.toLowerCase() == 'completed') color = Colors.green;
//     return Text(
//       status,
//       style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
//     );
//   }
// }

class AppointmentCard extends StatelessWidget {
  final AppointmentFullDetailsEntity appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return AppointmentListItem(
      showCancelButton: false, // الهيستوري دايماً مريض
      appointment: appointment,
      isDoctor: false, // الهيستوري دايماً مريض
      onTap:
          () => context.push(
            AppRouter.kMedicalDetails,
            // extra: {
            //   'appointmentId': appointment.appointmentId,
            //   'patientName': appointment.patientName,
            //   'status': appointment.status,
            //   'patientId': appointment.patientId.toString(),
            //   'isReadOnly': true,
            // },
            extra: {
              'appointmentId': appointment.appointmentId,
              'patientId': appointment.patientId.toString(),
              'patientName': appointment.patientName,
              'doctorName':
                  appointment.doctorName, // 🚨 السطر ده كان ناقص، ضيفه
              'status': appointment.status,
              'patientNote':
                  appointment
                      .patientNotes, // 🚨 السطر ده كان ناقص عشان الـ Reason يظهر
              'isReadOnly': true,
            },
          ),
      // مش هنحط زرار كانسل بره في الهيستوري عشان الزحمة، كفاية جوه
    );
  }
}
