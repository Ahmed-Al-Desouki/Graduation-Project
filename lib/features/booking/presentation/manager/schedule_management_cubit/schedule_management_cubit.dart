import 'package:bloc/bloc.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/booking/domain/entities/schedule_entity.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_schedule_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/generate_slots_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/get_active_schedule_use_case.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'schedule_management_state.dart';

class ScheduleManagementCubit extends Cubit<ScheduleManagementState> {
  final CreateScheduleUseCase createScheduleUseCase;
  final GenerateSlotsUseCase generateSlotsUseCase;
  final GetActiveScheduleUseCase getActiveScheduleUseCase;

  ScheduleManagementCubit(
    this.createScheduleUseCase,
    this.generateSlotsUseCase,
    this.getActiveScheduleUseCase,
  ) : super(ScheduleManagementInitial());

  Future<void> fetchCurrentSchedule(String doctorId) async {
    emit(ScheduleManagementLoading());
    final result = await getActiveScheduleUseCase(doctorId);

    result.fold((failure) {
      // لو مفيش جدول أصلاً (أول مرة)، نرجعه للحالة الابتدائية عشان يملأ البيانات
      if (failure is ServerFailure && failure.errmessage.contains("404")) {
        emit(ScheduleManagementInitial());
      } else {
        emit(ScheduleManagementFailure(failure.errmessage));
      }
    }, (schedule) => emit(ScheduleFetchedSuccess(schedule)));
  }

  // Future<void> saveDoctorSchedule({required ScheduleEntity schedule}) async {
  //   emit(ScheduleManagementLoading());

  //   final result = await createScheduleUseCase(schedule);

  //   result.fold(
  //     (failure) => emit(ScheduleManagementFailure(failure.errmessage)),
  //     (scheduleId) {
  //       emit(ScheduleCreatedSuccess(scheduleId));
  //       // اختيارياً: يمكننا البدء في الـ Generate تلقائياً هنا
  //     },
  //   );
  // }

  Future<void> saveDoctorSchedule({required ScheduleEntity schedule}) async {
    emit(ScheduleManagementLoading());

    final String currentUserId = getIt<SessionManager>().userId;

    // 1. حفظ الجدول (Template)
    final saveResult = await createScheduleUseCase(schedule);

    await saveResult.fold(
      (failure) async => emit(ScheduleManagementFailure(failure.errmessage)),
      (scheduleId) async {
        // 2. توليد المواعيد (Generate Slots)
        final generateResult = await generateSlotsUseCase(
          doctorId: currentUserId,
          start: schedule.effectiveFromDate,
          end: schedule.effectiveToDate,
          regenerate: true,
        );

        generateResult.fold(
          (failure) => emit(
            ScheduleManagementFailure(
              "Schedule saved, but failed to generate slots.",
            ),
          ),
          (_) async {
            // ✅ الحركة السحرية هنا:booking_box
            // تحديث الـ Flag في Hive عشان الراوتر المرة الجاية يفتح الكالندر
            var box = Hive.box('booking_box');
            await box.put('isScheduleConfigured', true);

            // إرسال حالة النجاح النهائية
            emit(
              SlotsGeneratedSuccess(
                "Your schedule has been set up successfully!",
              ),
            );
          },
        );
      },
    );
  }

  // // 2. وظيفة توليد المواعيد (Generate Slots)
  // Future<void> generateDoctorSlots({
  //   required String doctorId,
  //   required DateTime startDate,
  //   required DateTime endDate,
  // }) async {
  //   emit(ScheduleManagementLoading());

  //   final result = await generateSlotsUseCase(
  //     doctorId: doctorId,
  //     start: startDate,
  //     end: endDate,
  //     regenerate: true, // لضمان تحديث أي مواعيد قديمة
  //   );

  //   result.fold(
  //     (failure) => emit(ScheduleManagementFailure(failure.errmessage)),
  //     (_) => emit(SlotsGeneratedSuccess("تم توليد مواعيدك بنجاح!")),
  //   );
  // }
}
