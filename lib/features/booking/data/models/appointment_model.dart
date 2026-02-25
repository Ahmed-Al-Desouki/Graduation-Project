import '../../domain/entities/appointment_entity.dart';

class AppointmentModel extends AppointmentEntity {
  AppointmentModel({
    required super.appointmentId,
    required super.appointmentDate,
    required super.startTime,
    required super.endTime,
    required super.status,
    super.patientNotes,
    required super.doctorName,
    required super.patientName,
    required super.patientId,
    super.prescriptions,
  });

  // ✅ تحويل الـ JSON القادم من السيرفر إلى Model
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      appointmentId: json['appointmentId'],
      // تحويل النص القادم من الباك (ISO 8601) إلى DateTime
      appointmentDate: DateTime.parse(json['appointmentDate']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      status: json['status'], // القيم: Pending, Confirmed, etc.
      patientNotes: json['patientNotes'],
      doctorName: json['doctorName'] ?? '',
      patientName: json['patientName'] ?? '',
      patientId: json['patientId'] ?? 0,
      prescriptions:
          json['prescriptions'] != null
              ? List<dynamic>.from(json['prescriptions'])
              : [],
    );
  }

  // ✅ (اختياري) لو احتجت تبعت بيانات الموعد في Body لـ API تانية
  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'patientNotes': patientNotes,
      'doctorName': doctorName,
      'patientName': patientName,
      'patientId': patientId,
    };
  }
}
