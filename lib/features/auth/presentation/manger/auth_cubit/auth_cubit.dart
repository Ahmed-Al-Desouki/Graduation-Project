import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/auth/data/repo/auth_repo.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  AuthCubit(this._authRepository) : super(AuthInitial());
  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());
    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => emit(LoginFailure(errMessage: failure.errmessage)),
      (token) => emit(LoginSuccess(uid: 'unknown', email: email)),
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
      (message) => emit(RegisterSuccess(uid: 'temp', email: email)),
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
}
