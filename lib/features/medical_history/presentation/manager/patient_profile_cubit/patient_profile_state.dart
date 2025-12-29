part of 'patient_profile_cubit.dart';

@immutable
sealed class PatientProfileState {}

final class PatientProfileInitial extends PatientProfileState {}

final class PatientProfileLoading extends PatientProfileState {}

final class PatientProfileSuccess extends PatientProfileState {
  final PatientProfileModel profile;
  PatientProfileSuccess({required this.profile});
}

final class PatientProfileFailure extends PatientProfileState {
  final String errMessage;
  PatientProfileFailure({required this.errMessage});
}

final class PatientUpdateLoading extends PatientProfileState {}

final class PatientUpdateSuccess extends PatientProfileState {
  final String message;
  PatientUpdateSuccess({required this.message});
}

final class PatientUpdateFailure extends PatientProfileState {
  final String errMessage;
  PatientUpdateFailure({required this.errMessage});
}

final class PatientUploadLoading extends PatientProfileState {}

final class PatientUploadSuccess extends PatientProfileState {
  final String message;
  PatientUploadSuccess({required this.message});
}

final class PatientUploadFailure extends PatientProfileState {
  final String errMessage;
  PatientUploadFailure({required this.errMessage});
}

final class PatientDeleteSuccess extends PatientProfileState {
  final String message;
  PatientDeleteSuccess({required this.message});
}

final class PatientDeleteFailure extends PatientProfileState {
  final String errMessage;
  PatientDeleteFailure({required this.errMessage});
}

final class PatientOperationLoading extends PatientProfileState {}

final class PatientOperationSuccess extends PatientProfileState {
  final String message;
  PatientOperationSuccess({required this.message});
}

final class PatientOperationFailure extends PatientProfileState {
  final String errMessage;
  PatientOperationFailure({required this.errMessage});
}
