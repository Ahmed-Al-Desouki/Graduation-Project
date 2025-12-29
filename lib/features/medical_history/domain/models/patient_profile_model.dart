// import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';
// import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';
// import 'package:graduation_project/features/medical_history/domain/models/social_history_model.dart';
// import 'package:graduation_project/features/medical_history/domain/models/surgery_model.dart';
// import 'medical_file_model.dart';

// class PatientProfileModel {
//   final int patientID;
//   final int medicalHistoryID;
//   final String fullName;
//   // ... باقي المتغيرات ...
//   final String email;
//   final String? profileImageUrl;
//   final String? dateOfBirth;
//   final int age;
//   final String gender;
//   final String? currentLocation;
//   final String? bloodType;
//   final double height;
//   final double weight;

//   final List<String> allergies;
//   final List<String> chronicConditions;
//   final List<MedicalFileModel> labTests;
//   final List<MedicalFileModel> radiologyFiles;
//   final List<dynamic> pastAppointments;
//   final List<dynamic> medicalRecords;

//   final List<SurgeryModel> surgeries;
//   final List<FamilyHistoryModel> familyHistory;
//   final SocialHistoryModel? socialHistory;

//   // ✅✅ هنا التعديل: فصلنا القائمتين
//   final List<MedicationModel> currentMedications; // أدوية الدكتور
//   final List<MedicationModel> patientSelfMedications; // أدوية المريض

//   PatientProfileModel({
//     required this.patientID,
//     required this.medicalHistoryID,
//     required this.fullName,
//     required this.email,
//     this.profileImageUrl,
//     this.dateOfBirth,
//     required this.age,
//     required this.gender,
//     this.currentLocation,
//     this.bloodType,
//     required this.height,
//     required this.weight,
//     required this.allergies,
//     required this.chronicConditions,
//     required this.labTests,
//     required this.radiologyFiles,
//     required this.pastAppointments,
//     required this.medicalRecords,
//     required this.surgeries,
//     required this.familyHistory,
//     this.socialHistory,
//     // ✅
//     required this.currentMedications,
//     required this.patientSelfMedications,
//   });

//   factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
//     return PatientProfileModel(
//       patientID: json['patientID'] ?? 0,
//       medicalHistoryID: json['medicalHistoryID'] ?? 0,
//       fullName: json['fullName'] ?? '',
//       email: json['email'] ?? '',
//       profileImageUrl: json['profileImageUrl'],
//       dateOfBirth: json['dateOfBirth'],
//       age: json['age'] ?? 0,
//       gender: json['gender'] ?? 'Unknown',
//       currentLocation: json['currentLocation'],
//       bloodType: json['bloodType'],
//       height: (json['height'] as num?)?.toDouble() ?? 0.0,
//       weight: (json['weight'] as num?)?.toDouble() ?? 0.0,

//       allergies:
//           (json['allergies'] is List)
//               ? (json['allergies'] as List).map((e) => e.toString()).toList()
//               : [],

//       chronicConditions:
//           (json['chronicConditions'] is List)
//               ? (json['chronicConditions'] as List)
//                   .map((e) => e.toString())
//                   .toList()
//               : [],

//       labTests:
//           (json['labTests'] is List)
//               ? (json['labTests'] as List)
//                   .map(
//                     (e) => MedicalFileModel.fromJson(e as Map<String, dynamic>),
//                   )
//                   .toList()
//               : [],

//       radiologyFiles:
//           (json['radiologyFiles'] is List)
//               ? (json['radiologyFiles'] as List)
//                   .map(
//                     (e) => MedicalFileModel.fromJson(e as Map<String, dynamic>),
//                   )
//                   .toList()
//               : [],

//       pastAppointments:
//           (json['pastAppointments'] is List) ? json['pastAppointments'] : [],
//       medicalRecords:
//           (json['medicalRecords'] is List) ? json['medicalRecords'] : [],

//       surgeries:
//           (json['surgeries'] is List)
//               ? (json['surgeries'] as List)
//                   .map((e) => SurgeryModel.fromJson(e as Map<String, dynamic>))
//                   .toList()
//               : [],

//       familyHistory:
//           (json['familyHistory'] is List)
//               ? (json['familyHistory'] as List)
//                   .map(
//                     (e) =>
//                         FamilyHistoryModel.fromJson(e as Map<String, dynamic>),
//                   )
//                   .toList()
//               : [],

//       socialHistory:
//           (json['socialHistory'] is Map<String, dynamic>)
//               ? SocialHistoryModel.fromJson(json['socialHistory'])
//               : null,

//       // ✅ 1. أدوية الدكتور (نخلي isSelf = false)
//       currentMedications:
//           (json['currentMedications'] is List)
//               ? (json['currentMedications'] as List)
//                   .map(
//                     (e) => MedicationModel.fromJson(
//                       e as Map<String, dynamic>,
//                     ).copyWith(isSelfMedication: false),
//                   ) // 👈 مهم جداً
//                   .toList()
//               : [],

//       // ✅ 2. أدوية المريض (نخلي isSelf = true)
//       patientSelfMedications:
//           (json['patientSelfMedications'] is List)
//               ? (json['patientSelfMedications'] as List)
//                   .map(
//                     (e) => MedicationModel.fromJson(
//                       e as Map<String, dynamic>,
//                     ).copyWith(isSelfMedication: true),
//                   ) // 👈 مهم جداً
//                   .toList()
//               : [],
//     );
//   }
// }

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
  final List<dynamic> pastAppointments;
  final List<dynamic> medicalRecords;

  final List<SurgeryModel> surgeries;
  final List<FamilyHistoryModel> familyHistory;

  // ده الحقل اللي كان عامل المشكلة
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

      pastAppointments:
          (json['pastAppointments'] is List) ? json['pastAppointments'] : [],
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

      // ✅✅ التعديل هنا: استخدام دالة مساعدة للتعامل مع الـ List
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

  // ✅ دالة مساعدة ذكية للتعامل مع الـ Social History
  static SocialHistoryModel? _parseSocialHistory(dynamic data) {
    if (data == null) return null;

    // 1. لو راجع كـ List (زي الوضع الحالي في الباك إيند)
    if (data is List) {
      if (data.isEmpty) return null;
      // ناخد أول عنصر في القائمة لأنه سجل واحد
      return SocialHistoryModel.fromJson(data.first as Map<String, dynamic>);
    }

    // 2. لو راجع كـ Map (لو الباك إيند قرر يغيره لمفرد)
    if (data is Map<String, dynamic>) {
      return SocialHistoryModel.fromJson(data);
    }

    return null;
  }
}
