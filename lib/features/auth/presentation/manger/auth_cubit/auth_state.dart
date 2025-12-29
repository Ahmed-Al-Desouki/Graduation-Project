part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class LoginLoading extends AuthState {}

final class RegisterLoading extends AuthState {}

final class LoginSuccess extends AuthState {
  final String email;
  final String role;
  final String uid;
  LoginSuccess({required this.uid, required this.email, required this.role});
}

class LoginOtpRequired extends AuthState {
  final String message;
  final String mfaToken;

  LoginOtpRequired({required this.message, required this.mfaToken});
}

final class ResendOtpSuccess extends AuthState {
  final String message;
  ResendOtpSuccess({required this.message});
}

final class ResendOtpLoading extends AuthState {}

final class RegisterSuccess extends AuthState {
  final String email;
  RegisterSuccess({required this.email});
}

final class LoginFailure extends AuthState {
  final String errMessage;
  LoginFailure({required this.errMessage});
}

final class ResendOtpFailure extends AuthState {
  final String errMessage;
  ResendOtpFailure({required this.errMessage});
}

final class RegisterFailure extends AuthState {
  final String errMessage;
  RegisterFailure({required this.errMessage});
}

final class ForgotPasswordLoading extends AuthState {}

final class ForgotPasswordFailure extends AuthState {
  final String errMessage;
  ForgotPasswordFailure({required this.errMessage});
}

final class ForgotPasswordSuccess extends AuthState {
  final String message;
  ForgotPasswordSuccess({required this.message});
}

final class ResetPasswordLoading extends AuthState {}

final class ResetPasswordFailure extends AuthState {
  final String errMessage;
  ResetPasswordFailure({required this.errMessage});
}

final class ResetPasswordSuccess extends AuthState {
  final String message;
  ResetPasswordSuccess({required this.message});
}

final class LogoutLoading extends AuthState {}

final class LogoutSuccess extends AuthState {}

final class LogoutFailure extends AuthState {
  final String errMessage;
  LogoutFailure({required this.errMessage});
}
