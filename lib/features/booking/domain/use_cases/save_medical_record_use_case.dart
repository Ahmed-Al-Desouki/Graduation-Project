import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/entities/medical_record_entity.dart';
import 'package:graduation_project/features/booking/domain/repositories/medical_repository.dart';

class SaveMedicalRecordUseCase {
  final MedicalRepository repository;
  SaveMedicalRecordUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String appointmentId,
    required MedicalRecordEntity record,
    required bool isUpdate,
  }) {
    if (isUpdate) {
      return repository.updateMedicalRecord(appointmentId, record);
    } else {
      return repository.createMedicalRecord(appointmentId, record);
    }
  }
}
