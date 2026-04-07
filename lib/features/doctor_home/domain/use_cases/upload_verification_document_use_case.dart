import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/verification_document_entity.dart';
import '../repositories/doctor_profile_repository.dart';

class UploadVerificationDocumentUseCase {
  final DoctorProfileRepository repository;

  UploadVerificationDocumentUseCase(this.repository);

  Future<Either<Failure, bool>> call(
    VerificationDocumentEntity document,
  ) async {
    return await repository.uploadVerificationDocument(document);
  }
}
