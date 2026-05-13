import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/review/data/models/review_model.dart';

abstract class ReviewRepository {
  Future<Either<Failure, void>> postReview(ReviewModel review);
}
