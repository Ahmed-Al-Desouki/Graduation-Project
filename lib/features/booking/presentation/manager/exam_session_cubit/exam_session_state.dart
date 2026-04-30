part of 'exam_session_cubit.dart';

@immutable
sealed class ExamSessionState {}

final class ExamSessionInitial extends ExamSessionState {}

class MedicalRecordLoading extends ExamSessionState {}

class MedicalRecordFetched extends ExamSessionState {
  final MedicalRecordEntity record;
  MedicalRecordFetched(this.record);
}

class MedicalRecordSavedSuccess extends ExamSessionState {
  final String message;
  MedicalRecordSavedSuccess(this.message);
}

class PrescriptionLoading extends ExamSessionState {}

class PrescriptionCreatedSuccess extends ExamSessionState {
  final String message;
  PrescriptionCreatedSuccess(this.message);
}

class PrescriptionFetchedSuccess extends ExamSessionState {
  final PrescriptionEntity prescription;
  PrescriptionFetchedSuccess(this.prescription);
}

class ExamSessionFailure extends ExamSessionState {
  final String errMessage;
  ExamSessionFailure(this.errMessage);
}

class AppointmentDetailsFetched extends ExamSessionState {
  final AppointmentFullDetailsEntity details;
  AppointmentDetailsFetched(this.details);
}
