import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/auth/data/models/auth_token_model.dart';
import 'package:image_picker/image_picker.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    XFile? profileImage,
  });

  Future<Either<Failure, dynamic>> login({
    required String email,
    required String password,
    String? otpCode,
  });

  Future<Either<Failure, AuthTokenModel>> googleSignIn({
    required String idToken,
    required String role,
  });

  Future<Either<Failure, String>> forgotPassword({required String email});
  Future<Either<Failure, String>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
  });

  Future<Either<Failure, AuthTokenModel>> refreshToken({
    required String refreshToken,
    required String accessToken,
  });

  Future<Either<Failure, bool>> checkAccessValidity(String accessToken);

  Future<Either<Failure, bool>> checkRefreshValidity(String refreshToken);

  Future<Either<Failure, Map<String, dynamic>>> resendOtp({
    required String mfaToken,
  });

  Future<Either<Failure, void>> logout();
}
