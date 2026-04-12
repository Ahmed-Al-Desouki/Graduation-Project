import 'package:bloc/bloc.dart';
import 'package:graduation_project/features/doctor_profile/presentation/manager/doctor_real_profile_state.dart';
import '../../domain/entities/doctor_profile_entity.dart';
import '../../domain/use_cases/get_doctor_profile_use_case.dart';

class DoctorRealProfileCubit extends Cubit<DoctorRealProfileState> {
  final GetDoctorProfileUseCase getDoctorProfileUseCase;

  DoctorRealProfileCubit(this.getDoctorProfileUseCase)
    : super(DoctorProfileInitial());

  DoctorProfileEntity? _cachedProfile;

  DoctorProfileEntity? get cachedProfile => _cachedProfile;

  Future<void> getDoctorProfile() async {
    emit(DoctorProfileLoading());

    final result = await getDoctorProfileUseCase();

    result.fold((failure) => emit(DoctorProfileFailure(failure.errmessage)), (
      profile,
    ) {
      _cachedProfile = profile;
      emit(DoctorProfileSuccess(profile));
    });
  }
}
