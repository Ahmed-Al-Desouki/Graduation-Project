import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/repositories/medical_repository.dart';
import 'package:graduation_project/features/medical_history/domain/models/patient_profile_model.dart';

class GetPatientProfileForDoctorUseCase {
  final MedicalRepository repository;
  GetPatientProfileForDoctorUseCase(this.repository);

  Future<Either<Failure, PatientProfileModel>> call(String pId, String aId) {
    return repository.getPatientProfileForDoctor(
      patientId: pId,
      appointmentId: aId,
    );
  }
}
