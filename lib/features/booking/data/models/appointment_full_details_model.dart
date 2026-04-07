// import '../../domain/entities/appointment_full_details_entity.dart';

// class AppointmentFullDetailsModel extends AppointmentFullDetailsEntity {
//   AppointmentFullDetailsModel({
//     required super.appointmentId,
//     required super.appointmentDate,
//     required super.startTime,
//     required super.endTime,
//     required super.status,
//     super.patientNotes,
//     required super.doctorName,
//     required super.patientName,
//     required super.patientId,
//     super.prescriptions,
//   });

//   // ✅ تحويل الـ JSON القادم من السيرفر إلى Model
//   factory AppointmentFullDetailsModel.fromJson(Map<String, dynamic> json) {
//     return AppointmentFullDetailsModel(
//       appointmentId: json['appointmentId'],
//       // تحويل النص القادم من الباك (ISO 8601) إلى DateTime
//       appointmentDate: DateTime.parse(json['appointmentDate']),
//       startTime: json['startTime'],
//       endTime: json['endTime'],
//       status: json['status'], // القيم: Pending, Confirmed, etc.
//       patientNotes: json['patientNotes'],
//       doctorName: json['doctorName'] ?? '',
//       patientName: json['patientName'] ?? '',
//       patientId: json['patientId'] ?? 0,
//       prescriptions:
//           json['prescriptions'] != null
//               ? List<dynamic>.from(json['prescriptions'])
//               : [],
//     );
//   }

//   // ✅ (اختياري) لو احتجت تبعت بيانات الموعد في Body لـ API تانية
//   Map<String, dynamic> toJson() {
//     return {
//       'appointmentId': appointmentId,
//       'appointmentDate': appointmentDate.toIso8601String(),
//       'startTime': startTime,
//       'endTime': endTime,
//       'status': status,
//       'patientNotes': patientNotes,
//       'doctorName': doctorName,
//       'patientName': patientName,
//       'patientId': patientId,
//     };
//   }
// }

// features/booking/data/models/appointment_full_details_model.dart

import '../../domain/entities/appointment_full_details_entity.dart';
import 'medical_record_model.dart'; // الموديل القديم بتاعك
import 'prescription_model.dart'; // الموديل القديم بتاعك

class AppointmentFullDetailsModel extends AppointmentFullDetailsEntity {
  AppointmentFullDetailsModel({
    required super.appointmentId,
    required super.appointmentDate,
    required super.startTime,
    required super.endTime,
    required super.status,
    required super.patientNotes,
    required super.doctorId,
    required super.doctorName,
    required super.patientId,
    required super.patientName,
    super.medicalRecord,
    super.prescriptions,
  });

  factory AppointmentFullDetailsModel.fromJson(Map<String, dynamic> json) {
    return AppointmentFullDetailsModel(
      appointmentId: json['appointmentId'],
      appointmentDate: DateTime.parse(json['appointmentDate']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      status: json['status'],
      patientNotes: json['patientNotes'] ?? '',
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      patientId: json['patientId'],
      patientName: json['patientName'],
      // ✅ تحويل السجل الطبي لو موجود
      medicalRecord:
          json['medicalRecord'] != null
              ? MedicalRecordModel.fromJson(json['medicalRecord'])
              : null,
      // ✅ تحويل لستة الروشتات لو موجودة
      prescriptions:
          json['prescriptions'] != null
              ? (json['prescriptions'] as List)
                  .map((i) => PrescriptionModel.fromJson(i))
                  .toList()
              : [],
    );
  }
}
