part of 'patient_account_profile_cubit.dart';

@immutable
sealed class PatientAccountProfileState {}

final class PatientAccountProfileInitial extends PatientAccountProfileState {}

final class PatientAccountProfileLoading extends PatientAccountProfileState {}

final class PatientAccountProfileLoaded extends PatientAccountProfileState {
  final PatientAccountProfileEntity profile;

  PatientAccountProfileLoaded(this.profile);
}

final class PatientAccountProfileFailure extends PatientAccountProfileState {
  final String errorMessage;

  PatientAccountProfileFailure(this.errorMessage);
}

final class PatientAccountProfileUpdateLoading
    extends PatientAccountProfileState {}

final class PatientAccountProfileUpdateSuccess
    extends PatientAccountProfileState {
  final String message;

  PatientAccountProfileUpdateSuccess(this.message);
}

final class PatientAccountProfileUpdateFailure
    extends PatientAccountProfileState {
  final String errorMessage;

  PatientAccountProfileUpdateFailure(this.errorMessage);
}

final class PatientAccountProfileImageUpdateLoading
    extends PatientAccountProfileState {}

final class PatientAccountProfileImageUpdateSuccess
    extends PatientAccountProfileState {
  final String message;

  PatientAccountProfileImageUpdateSuccess(this.message);
}

final class PatientAccountProfileImageUpdateFailure
    extends PatientAccountProfileState {
  final String errorMessage;

  PatientAccountProfileImageUpdateFailure(this.errorMessage);
}
