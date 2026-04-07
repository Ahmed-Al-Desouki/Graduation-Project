import 'package:dartz/dartz.dart';
import 'package:graduation_project/features/medical_history/domain/models/patient_profile_model.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/medical_repository.dart';
import '../data_sources/medical_remote_data_source.dart';
import '../models/medical_record_model.dart';
import '../models/medication_item_model.dart';
import '../../domain/entities/medical_record_entity.dart';
import '../../domain/entities/prescription_entity.dart';
import '../../domain/entities/medication_item_entity.dart';

class MedicalRepositoryImpl implements MedicalRepository {
  final MedicalRemoteDataSource remoteDataSource;

  MedicalRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, MedicalRecordEntity>> getMedicalRecord(
    String appointmentId,
  ) async {
    try {
      final result = await remoteDataSource.getMedicalRecord(appointmentId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createMedicalRecord(
    String appointmentId,
    MedicalRecordEntity record,
  ) async {
    try {
      // تحويل الـ Entity لـ Model قبل الإرسال
      final model = MedicalRecordModel(
        chiefComplaint: record.chiefComplaint,
        vitalSigns: record.vitalSigns,
        physicalExamination: record.physicalExamination,
        diagnosis: record.diagnosis,
        diagnosisCode: record.diagnosisCode,
        treatmentPlan: record.treatmentPlan,
        doctorNotes: record.doctorNotes,
        followUpRequired: record.followUpRequired,
        followUpDate: record.followUpDate,
        followUpInstructions: record.followUpInstructions,
      );
      final message = await remoteDataSource.createMedicalRecord(
        appointmentId,
        model,
      );
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateMedicalRecord(
    String appointmentId,
    MedicalRecordEntity record,
  ) async {
    try {
      final model = MedicalRecordModel(
        chiefComplaint: record.chiefComplaint,
        vitalSigns: record.vitalSigns,
        physicalExamination: record.physicalExamination,
        diagnosis: record.diagnosis,
        diagnosisCode: record.diagnosisCode,
        treatmentPlan: record.treatmentPlan,
        doctorNotes: record.doctorNotes,
        followUpRequired: record.followUpRequired,
        followUpDate: record.followUpDate,
        followUpInstructions: record.followUpInstructions,
      );
      final message = await remoteDataSource.updateMedicalRecord(
        appointmentId,
        model,
      );
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PrescriptionEntity>>> getPrescriptions(
    String appointmentId,
  ) async {
    try {
      final result = await remoteDataSource.getPrescriptionByAppointment(
        appointmentId,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PrescriptionEntity>> createPrescription(
    String appointmentId,
    PrescriptionEntity prescription,
  ) async {
    try {
      final Map<String, dynamic> body = {
        "appointmentId": appointmentId,
        "validUntil": prescription.validUntil?.toIso8601String(),
        "specialInstructions": prescription.specialInstructions,
        "items":
            prescription.items
                .map(
                  (e) =>
                      MedicationItemModel(
                        medicationName: e.medicationName,
                        dosage: e.dosage,
                        frequency: e.frequency,
                        duration: e.duration,
                        quantity: e.quantity,
                        instructions: e.instructions,
                        reminderFrequencyType: e.reminderFrequencyType,
                        reminderWeeklyDays: e.reminderWeeklyDays,
                        reminderDailyDoseTimes: e.reminderDailyDoseTimes,
                        reminderIntervalHours: e.reminderIntervalHours,
                        reminderStartDate: e.reminderStartDate,
                        reminderEndDate: e.reminderEndDate,
                        reminderFirstDoseTime: e.reminderFirstDoseTime,
                      ).toJson(),
                )
                .toList(),
      };
      final result = await remoteDataSource.createPrescription(body);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> addPrescriptionItems(
    String prescriptionId,
    List<MedicationItemEntity> items,
  ) async {
    try {
      final models =
          items
              .map(
                (e) => MedicationItemModel(
                  medicationName: e.medicationName,
                  dosage: e.dosage,
                  frequency: e.frequency,
                  duration: e.duration,
                  quantity: e.quantity,
                  instructions: e.instructions,
                  reminderFrequencyType: e.reminderFrequencyType,
                  reminderWeeklyDays: e.reminderWeeklyDays,
                  reminderDailyDoseTimes: e.reminderDailyDoseTimes,
                  reminderIntervalHours: e.reminderIntervalHours,
                  reminderStartDate: e.reminderStartDate,
                  reminderEndDate: e.reminderEndDate,
                  reminderFirstDoseTime: e.reminderFirstDoseTime,
                ),
              )
              .toList();
      final message = await remoteDataSource.addPrescriptionItemsBulk(
        prescriptionId,
        models,
      );
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PatientProfileModel>> getPatientProfileForDoctor({
    required String patientId,
    required String appointmentId,
  }) async {
    try {
      // 1. نداء الداتا سورس
      final response = await remoteDataSource.getPatientProfileForDoctor(
        patientId,
        appointmentId,
      );

      // 2. تحويل الـ JSON للموديل العبقري اللي إنت لسه باعتهولي
      final model = PatientProfileModel.fromJson(response);

      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
