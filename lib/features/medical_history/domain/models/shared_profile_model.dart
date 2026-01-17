import 'package:graduation_project/features/medical_history/domain/models/surgery_model.dart';

class SharedProfileModel {
  final String patientName;
  final int age;
  final String bloodType;
  final List<String> allergies;
  final List<String> conditions;
  final List<String> medications;
  final List<SurgeryModel> surgeries;

  SharedProfileModel({
    required this.patientName,
    required this.age,
    required this.bloodType,
    required this.allergies,
    required this.conditions,
    required this.medications,
    required this.surgeries,
  });

  factory SharedProfileModel.fromJson(Map<String, dynamic> json) {
    return SharedProfileModel(
      patientName: json['fullName'] ?? 'Unknown',
      age: json['age'] ?? 0,
      bloodType: json['bloodType'] ?? 'N/A',
      allergies: List<String>.from(json['allergies'] ?? []),
      conditions: List<String>.from(json['chronicConditions'] ?? []),
      medications: [
        ...List<String>.from(json['currentMedications'] ?? []),
        ...List<String>.from(json['patientSelfMedications'] ?? []),
      ],
      surgeries: List<SurgeryModel>.from(json['surgeries'] ?? []),
    );
  }
}
