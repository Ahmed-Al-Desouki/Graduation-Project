import 'package:dartz/dartz.dart';
import 'package:graduation_project/features/search/domain/entities/search_response_entity.dart';
import '../../../../core/errors/failures.dart';

abstract class SearchRepo {
  Future<Either<Failure, SearchResponseEntity>> searchDoctors({
    String? query,
    String? specialization,
    double? patientLatitude,
    double? patientLongitude,
    double? radiusKm,
    int page = 1,
    int pageSize,
  });

  Future<Either<Failure, List<String>>> getSpecializations();

  Future<Either<Failure, SearchResponseEntity>> getTopRatedDoctors({
    int page = 1,
    int pageSize,
  });
}
