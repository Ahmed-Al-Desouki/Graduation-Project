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

// import '../../domain/entities/appointment_full_details_entity.dart';
// import 'medical_record_model.dart'; // الموديل القديم بتاعك
// import 'prescription_model.dart'; // الموديل القديم بتاعك

// class AppointmentFullDetailsModel extends AppointmentFullDetailsEntity {
//   AppointmentFullDetailsModel({
//     required super.appointmentId,
//     required super.appointmentDate,
//     required super.startTime,
//     required super.endTime,
//     required super.status,
//     required super.patientNotes,
//     required super.doctorId,
//     required super.doctorName,
//     required super.patientId,
//     required super.patientName,
//     super.medicalRecord,
//     super.prescriptions,
//   });

//   factory AppointmentFullDetailsModel.fromJson(Map<String, dynamic> json) {
//     return AppointmentFullDetailsModel(
//       appointmentId: json['appointmentId'],
//       appointmentDate: DateTime.parse(json['appointmentDate']),
//       startTime: json['startTime'],
//       endTime: json['endTime'],
//       status: json['status'],
//       patientNotes: json['patientNotes'] ?? '',
//       doctorId: json['doctorId'],
//       doctorName: json['doctorName'],
//       patientId: json['patientId'],
//       patientName: json['patientName'],
//       // ✅ تحويل السجل الطبي لو موجود
//       medicalRecord:
//           json['medicalRecord'] != null
//               ? MedicalRecordModel.fromJson(json['medicalRecord'])
//               : null,
//       // ✅ تحويل لستة الروشتات لو موجودة
//       prescriptions:
//           json['prescriptions'] != null
//               ? (json['prescriptions'] as List)
//                   .map((i) => PrescriptionModel.fromJson(i))
//                   .toList()
//               : [],
//     );
//   }
// }

import '../../domain/entities/appointment_full_details_entity.dart';
import 'medical_record_model.dart';
import 'prescription_model.dart';

// ✅ الـ Enum اللي هيريحنا في الـ UI
enum AppointmentStatus {
  Pending,
  Confirmed,
  InProgress,
  Completed,
  Cancelled,
  NoShow,
}

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
    super.cancelBy,
    super.cancellationReason,
    required super.canViewMedicalHistory,
    // required super.canViewPrescriptions,
    // required super.canViewLabResults,
    // required super.revokeAll,
  });

  // ✅ Getter سحري: يخليك تنادي .statusEnum من أي مكان في الـ UI
  AppointmentStatus get statusEnum {
    return AppointmentStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => AppointmentStatus.Pending,
    );
  }

  factory AppointmentFullDetailsModel.fromJson(Map<String, dynamic> json) {
    return AppointmentFullDetailsModel(
      appointmentId: json['appointmentId'],
      appointmentDate: DateTime.parse(json['appointmentDate']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      status: json['status'], // بياخدها String عادي من السيرفر
      patientNotes: json['patientNotes'] ?? '',
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      patientId: json['patientId'],
      patientName: json['patientName'],
      medicalRecord:
          json['medicalRecord'] != null
              ? MedicalRecordModel.fromJson(json['medicalRecord'])
              : null,
      prescriptions:
          json['prescriptions'] != null
              ? (json['prescriptions'] as List)
                  .map((i) => PrescriptionModel.fromJson(i))
                  .toList()
              : [],
      cancelBy: json['cancelledBy'], // مين اللي ألغى الموعد
      cancellationReason: json['cancellationReason'], // سبب الإلغاء
      canViewMedicalHistory:
          json['canViewMedicalHistory'] ??
          false, // هل المريض يقدر يشوف تاريخه الطبي؟
      // canViewPrescriptions:
      //     json['canViewPrescriptions'] ?? false, // هل المريض يقدر يشوف روشتاته؟
      // canViewLabResults:
      //     json['canViewLabResults'] ??
      //     false, // هل المريض يقدر يشوف نتائج التحاليل؟
      // revokeAll:
      //     json['revokeAll'] ?? false, // هل المريض يقدر يلغى جميع المواعيد؟
    );
  }

  // داخل AppointmentFullDetailsModel
  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'patientNotes': patientNotes,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'medicalRecord':
          medicalRecord != null
              ? (medicalRecord as MedicalRecordModel).toJson()
              : null,
      'prescriptions':
          prescriptions
              ?.map((e) => (e as PrescriptionModel).toJson(appointmentId))
              .toList(),
      'cancelledBy': cancelBy,
      'cancellationReason': cancellationReason,
      'canViewMedicalHistory': canViewMedicalHistory,
    };
  }
}
