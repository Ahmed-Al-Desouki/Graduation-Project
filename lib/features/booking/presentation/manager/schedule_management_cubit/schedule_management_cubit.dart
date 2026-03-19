import 'package:bloc/bloc.dart';
import 'package:graduation_project/core/errors/failures.dart';
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

// class ScheduleManagementCubit extends Cubit<ScheduleManagementState> {
//   final CreateScheduleUseCase createScheduleUseCase;
//   final GenerateSlotsUseCase generateSlotsUseCase;
//   final GetActiveScheduleUseCase getActiveScheduleUseCase;

//   ScheduleManagementCubit(
//     this.createScheduleUseCase,
//     this.generateSlotsUseCase,
//     this.getActiveScheduleUseCase,
//   ) : super(ScheduleManagementInitial());

//   // Future<void> fetchCurrentSchedule() async {
//   //   emit(ScheduleManagementLoading());
//   //   final doctorId = getIt<SessionManager>().userId;
//   //   final result = await getActiveScheduleUseCase(doctorId);

//   //   result.fold((failure) {
//   //     // لو مفيش جدول أصلاً (أول مرة)، نرجعه للحالة الابتدائية عشان يملأ البيانات
//   //     if (failure is ServerFailure && failure.errmessage.contains("404")) {
//   //       emit(ScheduleManagementInitial());
//   //     } else {
//   //       emit(ScheduleManagementFailure(failure.errmessage));
//   //     }
//   //   }, (schedule) => emit(ScheduleFetchedSuccess(schedule)));
//   // }

//   // 1. جلب الجدول الحالي
//   Future<void> fetchCurrentSchedule() async {
//     emit(ScheduleManagementLoading());
//     final doctorId = getIt<SessionManager>().userId;
//     final result = await getActiveScheduleUseCase(doctorId);

//     result.fold((failure) {
//       // لو 404 يعني الدكتور لسه معندوش جدول، نرجعه للـ Initial عشان يبدأ يملأه
//       if (failure.errmessage.contains("404")) {
//         emit(ScheduleManagementInitial());
//       } else {
//         emit(ScheduleManagementFailure(failure.errmessage));
//       }
//     }, (schedule) => emit(ScheduleFetchedSuccess(schedule)));
//   }

//   // Future<void> saveDoctorSchedule({required ScheduleEntity schedule}) async {
//   //   emit(ScheduleManagementLoading());

//   //   final result = await createScheduleUseCase(schedule);

//   //   result.fold(
//   //     (failure) => emit(ScheduleManagementFailure(failure.errmessage)),
//   //     (scheduleId) {
//   //       emit(ScheduleCreatedSuccess(scheduleId));
//   //       // اختيارياً: يمكننا البدء في الـ Generate تلقائياً هنا
//   //     },
//   //   );
//   // }

//   // Future<void> saveDoctorSchedule({required ScheduleEntity schedule}) async {
//   //   emit(ScheduleManagementLoading());

//   //   final String currentUserId = getIt<SessionManager>().userId;

//   //   // 1. حفظ الجدول (Template)
//   //   final saveResult = await createScheduleUseCase(schedule);

//   //   await saveResult.fold(
//   //     (failure) async => emit(ScheduleManagementFailure(failure.errmessage)),
//   //     (scheduleId) async {
//   //       // 2. توليد المواعيد (Generate Slots)
//   //       final generateResult = await generateSlotsUseCase(
//   //         doctorId: currentUserId,
//   //         start: schedule.effectiveFromDate,
//   //         end: schedule.effectiveToDate,
//   //         regenerate: true,
//   //       );

//   //       generateResult.fold(
//   //         (failure) => emit(
//   //           ScheduleManagementFailure(
//   //             "Schedule saved, but failed to generate slots.",
//   //           ),
//   //         ),
//   //         (_) async {
//   //           // ✅ الحركة السحرية هنا:booking_box
//   //           // تحديث الـ Flag في Hive عشان الراوتر المرة الجاية يفتح الكالندر
//   //           var box = Hive.box('booking_box');
//   //           await box.put('isScheduleConfigured', true);

//   //           // إرسال حالة النجاح النهائية
//   //           emit(
//   //             SlotsGeneratedSuccess(
//   //               "Your schedule has been set up successfully!",
//   //             ),
//   //           );
//   //         },
//   //       );
//   //     },
//   //   );
//   // }

//   Future<void> saveDoctorSchedule({required ScheduleEntity schedule}) async {
//     emit(ScheduleManagementLoading());
//     final String currentUserId = getIt<SessionManager>().userId;

//     bool allDaysSaved = true;
//     String? lastErrorMessage;

