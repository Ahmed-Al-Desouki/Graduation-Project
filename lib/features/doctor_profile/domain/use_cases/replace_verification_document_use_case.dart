import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/doctor_real_profile_repository.dart';

class ReplaceVerificationDocumentUseCase {
  final DoctorRealProfileRepository repository;

  ReplaceVerificationDocumentUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required int verificationId,
    required File newFile,
  }) async {
    return await repository.replaceVerificationDocument(
      verificationId: verificationId,
      newFile: newFile,
    );
  }
}
