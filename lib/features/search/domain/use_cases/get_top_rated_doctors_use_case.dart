import 'package:dartz/dartz.dart';
import 'package:graduation_project/features/search/domain/entities/search_response_entity.dart';
import 'package:graduation_project/features/search/domain/repositories/search_repo.dart';
import '../../../../core/errors/failures.dart';

class GetTopRatedDoctorsUseCase {
  final SearchRepo repository;

  GetTopRatedDoctorsUseCase(this.repository);

  Future<Either<Failure, SearchResponseEntity>> call({
    int page = 1,
    int pageSize = 10,
  }) async {
    return await repository.getTopRatedDoctors(page: page, pageSize: pageSize);
  }
}
