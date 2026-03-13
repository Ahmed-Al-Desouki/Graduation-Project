import 'package:dartz/dartz.dart';
import 'package:graduation_project/features/search/domain/entities/search_response_entity.dart';
import 'package:graduation_project/features/search/domain/repositories/search_repo.dart';
import '../../../../core/errors/failures.dart';

class SearchDoctorsUseCase {
  final SearchRepo repository;

  SearchDoctorsUseCase(this.repository);

  Future<Either<Failure, SearchResponseEntity>> call({
    String? query,
    String? specialization,
    int page = 1,
    int pageSize = 10,
  }) async {
    return await repository.searchDoctors(
      query: query,
      specialization: specialization,
      page: page,
      pageSize: pageSize,
    );
  }
}
