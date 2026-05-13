import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/review/domain/repos/review_repo.dart';
import '../web_services/review_web_service.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewWebService _reviewWebService;

  ReviewRepositoryImpl(this._reviewWebService);

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
  Future<Either<Failure, void>> postReview(ReviewModel review) async {
    return _taskWrapper(() async {
      await _reviewWebService.postReview(review.toJson());
    });
  }
}
