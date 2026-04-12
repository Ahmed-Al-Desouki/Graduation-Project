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
//     return AppointmentListItem(
//       showCancelButton: false, // الهيستوري دايماً مريض
//       appointment: appointment,
//       isDoctor: false, // الهيستوري دايماً مريض
//       onTap:
//           () => context.push(
//             AppRouter.kMedicalDetails,
//             extra: {
//               'appointmentId': appointment.appointmentId,
//               'patientId': appointment.patientId.toString(),
//               'patientName': appointment.patientName,
//               'doctorName':
//                   appointment.doctorName, // 🚨 السطر ده كان ناقص، ضيفه
//               'status': appointment.status,
//               'patientNote':
//                   appointment
//                       .patientNotes, // 🚨 السطر ده كان ناقص عشان الـ Reason يظهر
//               'isReadOnly': true,
//             },
//           ),
//       // مش هنحط زرار كانسل بره في الهيستوري عشان الزحمة، كفاية جوه
//     );
//   }
// }

class AppointmentCard extends StatelessWidget {
  final AppointmentFullDetailsEntity appointment;
  final bool isDoctorViewInHistory;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.isDoctorViewInHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppointmentListItem(
      appointment: appointment,
      // 💡 الزتونة: في الميديكال هيستوري، الكارت بيعرض "زيارات الدكاترة"
      // فبنخلي isDoctor: false عشان الـ ListItem يظهر doctorName
      isDoctor: isDoctorViewInHistory,
      showCancelButton: false,
      onTap:
          () => context.push(
            AppRouter.kMedicalDetails,
            extra: {
              'appointmentId': appointment.appointmentId,
              'patientId': appointment.patientId.toString(),
              'patientName': appointment.patientName,
              'doctorName': appointment.doctorName, // ✅ مبعوث صح
              'status': appointment.status,
              'patientNote':
                  appointment.patientNotes, // ✅ مبعوث صح عشان الـ Reason يظهر
              'isReadOnly': true,
            },
          ),
    );
  }
}
