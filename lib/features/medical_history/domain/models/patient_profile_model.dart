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
  final List<dynamic> pastAppointments;
  final List<dynamic> medicalRecords;

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
          (json['allergies'] as List?)?.map((e) => e.toString()).toList() ?? [],
      chronicConditions:
          (json['chronicConditions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      labTests:
          (json['labTests'] as List?)
              ?.map((e) => MedicalFileModel.fromJson(e))
              .toList() ??
          [],
      radiologyFiles:
          (json['radiologyFiles'] as List?)
              ?.map((e) => MedicalFileModel.fromJson(e))
              .toList() ??
          [],

      pastAppointments: json['pastAppointments'] ?? [],
      medicalRecords: json['medicalRecords'] ?? [],
    );
  }
}
