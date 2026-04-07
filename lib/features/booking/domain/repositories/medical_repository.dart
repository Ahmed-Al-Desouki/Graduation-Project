import 'package:dartz/dartz.dart';
import 'package:graduation_project/features/medical_history/domain/models/patient_profile_model.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medical_record_entity.dart';
import '../entities/prescription_entity.dart';
import '../entities/medication_item_entity.dart';

abstract class MedicalRepository {
  // Medical Record
  Future<Either<Failure, MedicalRecordEntity>> getMedicalRecord(
    String appointmentId,
  );
  Future<Either<Failure, String>> createMedicalRecord(
    String appointmentId,
    MedicalRecordEntity record,
  );
  Future<Either<Failure, String>> updateMedicalRecord(
    String appointmentId,
    MedicalRecordEntity record,
  );

  // Prescription
  Future<Either<Failure, List<PrescriptionEntity>>> getPrescriptions(
    String appointmentId,
  );
  Future<Either<Failure, PrescriptionEntity>> createPrescription(
    String appointmentId,
    PrescriptionEntity prescription,
  );
  Future<Either<Failure, String>> addPrescriptionItems(
    String prescriptionId,
    List<MedicationItemEntity> items,
  );

  Future<Either<Failure, PatientProfileModel>> getPatientProfileForDoctor({
    required String patientId,
    required String appointmentId,
  });
}
