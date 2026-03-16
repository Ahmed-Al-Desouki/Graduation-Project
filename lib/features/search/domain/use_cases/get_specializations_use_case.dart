import 'package:dartz/dartz.dart';
import 'package:graduation_project/features/search/domain/repositories/search_repo.dart';
import '../../../../core/errors/failures.dart';

class GetSpecializationsUseCase {
  final SearchRepo repository;

  GetSpecializationsUseCase(this.repository);

  Future<Either<Failure, List<String>>> call() async {
    return await repository.getSpecializations();
  }
}
