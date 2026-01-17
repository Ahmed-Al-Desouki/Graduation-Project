import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/home/data/models/home_user_model.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeUserModel>> fetchHomeUserInfo();
}
