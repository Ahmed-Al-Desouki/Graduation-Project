import 'package:dartz/dartz.dart';
import 'package:graduation_project/features/search/domain/entities/search_response_entity.dart';
import 'package:graduation_project/features/search/domain/repositories/search_repo.dart';
import '../../../../core/errors/failures.dart';
import '../../data/data_sources/search_remote_data_source.dart';
import '../../data/models/doctor_model.dart';

class SearchRepositoryImpl implements SearchRepo {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SearchResponseEntity>> searchDoctors({
    String? query,
    String? specialization,
    double? patientLatitude,
    double? patientLongitude,
    double? radiusKm,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await remoteDataSource.searchDoctors(
        query: query,
        specialization: specialization,
        patientLatitude: patientLatitude,
        patientLongitude: patientLongitude,
        radiusKm: radiusKm,
        page: page,
        pageSize: pageSize,
      );

      List<dynamic> doctorsData = [];
      if (response.containsKey('doctors')) {
        doctorsData = response['doctors'] as List;
      }

      final doctors =
          doctorsData
              .map(
                (json) => DoctorModel.fromJson(Map<String, dynamic>.from(json)),
              )
              .toList();

      final hasNextPage = response['hasNextPage'] as bool? ?? false;
      final totalCount = response['totalCount'] as int? ?? 0;

      return Right(
        SearchResponseEntity(
          doctors: doctors,
          totalCount: totalCount,
          page: page,
          pageSize: pageSize,
          hasNextPage: hasNextPage,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSpecializations() async {
    try {
      final specializations = await remoteDataSource.getSpecializations();

      return Right(specializations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SearchResponseEntity>> getTopRatedDoctors({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await remoteDataSource.getTopRatedDoctors(
        page: page,
        pageSize: pageSize,
      );

      List<dynamic> doctorsData = [];
      if (response.containsKey('doctors')) {
        doctorsData = response['doctors'] as List;
      }

      final doctors =
          doctorsData
              .map(
                (json) => DoctorModel.fromJson(Map<String, dynamic>.from(json)),
              )
              .toList();

      final hasNextPage = response['hasNextPage'] as bool? ?? false;
      final totalCount = response['totalCount'] as int? ?? 0;

      return Right(
        SearchResponseEntity(
          doctors: doctors,
          totalCount: totalCount,
          page: page,
          pageSize: pageSize,
          hasNextPage: hasNextPage,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