//     // 🔄 الـ Loop السحري: هنبعت كل يوم لوحده للسيرفر (نظام v2.0)
//     for (var range in schedule.timeRanges) {
//       // بنعمل Entity وهمية لكل يوم عشان الـ UseCase والـ Repo يبعتوا الـ PUT صح
//       final dayConfig = ScheduleEntity(
//         id: schedule.id,
//         templateName: schedule.templateName,
//         slotDurationMinutes: schedule.slotDurationMinutes,
//         bufferTimeMinutes: schedule.bufferTimeMinutes,
//         effectiveFromDate: schedule.effectiveFromDate,
//         effectiveToDate: schedule.effectiveToDate,
//         timeRanges: [range], // بنبعت الـ Range بتاع اليوم ده بس
//       );

//       final result = await createScheduleUseCase(dayConfig);

//       result.fold(
//         (failure) {
//           allDaysSaved = false;
//           lastErrorMessage =
//               "Error saving day ${range.dayOfWeek}: ${failure.errmessage}";
//         },
//         (_) => null, // نجاح اليوم ده، كمل للي بعده
//       );

//       if (!allDaysSaved) break; // لو يوم فشل، وقف ومتبعتش الباقي
//     }

//     // لو فيه يوم وقع، اظهر إيرور ووقف
//     if (!allDaysSaved) {
//       emit(
//         ScheduleManagementFailure(lastErrorMessage ?? "Error saving schedule"),
//       );
//       return;
//     }

//     // 3. لو كل الأيام اتسيفت صح، نطلب الـ Generate Slots للمدة كلها
//     final generateResult = await generateSlotsUseCase(
//       doctorId: currentUserId,
//       start: schedule.effectiveFromDate,
//       end: schedule.effectiveToDate,
//       regenerate: true, // عشان يمسح القديم ويحط التعديل الجديد
//     );

//     generateResult.fold(
//       (failure) => emit(
//         ScheduleManagementFailure(
//           "Schedule saved, but failed to generate slots.",
//         ),
//       ),
//       (_) async {
//         // ✅ تحديث الـ Flag في Hive عشان الراوتر يفتح الكالندر المرة الجاية
//         var box = Hive.box('booking_box');
//         await box.put('isScheduleConfigured', true);

//         emit(
//           SlotsGeneratedSuccess("Your schedule has been set up successfully!"),
//         );
//       },
//     );
//   }

//   // // 2. وظيفة توليد المواعيد (Generate Slots)
//   // Future<void> generateDoctorSlots({
//   //   required String doctorId,
//   //   required DateTime startDate,
//   //   required DateTime endDate,
//   // }) async {
//   //   emit(ScheduleManagementLoading());

//   //   final result = await generateSlotsUseCase(
//   //     doctorId: doctorId,
//   //     start: startDate,
//   //     end: endDate,
//   //     regenerate: true, // لضمان تحديث أي مواعيد قديمة
//   //   );

//   //   result.fold(
//   //     (failure) => emit(ScheduleManagementFailure(failure.errmessage)),
//   //     (_) => emit(SlotsGeneratedSuccess("تم توليد مواعيدك بنجاح!")),
//   //   );
//   // }
// }

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

  // 1. جلب الجدول الحالي
  Future<void> fetchCurrentSchedule() async {
    emit(ScheduleManagementLoading());
    final doctorId = getIt<SessionManager>().userId;
    final result = await getActiveScheduleUseCase(doctorId);

    result.fold(
      (failure) =>
          failure.errmessage.contains("404")
              ? emit(ScheduleManagementInitial())
              : emit(ScheduleManagementFailure(failure.errmessage)),
      (schedule) => emit(ScheduleFetchedSuccess(schedule)),
    );
  }

  // 2. حفظ الجدول (يوم بيوم) وتوليد المواعيد
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
        emit(SlotsGeneratedSuccess("Schedule updated successfully!"));
      },
    );
  }

  // 3. حذف يوم عمل نهائياً
  Future<void> deleteDayConfig(int dayOfWeek) async {
    emit(ScheduleManagementLoading());
    final doctorId = getIt<SessionManager>().userId;
    final res = await removeWorkingDayUseCase(doctorId, dayOfWeek);
    res.fold(
      (f) => emit(ScheduleManagementFailure(f.errmessage)),
      (_) => fetchCurrentSchedule(),
    );
  }

  // 4. إضافة إجازة (Day Off)
  Future<void> setDayOff(DateTime date, String reason) async {
    emit(ScheduleManagementLoading());
    final doctorId = getIt<SessionManager>().userId;
    final res = await addDayOffUseCase(doctorId, date, reason);
    res.fold(
      (f) => emit(ScheduleManagementFailure(f.errmessage)),
      (_) => emit(SlotsGeneratedSuccess("Day off added")),
    );
  }

  // 5. إضافة ساعات مخصصة (Custom Hours)
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

  // 6. مسح استثناء (إلغاء إجازة مثلاً)
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
