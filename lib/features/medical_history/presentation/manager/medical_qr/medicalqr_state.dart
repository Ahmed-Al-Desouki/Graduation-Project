part of 'medicalqr_cubit.dart';

@immutable
sealed class MedicalqrState {}

final class MedicalqrInitial extends MedicalqrState {}

class MedicalQrLoading extends MedicalqrState {}

class MedicalQrSuccess extends MedicalqrState {
  final String qrCodeBase64;
  final String token;
  MedicalQrSuccess(this.qrCodeBase64, this.token);
}

class MedicalQrFailure extends MedicalqrState {
  final String errMessage;
  MedicalQrFailure(this.errMessage);
}

class SharedHistoryLoading extends MedicalqrState {}

class SharedHistorySuccess extends MedicalqrState {
  final PatientProfileModel profile;
  SharedHistorySuccess(this.profile);
}

class SharedHistoryFailure extends MedicalqrState {
  final String errMessage;
  SharedHistoryFailure(this.errMessage);
}
