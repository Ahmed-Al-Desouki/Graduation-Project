import 'package:flutter/material.dart';
import 'package:graduation_project/features/booking/domain/entities/appointment_full_details_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/appointment_list_item.dart';

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
      isDoctor: isDoctorViewInHistory,
      showCancelButton: false,
      onTap:
          () => context.push(
            AppRouter.kMedicalDetails,
            extra: {
              'appointmentId': appointment.appointmentId,
              'patientId': appointment.patientId.toString(),
              'patientName': appointment.patientName,
              'doctorName': appointment.doctorName,
              'status': appointment.status,
              'patientNote': appointment.patientNotes,
              'isReadOnly': true,
            },
          ),
    );
  }
}
