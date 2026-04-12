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
