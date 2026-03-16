import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/entities/prescription_entity.dart';
import 'package:graduation_project/features/booking/domain/repositories/medical_repository.dart';

class GetPrescriptionUseCase {
  final MedicalRepository repository;
  GetPrescriptionUseCase(this.repository);

  Future<Either<Failure, PrescriptionEntity>> call(String appointmentId) async {
    final result = await repository.getPrescriptions(appointmentId);

    return result.fold(
      (failure) {
        // ✅ لو السيرفر رجع 404، نعتبرها نجاح لكن بروشتة فاضية بدل ما نطلع أيرور
        if (failure.errmessage.contains("404")) {
          return Right(PrescriptionEntity(items: []));
        }
        return Left(failure);
      },
      (prescriptions) {
        if (prescriptions.isNotEmpty) {
          return Right(prescriptions.first);
        } else {
          // ✅ برضه هنا نرجع Right فاضي بدل Left
          return Right(PrescriptionEntity(items: []));
        }
      },
    );
  }
}
