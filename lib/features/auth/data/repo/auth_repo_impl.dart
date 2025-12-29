import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/auth/data/models/auth_token_model.dart';
import 'package:graduation_project/features/auth/data/repo/auth_repo.dart';
import 'package:image_picker/image_picker.dart';
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
    XFile? profileImage,
  }) async {
    try {
      final res = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        profileImagePath: profileImage,
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
  Future<Either<Failure, AuthTokenModel>> googleSignIn({
    required String idToken,
    required String role,
  }) async {
    try {
      final res = await _authService.googleSignIn(idToken: idToken, role: role);

      if (res['success'] == true) {
        final tokens = res['data'] ?? res;
        return Right(AuthTokenModel.fromJson(tokens));
      } else {
        final msg = res['data']?['message'] ?? 'Google Sign In failed';
        return Left(ServerFailure(msg));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, dynamic>> login({
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
      print("🧩 LOGIN RESPONSE => $res");

      if (res['success'] == true) {
        if (otpCode == null || otpCode.isEmpty) {
          return Right({
            "message": res['message'] ?? 'OTP Sent successfully',
            "mfaToken": res['mfaToken'],
          });
        } else {
          return Right(AuthTokenModel.fromJson(res));
        }
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
  Future<Either<Failure, AuthTokenModel>> refreshToken({
    required String refreshToken,
    required String accessToken,
  }) async {
    try {
      final res = await _authService.refreshToken(
        refreshToken: refreshToken,
        accessToken: accessToken,
      );

      if (res['success'] == true) {
        final tokens = res['data'] ?? res;
        return Right(AuthTokenModel.fromJson(tokens));
      } else {
        final msg = res['data']?['message'] ?? 'Refresh token failed';
        return Left(ServerFailure(msg));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkAccessValidity(String accessToken) async {
    try {
      final res = await _authService.checkToken();
      print(res);
      return Right(res['summary'] == 'all_valid');
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, bool>> checkRefreshValidity(
    String refreshToken,
  ) async {
    try {
      final res = await _authService.checkRefreshToken(refreshToken);
      print(res);

      return Right(res['summary'] == 'all_valid');
    } catch (e) {
      return const Right(false);
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

  @override
  Future<Either<Failure, Map<String, dynamic>>> resendOtp({
    required String mfaToken,
  }) async {
    try {
      final res = await _authService.resendOtp(mfaToken: mfaToken);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> logout() async {
    try {
      // ✅ جلب البيانات المخزنة مباشرة (بدون فك تشفير)
      final userIdString = await SecureStorageHelper.getUserId();
      final jti = await SecureStorageHelper.getJti();

      final userId = int.tryParse(userIdString ?? "0") ?? 0;

      if (jti != null && userId != 0) {
        // مناداة السيرفيس
        await _authService.logout(userId: userId, jti: jti);
      }

      return const Right(null);
    } catch (e) {
      return const Right(null);
    }
  }
}
