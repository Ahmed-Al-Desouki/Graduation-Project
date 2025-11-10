import 'package:bloc/bloc.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/auth/data/models/auth_token_model.dart';
import 'package:graduation_project/features/auth/data/repo/auth_repo.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
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
            await SecureStorageHelper.saveTokens(
              accessToken: response.accessToken,
              refreshToken: response.refreshToken,
            );
            emit(LoginSuccess(email: email));
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
