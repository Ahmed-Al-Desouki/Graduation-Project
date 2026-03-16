import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/entities/medical_record_entity.dart';
import 'package:graduation_project/features/booking/domain/repositories/medical_repository.dart';

class GetMedicalRecordUseCase {
  final MedicalRepository repository;
  GetMedicalRecordUseCase(this.repository);

  Future<Either<Failure, MedicalRecordEntity>> call(String appointmentId) {
    return repository.getMedicalRecord(appointmentId);
  }
}
