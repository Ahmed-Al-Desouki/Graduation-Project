import 'package:graduation_project/features/doctor_profile/domain/entities/profile_image_entity.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/public_doctor_profile_entity.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/slot_config_entity.dart';
import 'package:meta/meta.dart';
import '../../domain/entities/doctor_profile_entity.dart';

@immutable
sealed class DoctorRealProfileState {}

final class DoctorProfileInitial extends DoctorRealProfileState {}

final class DoctorProfileLoading extends DoctorRealProfileState {}

final class DoctorProfileSuccess extends DoctorRealProfileState {
  final DoctorProfileEntity profile;
  DoctorProfileSuccess(this.profile);
}

final class DoctorProfileFailure extends DoctorRealProfileState {
  final String errorMessage;
  DoctorProfileFailure(this.errorMessage);
}

final class UpdateBasicInfoLoading extends DoctorRealProfileState {}

final class UpdateBasicInfoSuccess extends DoctorRealProfileState {}

final class UpdateBasicInfoFailure extends DoctorRealProfileState {
  final String errorMessage;
  UpdateBasicInfoFailure(this.errorMessage);
}

final class UpdateRealLocationLoading extends DoctorRealProfileState {}

final class UpdateRealLocationSuccess extends DoctorRealProfileState {}

final class UpdateRealLocationFailure extends DoctorRealProfileState {
  final String errorMessage;
  UpdateRealLocationFailure(this.errorMessage);
}

final class ReplaceVerificationDocumentLoading extends DoctorRealProfileState {}

final class ReplaceVerificationDocumentSuccess extends DoctorRealProfileState {}

final class ReplaceVerificationDocumentFailure extends DoctorRealProfileState {
  final String errorMessage;
  ReplaceVerificationDocumentFailure(this.errorMessage);
}

final class UpdateAchievementLoading extends DoctorRealProfileState {}

final class UpdateAchievementSuccess extends DoctorRealProfileState {}

final class UpdateAchievementFailure extends DoctorRealProfileState {
  final String errorMessage;
  UpdateAchievementFailure(this.errorMessage);
}

final class DeleteAchievementLoading extends DoctorRealProfileState {}

final class DeleteAchievementSuccess extends DoctorRealProfileState {}

final class DeleteAchievementFailure extends DoctorRealProfileState {
  final String errorMessage;
  DeleteAchievementFailure(this.errorMessage);
}

final class UpdateProfileImageLoading extends DoctorRealProfileState {}

final class UpdateProfileImageSuccess extends DoctorRealProfileState {
  final ProfileImageEntity profileImage;
  UpdateProfileImageSuccess(this.profileImage);
}

final class UpdateProfileImageFailure extends DoctorRealProfileState {
  final String errorMessage;
  UpdateProfileImageFailure(this.errorMessage);
}

final class GetSlotConfigLoading extends DoctorRealProfileState {}

final class GetSlotConfigSuccess extends DoctorRealProfileState {
  final List<SlotConfigEntity> slotConfigs;
  GetSlotConfigSuccess(this.slotConfigs);
}

final class GetSlotConfigFailure extends DoctorRealProfileState {
  final String errorMessage;
  GetSlotConfigFailure(this.errorMessage);
}

final class PublicDoctorProfileSuccess extends DoctorRealProfileState {
  final PublicDoctorProfileEntity profile;
  PublicDoctorProfileSuccess(this.profile);
}
