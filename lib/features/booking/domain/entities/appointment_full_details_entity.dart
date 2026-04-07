// class AppointmentFullDetailsEntity {
//   final String appointmentId;
//   final DateTime appointmentDate;
//   final String startTime;
//   final String endTime;
//   final String status; // Pending, Confirmed, InProgress, etc.
//   final String? patientNotes;
//   final String doctorName;
//   final String patientName;
//   final List<dynamic>? prescriptions;
//   final int patientId; // ✅ أضفنا هذا السطر

//   AppointmentFullDetailsEntity({
//     required this.appointmentId,
//     required this.appointmentDate,
//     required this.startTime,
//     required this.endTime,
//     required this.status,
//     this.patientNotes,
//     required this.doctorName,
//     required this.patientName,
//     required this.patientId, // ✅ أضفنا هذا السطر
//     this.prescriptions,
//   });
// }

// features/booking/domain/entities/appointment_full_details_entity.dart

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
  final int patientId; // 🎯 الكنز اللي كنا بندور عليه
  final String patientName;
  final MedicalRecordEntity?
  medicalRecord; // ممكن يرجع null لو لسه السيشن مبدأتش
  final List<PrescriptionEntity>? prescriptions; // لستة الروشتات

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
  });
}
