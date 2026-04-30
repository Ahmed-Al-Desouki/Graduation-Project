import 'medical_record_entity.dart';
import 'prescription_entity.dart';

class AppointmentFullDetailsEntity {
  final String appointmentId;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final String status;
  final String patientNotes;
  final int doctorId;
  final String doctorName;
  final int patientId;
  final String patientName;
  final MedicalRecordEntity? medicalRecord;
  final List<PrescriptionEntity>? prescriptions;
  final String? cancelBy;
  final String? cancellationReason;
  final bool canViewMedicalHistory;

  AppointmentFullDetailsEntity({
    required this.appointmentId,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.patientNotes,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    this.medicalRecord,
    this.prescriptions,
    this.cancelBy,
    this.cancellationReason,
    required this.canViewMedicalHistory,
  });
}
