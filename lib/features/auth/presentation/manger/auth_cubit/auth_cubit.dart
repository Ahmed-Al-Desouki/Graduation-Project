import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/auth/data/models/auth_token_model.dart';

import 'package:graduation_project/features/auth/data/repo/auth_repo.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final _secureStorage = const FlutterSecureStorage();
  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> login({
    required String email,
    required String password,
    String? otpCode,
  }) async {
    emit(LoginLoading());

    final result = await _authRepository.login(
      email: email,
      password: password,
      otpCode: otpCode,
    );

    result.fold(
      (failure) => emit(LoginFailure(errMessage: failure.errmessage)),
      (response) async {
        if (response is Map<String, dynamic>) {
          emit(
            LoginOtpRequired(
              message: response["message"],
              mfaToken: response["mfaToken"],
            ),
          );
          print("MFA TOKEN IN CUBIT: ${response["mfaToken"]}");
        } else if (response is AuthTokenModel) {
          try {
            Map<String, dynamic> payload = JwtDecoder.decode(
              response.accessToken,
            );
            final role =
                (payload['role'] ?? payload['Role'] ?? '')
                    .toString()
                    .toLowerCase();
            final uid =
                (payload['uid'] ?? payload['userId'] ?? payload['id'] ?? '')
                    .toString();

            await SecureStorageHelper.saveTokens(
              accessToken: response.accessToken,
              refreshToken: response.refreshToken,
            );

            await SecureStorageHelper.saveUserRoleAndId(
              role: role,
              userId: uid,
            );

            emit(LoginSuccess(uid: uid, email: email, role: role));
          } catch (e) {
            emit(LoginFailure(errMessage: 'Failed to save tokens: $e'));
          }
        } else {
          emit(
            LoginFailure(errMessage: 'Unknown response type from repository'),
          );
        }
      },
    );
    // =======
    //     (failure) => emit(LoginFailure(errMessage: failure.errmessage)),
    //     (token) async {
    //       // token هنا مفترض string access token
    //       try {
    //         // decode
    //         Map<String, dynamic> payload = JwtDecoder.decode(token);
    //         final role = (payload['role'] ?? payload['Role'] ?? '').toString().toLowerCase();
    //         final uid = (payload['uid'] ?? payload['userId'] ?? payload['id'] ?? '').toString();

    //         final prefs = await SharedPreferences.getInstance();
    //         await prefs.setString('accessToken', token);
    //         await prefs.setString('role', role);

    //         // لو بتحب تعدل ApiService ليضيف التوكن تلقائي
    //         // getIt<ApiService>().setToken(token); // قابل للتنفيذ لو ضفت method في ApiService

    //         emit(LoginSuccess(uid: uid, email: email, role: role,));
    //       } catch (e) {
    //         // لو decode فشل
    //         emit(LoginFailure(errMessage: 'Invalid token format'));
    //       }
    //     },
    //   );
    // >>>>>>> origin/login-register
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    emit(RegisterLoading());
    final result = await _authRepository.register(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );

    result.fold(
      (failure) => emit(RegisterFailure(errMessage: failure.errmessage)),
      (message) => emit(RegisterSuccess(email: email)),
    );
  }

  Future<void> forgotPassword({required String email}) async {
    emit(ForgotPasswordLoading());
    final result = await _authRepository.forgotPassword(email: email);

    result.fold(
      (failure) => emit(ForgotPasswordFailure(errMessage: failure.errmessage)),
      (message) => emit(ForgotPasswordSuccess(message: message)),
    );
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(ResetPasswordLoading());
    final result = await _authRepository.resetPassword(
      email: email,
      token: token,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    result.fold(
      (failure) => emit(ResetPasswordFailure(errMessage: failure.errmessage)),
      (message) => emit(ResetPasswordSuccess(message: message)),
    );
  }

  Future<void> resendOtp(String mfaToken) async {
    emit(ResendOtpLoading());

    final result = await _authRepository.resendOtp(mfaToken: mfaToken);

    result.fold(
      (failure) => emit(ResendOtpFailure(errMessage: failure.errmessage)),
      (response) =>
          emit(ResendOtpSuccess(message: response["message"] ?? "OTP Sent")),
    );
  }
}
