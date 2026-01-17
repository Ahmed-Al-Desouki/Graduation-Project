import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/home/data/models/home_user_model.dart';
import 'package:graduation_project/features/home/data/service/home_web_service.dart';
import 'package:graduation_project/features/home/domain/repos/home_repo.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeWebService _homeWebService;

  HomeRepositoryImpl(this._homeWebService);

  Future<Either<Failure, T>> _taskWrapper<T>(
    Future<T> Function() action,
  ) async {
    try {
      return Right(await action());
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioException(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HomeUserModel>> fetchHomeUserInfo() async {
    return _taskWrapper(() async {
      final response = await _homeWebService.fetchHomeUserInfo();
      if (response['success'] == true) {
        // ✅ إضافة الـ Versioning للرابط عشان نكسر الكاش
        String? imageUrl = response['imageUrl'];
        if (imageUrl != null && imageUrl.isNotEmpty) {
          imageUrl = "$imageUrl?v=${DateTime.now().millisecondsSinceEpoch}";
        }

        return HomeUserModel(
          fullName: response['fullName'] ?? 'User',
          imageUrl: imageUrl,
        );
      }
      throw Exception(response['message'] ?? 'Failed to load user info');
    });
  }
}
