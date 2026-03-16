import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/entities/medication_item_entity.dart';
import 'package:graduation_project/features/booking/domain/repositories/medical_repository.dart';

class AddPrescriptionItemsUseCase {
  final MedicalRepository repository;

  AddPrescriptionItemsUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String prescriptionId,
    required List<MedicationItemEntity> items,
  }) async {
    return await repository.addPrescriptionItems(prescriptionId, items);
  }
}
