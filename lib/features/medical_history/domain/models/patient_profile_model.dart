import 'package:graduation_project/features/booking/data/models/appointment_full_details_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/social_history_model.dart';
import 'package:graduation_project/features/medical_history/domain/models/surgery_model.dart';
import 'medical_file_model.dart';

class PatientProfileModel {
  final int patientID;
  final int medicalHistoryID;
  final String fullName;
  final String email;
  final String? profileImageUrl;
  final String? dateOfBirth;
  final int age;
  final String gender;
  final String? currentLocation;
  final String? bloodType;
  final double height;
  final double weight;
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<MedicalFileModel> labTests;
  final List<MedicalFileModel> radiologyFiles;
  final List<AppointmentFullDetailsModel> pastAppointments;
  final List<dynamic> medicalRecords;
  final List<SurgeryModel> surgeries;
  final List<FamilyHistoryModel> familyHistory;
  final SocialHistoryModel? socialHistory;
  final List<MedicationModel> currentMedications;
  final List<MedicationModel> patientSelfMedications;

  PatientProfileModel({
    required this.patientID,
    required this.medicalHistoryID,
    required this.fullName,
    required this.email,
    this.profileImageUrl,
    this.dateOfBirth,
    required this.age,
    required this.gender,
    this.currentLocation,
    this.bloodType,
    required this.height,
    required this.weight,
    required this.allergies,
    required this.chronicConditions,
    required this.labTests,
    required this.radiologyFiles,
    required this.pastAppointments,
    required this.medicalRecords,
    required this.surgeries,
    required this.familyHistory,
    this.socialHistory,
    required this.currentMedications,
    required this.patientSelfMedications,
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientProfileModel(
      patientID: json['patientID'] ?? 0,
      medicalHistoryID: json['medicalHistoryID'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      dateOfBirth: json['dateOfBirth'],
      age: json['age'] ?? 0,
      gender: json['gender'] ?? 'Unknown',
      currentLocation: json['currentLocation'],
      bloodType: json['bloodType'],
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,

      allergies:
          (json['allergies'] is List)
              ? (json['allergies'] as List).map((e) => e.toString()).toList()
              : [],

      chronicConditions:
          (json['chronicConditions'] is List)
              ? (json['chronicConditions'] as List)
                  .map((e) => e.toString())
                  .toList()
              : [],

      labTests:
          (json['labTests'] is List)
              ? (json['labTests'] as List)
                  .map(
                    (e) => MedicalFileModel.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : [],

      radiologyFiles:
          (json['radiologyFiles'] is List)
              ? (json['radiologyFiles'] as List)
                  .map(
                    (e) => MedicalFileModel.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : [],

      // pastAppointments:
      //     (json['pastAppointments'] is List) ? json['pastAppointments'] : [],
      pastAppointments:
          (json['pastAppointments'] as List?)
              ?.map(
                (e) => AppointmentFullDetailsModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      medicalRecords:
          (json['medicalRecords'] is List) ? json['medicalRecords'] : [],

      surgeries:
          (json['surgeries'] is List)
              ? (json['surgeries'] as List)
                  .map((e) => SurgeryModel.fromJson(e as Map<String, dynamic>))
                  .toList()
              : [],

      familyHistory:
          (json['familyHistory'] is List)
              ? (json['familyHistory'] as List)
                  .map(
                    (e) =>
                        FamilyHistoryModel.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : [],

      socialHistory: _parseSocialHistory(json['socialHistory']),

      currentMedications:
          (json['currentMedications'] is List)
              ? (json['currentMedications'] as List)
                  .map(
                    (e) => MedicationModel.fromJson(
                      e as Map<String, dynamic>,
                    ).copyWith(isSelfMedication: false),
                  )
                  .toList()
              : [],

      patientSelfMedications:
          (json['patientSelfMedications'] is List)
              ? (json['patientSelfMedications'] as List)
                  .map(
                    (e) => MedicationModel.fromJson(
                      e as Map<String, dynamic>,
                    ).copyWith(isSelfMedication: true),
                  )
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientID': patientID,
      'medicalHistoryID': medicalHistoryID,
      'fullName': fullName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'gender': gender,
      'currentLocation': currentLocation,
      'bloodType': bloodType,
      'height': height,
      'weight': weight,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'labTests': labTests.map((e) => e.toJson()).toList(),
      'radiologyFiles': radiologyFiles.map((e) => e.toJson()).toList(),
      // 'pastAppointments': pastAppointments,
      'pastAppointments':
          pastAppointments.map((e) {
            if (e is AppointmentFullDetailsModel) return e.toJson();
            return e; // لو هو أصلاً Map أو نوع تاني
          }).toList(),
      'medicalRecords': medicalRecords,
      'surgeries': surgeries.map((e) => e.toJson()).toList(),
      'familyHistory': familyHistory.map((e) => e.toJson()).toList(),
      'socialHistory': socialHistory?.toJson(),
      'currentMedications': currentMedications.map((e) => e.toJson()).toList(),
      'patientSelfMedications':
          patientSelfMedications.map((e) => e.toJson()).toList(),
    };
  }

  static SocialHistoryModel? _parseSocialHistory(dynamic data) {
    if (data == null) return null;

    if (data is List) {
      if (data.isEmpty) return null;
      return SocialHistoryModel.fromJson(data.first as Map<String, dynamic>);
    }
    if (data is Map<String, dynamic>) {
      return SocialHistoryModel.fromJson(data);
    }

    return null;
  }
}
