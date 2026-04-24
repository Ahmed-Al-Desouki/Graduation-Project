import 'package:graduation_project/features/doctor_home/domain/entities/doctor_profile_status_entity.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/doctor_profile_entity.dart';
import 'package:meta/meta.dart';

@immutable
sealed class DoctorProfileState {}

final class DoctorProfileInitial extends DoctorProfileState {}

final class DoctorFlowLoading extends DoctorProfileState {}

final class DoctorFlowSuccess extends DoctorProfileState {
  final DoctorProfileStatusEntity status;

  DoctorFlowSuccess(this.status);
}

final class DoctorFlowFailure extends DoctorProfileState {
  final String errorMessage;

  DoctorFlowFailure(this.errorMessage);
}

final class DoctorProfileDataLoading extends DoctorProfileState {}

final class DoctorProfileDataSuccess extends DoctorProfileState {
  final DoctorProfileEntity profile;

  DoctorProfileDataSuccess(this.profile);
}

final class DoctorProfileDataFailure extends DoctorProfileState {
  final String errorMessage;

  DoctorProfileDataFailure(this.errorMessage);
}

final class ProfileSubmissionLoading extends DoctorProfileState {}

final class ProfileSubmissionSuccess extends DoctorProfileState {
  final DoctorProfileStatusEntity status;

  ProfileSubmissionSuccess(this.status);
}

final class ProfileSubmissionFailure extends DoctorProfileState {
  final String errorMessage;

  ProfileSubmissionFailure(this.errorMessage);
}
