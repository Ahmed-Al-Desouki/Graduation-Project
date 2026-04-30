import '../../domain/entities/appointment_full_details_entity.dart';
import 'medical_record_model.dart';
import 'prescription_model.dart';

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
  });

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
      status: json['status'],
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
      cancelBy: json['cancelledBy'],
      cancellationReason: json['cancellationReason'],
      canViewMedicalHistory: json['canViewMedicalHistory'] ?? false,
    );
  }

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
