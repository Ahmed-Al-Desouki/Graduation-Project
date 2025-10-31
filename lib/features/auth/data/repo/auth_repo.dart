import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  });

  Future<Either<Failure, String>> login({
    required String email,
    required String password,
    String? otpCode,
  });

  Future<Either<Failure, String>> forgotPassword({required String email});
  Future<Either<Failure, String>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
  });
}
