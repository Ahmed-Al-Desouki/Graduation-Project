import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/use_cases/book_follow_up_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_manual_slot_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/update_appointment_status_use_case.dart';
import 'package:meta/meta.dart';

part 'appointment_action_state.dart';

class AppointmentActionCubit extends Cubit<AppointmentActionState> {
  final UpdateAppointmentStatusUseCase updateStatusUseCase;
  final CreateManualSlotUseCase createManualSlotUseCase;
  final BookFollowUpUseCase followUpUseCase;
  AppointmentActionCubit(
    this.updateStatusUseCase,
    this.createManualSlotUseCase,
    this.followUpUseCase,
  ) : super(AppointmentActionInitial());

  // 1. تغيير حالة الموعد (Confirm, Start, Complete, Cancel)
  Future<void> updateStatus(
    String id,
    AppointmentAction action, {
    String? reason,
  }) async {
    emit(AppointmentActionLoading());
    final result = await updateStatusUseCase(id, action, cancelReason: reason);

    result.fold(
      (failure) => emit(AppointmentActionFailure(failure.errmessage)),
      (_) => emit(
        AppointmentActionSuccess(
          "تم تحديث حالة الموعد بنجاح",
          actionType: action.name,
        ),
      ),
    );
  }

  // 2. إضافة موعد يدوي (Manual Slot) خارج الجدول
  Future<void> addManualSlot({
    required String doctorId,
    required DateTime date,
    required String start,
    required String end,
  }) async {
    emit(AppointmentActionLoading());
    final result = await createManualSlotUseCase(
      doctorId: doctorId,
      date: date,
      startTime: start,
      endTime: end,
    );

    result.fold(
      (failure) => emit(AppointmentActionFailure(failure.errmessage)),
      (_) => emit(AppointmentActionSuccess("تم إضافة الموعد اليدوي بنجاح")),
    );
  }

  // 3. حجز موعد متابعة
  Future<void> bookFollowUp({
    required String originalId,
    String? slotId, // لو هيختار ميعاد موجود
    DateTime? newDate, // لو هيحدد ميعاد جديد يدوي
    String? startTime,
    int? duration,
    required String instructions,
  }) async {
    emit(AppointmentActionLoading());

    late Either<Failure, void> result;

    if (slotId != null) {
      // حالة الـ Existing Slot
      result = await followUpUseCase.existingSlot(
        originalId: originalId,
        slotId: slotId,
        notes: "Follow-up for previous appointment",
        instructions: instructions,
      );
    } else {
      // حالة الـ New Custom Slot
      result = await followUpUseCase.newSlot(
        originalId: originalId,
        date: newDate!,
        startTime: startTime!,
        duration: duration ?? 30,
        notes: "Custom follow-up session",
        instructions: instructions,
      );
    }

    result.fold(
      (failure) => emit(AppointmentActionFailure(failure.errmessage)),
      (_) => emit(AppointmentActionSuccess("تم تحديد موعد المتابعة بنجاح")),
    );
  }
}
