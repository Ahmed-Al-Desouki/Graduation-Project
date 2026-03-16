import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/entities/prescription_entity.dart';
import 'package:graduation_project/features/booking/domain/repositories/medical_repository.dart';

class CreatePrescriptionUseCase {
  final MedicalRepository repository;
  CreatePrescriptionUseCase(this.repository);

  Future<Either<Failure, PrescriptionEntity>> call(
    String appointmentId,
    PrescriptionEntity prescription,
  ) {
    return repository.createPrescription(appointmentId, prescription);
  }
}
