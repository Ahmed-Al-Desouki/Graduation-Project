import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/features/doctor_profile/domain/repositories/doctor_real_profile_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/doctor_profile_entity.dart';
import '../data_sources/doctor_profile_remote_data_source.dart';

class DoctorRealProfileRepositoryImpl implements DoctorRealProfileRepository {
  final DoctorProfileRemoteDataSource remoteDataSource;

  DoctorRealProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, DoctorProfileEntity>> getDoctorProfile() async {
    try {
      final result = await remoteDataSource.getDoctorProfile();
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
