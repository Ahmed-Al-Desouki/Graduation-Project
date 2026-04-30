import 'package:bloc/bloc.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/booking/domain/entities/schedule_entity.dart';
import 'package:graduation_project/features/booking/domain/use_cases/add_custom_hours_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/add_day_off_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_schedule_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/generate_slots_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_active_schedule_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/remove_exception_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/remove_working_day_use_case.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'schedule_management_state.dart';

class ScheduleManagementCubit extends Cubit<ScheduleManagementState> {
  final CreateScheduleUseCase createScheduleUseCase;
  final GenerateSlotsUseCase generateSlotsUseCase;
  final GetActiveScheduleUseCase getActiveScheduleUseCase;
  final RemoveWorkingDayUseCase removeWorkingDayUseCase;
  final AddDayOffUseCase addDayOffUseCase;
  final AddCustomHoursUseCase addCustomHoursUseCase;
  final RemoveExceptionUseCase removeExceptionUseCase;

  ScheduleManagementCubit(
    this.createScheduleUseCase,
    this.generateSlotsUseCase,
    this.getActiveScheduleUseCase,
    this.removeWorkingDayUseCase,
    this.addDayOffUseCase,
    this.addCustomHoursUseCase,
    this.removeExceptionUseCase,
  ) : super(ScheduleManagementInitial());

  // Future<void> fetchCurrentSchedule() async {
  //   emit(ScheduleManagementLoading());
  //   final doctorId = getIt<SessionManager>().userId;
  //   final result = await getActiveScheduleUseCase(doctorId);

  //   result.fold(
  //     (failure) =>
  //         failure.errmessage.contains("404")
  //             ? emit(ScheduleManagementInitial())
  //             : emit(ScheduleManagementFailure(failure.errmessage)),
  //     (schedule) async {
  //       // await Hive.box('booking_box').put('isScheduleConfigured', true);
  //       // emit(ScheduleFetchedSuccess(schedule));
  //       if (schedule.timeRanges.isEmpty) {
  //         emit(ScheduleManagementInitial());
  //       } else {
  //         await Hive.box('booking_box').put('isScheduleConfigured', true);

  //         emit(ScheduleFetchedSuccess(schedule));
  //       }
  //     },
  //   );
  // }

  Future<void> fetchCurrentSchedule() async {
    emit(ScheduleManagementLoading());
    final doctorId = getIt<SessionManager>().userId;
    final result = await getActiveScheduleUseCase(doctorId);

    result.fold(
      (failure) {
        if (failure.errmessage.contains("404")) {
          emit(ScheduleManagementInitial());
        } else {
          emit(ScheduleManagementFailure(failure.errmessage));
        }
      },
      (schedule) {
        if (schedule.timeRanges.isEmpty) {
          emit(ScheduleManagementInitial());
        } else {
          emit(ScheduleFetchedSuccess(schedule));
        }
      },
    );
  }

  Future<void> saveDoctorSchedule({required ScheduleEntity schedule}) async {
    emit(ScheduleManagementLoading());
    final String currentUserId = getIt<SessionManager>().userId;
    bool allSaved = true;
    String? error;

    for (var range in schedule.timeRanges) {
      final dayConfig = ScheduleEntity(
        id: schedule.id,
        templateName: schedule.templateName,
        slotDurationMinutes: schedule.slotDurationMinutes,
        bufferTimeMinutes: schedule.bufferTimeMinutes,
        effectiveFromDate: schedule.effectiveFromDate,
        effectiveToDate: schedule.effectiveToDate,
        timeRanges: [range],
      );
      final res = await createScheduleUseCase(dayConfig);
      res.fold((f) {
        allSaved = false;
        error = f.errmessage;
      }, (_) => null);
      if (!allSaved) break;
    }

    if (!allSaved) {
      emit(ScheduleManagementFailure(error!));
      return;
    }

    final genRes = await generateSlotsUseCase(
      doctorId: currentUserId,
      start: schedule.effectiveFromDate,
      end: schedule.effectiveToDate,
      regenerate: true,
    );

    genRes.fold(
      (f) => emit(ScheduleManagementFailure("Saved, but generation failed")),
      (_) async {
        await Hive.box('booking_box').put('isScheduleConfigured', true);
        //
        // await fetchCurrentSchedule();
        emit(SlotsGeneratedSuccess("Schedule updated successfully!"));
      },
    );
  }

  Future<void> deleteDayConfig(int dayOfWeek) async {
    emit(ScheduleManagementLoading());
    final doctorId = getIt<SessionManager>().userId;
    final res = await removeWorkingDayUseCase(doctorId, dayOfWeek);
    res.fold(
      (f) => emit(ScheduleManagementFailure(f.errmessage)),
      // (_) => fetchCurrentSchedule(),
      (_) => null,
    );
  }

  Future<void> setDayOff(DateTime date, String reason) async {
    emit(ScheduleManagementLoading());
    final doctorId = getIt<SessionManager>().userId;
    final res = await addDayOffUseCase(doctorId, date, reason);
    res.fold(
      (f) => emit(ScheduleManagementFailure(f.errmessage)),
      (_) => emit(SlotsGeneratedSuccess("Day off added")),
    );
  }

  Future<void> setCustomHours(
    DateTime date,
    String start,
    String end,
    String reason,
  ) async {
    emit(ScheduleManagementLoading());
    final doctorId = getIt<SessionManager>().userId;
    final res = await addCustomHoursUseCase(doctorId, date, start, end, reason);
    res.fold(
      (f) => emit(ScheduleManagementFailure(f.errmessage)),
      (_) => emit(SlotsGeneratedSuccess("Custom hours applied")),
    );
  }

  Future<void> clearException(DateTime date) async {
    emit(ScheduleManagementLoading());
    final doctorId = getIt<SessionManager>().userId;
    final res = await removeExceptionUseCase(doctorId, date);
    res.fold(
      (f) => emit(ScheduleManagementFailure(f.errmessage)),
      (_) => emit(SlotsGeneratedSuccess("Exception removed")),
    );
  }
}
