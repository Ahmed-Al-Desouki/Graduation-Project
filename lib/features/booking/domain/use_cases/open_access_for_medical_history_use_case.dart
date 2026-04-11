import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/repositories/medical_repository.dart';

class OpenAccessForMedicalHistoryUseCase {
  final MedicalRepository repository;

  OpenAccessForMedicalHistoryUseCase(this.repository);

  // Future<Either<Failure, String>> call(String appointmentId) async {
  //   return await repository.grantMedicalAccess(appointmentId);
  // }
  Future<Either<Failure, String>> call(
    String appointmentId,
    bool isGranting,
  ) async {
    return await repository.grantMedicalAccess(appointmentId, isGranting);
  }
}
