import 'package:meta/meta.dart';

@immutable
sealed class DoctorProfileState {}

final class DoctorProfileInitial extends DoctorProfileState {}

// ✅ Complete Profile States
final class CompleteProfileLoading extends DoctorProfileState {}

final class CompleteProfileSuccess extends DoctorProfileState {}

final class CompleteProfileFailure extends DoctorProfileState {
  final String errorMessage;
  CompleteProfileFailure(this.errorMessage);
}

// ✅ Verification Document States
final class VerificationDocumentLoading extends DoctorProfileState {}

final class VerificationDocumentSuccess extends DoctorProfileState {}

final class VerificationDocumentFailure extends DoctorProfileState {
  final String errorMessage;
  VerificationDocumentFailure(this.errorMessage);
}

// ✅ Location States
final class UpdateLocationLoading extends DoctorProfileState {}

final class UpdateLocationSuccess extends DoctorProfileState {}

final class UpdateLocationFailure extends DoctorProfileState {
  final String errorMessage;
  UpdateLocationFailure(this.errorMessage);
}

// ✅ Achievement States
final class AddAchievementLoading extends DoctorProfileState {}

final class AddAchievementSuccess extends DoctorProfileState {}

final class AddAchievementFailure extends DoctorProfileState {
  final String errorMessage;
  AddAchievementFailure(this.errorMessage);
}

// ✅ Profile Status Check States (للـ Loading Screen)
final class ProfileStatusLoading extends DoctorProfileState {}

final class ProfileStatusSuccess extends DoctorProfileState {
  final bool isProfileCompleted;
  final bool isActive;
  ProfileStatusSuccess({
    required this.isProfileCompleted,
    required this.isActive,
  });
}

final class ProfileStatusFailure extends DoctorProfileState {
  final String errorMessage;
  ProfileStatusFailure(this.errorMessage);
}

// ✅ Admin Review States (للـ Loading Screen بعد الـ Submit)
final class AdminReviewLoading extends DoctorProfileState {}

final class AdminReviewApproved extends DoctorProfileState {}

final class AdminReviewRejected extends DoctorProfileState {
  final String errorMessage;
  AdminReviewRejected(this.errorMessage);
}
