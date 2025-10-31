part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class LoginLoading extends AuthState {}

final class RegisterLoading extends AuthState {}

final class LoginSuccess extends AuthState {
  final String uid;
  final String email;
  LoginSuccess({required this.uid, required this.email});
}

final class RegisterSuccess extends AuthState {
  final String uid;
  final String email;
  RegisterSuccess({required this.uid, required this.email});
}

final class LoginFailure extends AuthState {
  final String errMessage;
  LoginFailure({required this.errMessage});
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
