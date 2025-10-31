import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/auth/data/repo/auth_repo.dart';
import '../services/auth_web_service.dart';

class AuthRepositoryimpl implements AuthRepository {
  final AuthWebServices _authService;

  AuthRepositoryimpl(this._authService);

  @override
  Future<Either<Failure, String>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final res = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );

      if (res['success'] == true) {
        final msg = res['data']?['message'] ?? 'Registered successfully';
        return Right(msg);
      } else {
        final msg = res['data']?['message'] ?? 'Registration failed';
        return Left(ServerFailure(msg));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> login({
    required String email,
    required String password,
    String? otpCode,
  }) async {
    try {
      final res = await _authService.login(
        email: email,
        password: password,
        otpCode: otpCode ?? "",
      );

      if (res['success'] == true) {
        final token = res['data']?['accessToken'] ?? '';
        return Right(token);
      } else {
        final msg = res['data']?['message'] ?? 'Login failed';
        return Left(ServerFailure(msg));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword({
    required String email,
  }) async {
    try {
      final res = await _authService.forgotPassword(email: email);

      if (res['success'] == true) {
        final msg =
            res['data']?['message'] ?? 'Password reset email sent successfully';
        return Right(msg);
      } else {
        final msg =
            res['data']?['message'] ?? 'Failed to send password reset email';
        return Left(ServerFailure(msg));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final res = await _authService.resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (res['success'] == true) {
        final msg = res['data']?['message'] ?? 'Password reset successfully';
        return Right(msg);
      } else {
        final msg = res['data']?['message'] ?? 'Password reset failed';
        return Left(ServerFailure(msg));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
