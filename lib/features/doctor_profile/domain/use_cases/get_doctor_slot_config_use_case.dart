import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/slot_config_entity.dart';
import '../repositories/doctor_real_profile_repository.dart';

class GetDoctorSlotConfigUseCase {
  final DoctorRealProfileRepository repository;

  GetDoctorSlotConfigUseCase(this.repository);

  Future<Either<Failure, List<SlotConfigEntity>>> call(int doctorId) async {
    return await repository.getDoctorSlotConfig(doctorId);
  }
}
