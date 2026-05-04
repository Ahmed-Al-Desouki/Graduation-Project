import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/booking/domain/use_cases/block_slot_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/book_follow_up_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/creat_chat_room_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_appointment_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_manual_slot_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_payment_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/delete_slot_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/restore_blocked_slots_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/update_appointment_status_use_case.dart';
import 'package:graduation_project/features/chat/domain/entities/chat_entity.dart';
import 'package:meta/meta.dart';

part 'appointment_action_state.dart';

class AppointmentActionCubit extends Cubit<AppointmentActionState> {
  final UpdateAppointmentStatusUseCase updateStatusUseCase;
  final CreateManualSlotUseCase createManualSlotUseCase;
  final BookFollowUpUseCase followUpUseCase;
  final DeleteSlotUseCase deleteSlotUseCase;
  final BlockSlotUseCase blockSlotUseCase;
  final CreatePaymentUseCase createPaymentUseCase;
  final CreateAppointmentUseCase createAppointmentUseCase;
  final CreateChatRoomUseCase createChatRoomUseCase;
  final RestoreBlockedSlotsUseCase restoreBlockedSlotsUseCase;

  AppointmentActionCubit(
    this.updateStatusUseCase,
    this.createManualSlotUseCase,
    this.followUpUseCase,
    this.deleteSlotUseCase,
    this.blockSlotUseCase,
    this.createPaymentUseCase,
    this.createAppointmentUseCase,
    this.createChatRoomUseCase,
    this.restoreBlockedSlotsUseCase,
  ) : super(AppointmentActionInitial());

  Future<void> restoreSlot(String slotId) async {
    emit(AppointmentActionLoading());
    final doctorId = getIt<SessionManager>().userId;

    final result = await restoreBlockedSlotsUseCase(doctorId, [slotId]);

    result.fold(
      (failure) => emit(AppointmentActionFailure(failure.errmessage)),
      (_) => emit(
        AppointmentActionSuccess(
          "The blocked slot has been restored successfully",
        ),
      ),
    );
  }

  Future<void> updateStatus(
    String id,
    AppointmentAction action, {
    String? reason,
  }) async {
    emit(AppointmentActionLoading());
    final result = await updateStatusUseCase(id, action);

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

  Future<void> doctorCancel(String appointmentId, String reason) async {
    emit(AppointmentActionLoading());

    final result = await updateStatusUseCase(
      appointmentId,
      AppointmentAction.doctorCancel,
      cancelReason: reason,
    );

    result.fold(
      (failure) => emit(AppointmentActionFailure(failure.errmessage)),
      (_) =>
          emit(AppointmentActionSuccess("the appointment has been canceled")),
    );
  }

  Future<void> patientCancel(String appointmentId, String reason) async {
    emit(AppointmentActionLoading());
    final result = await updateStatusUseCase(
      appointmentId,
      AppointmentAction.patientCancel,
      cancelReason: reason,
    );

    result.fold(
      (failure) => emit(AppointmentActionFailure(failure.errmessage)),
      (_) =>
          emit(AppointmentActionSuccess("the appointment has been canceled")),
    );
  }

  Future<void> addManualSlot({
    // required String doctorId,
    required DateTime date,
    required String start,
    required String end,
  }) async {
    emit(AppointmentActionLoading());
    final doctorId = getIt<SessionManager>().userId;
    final result = await createManualSlotUseCase(
      doctorId: doctorId,
      date: date,
      startTime: start,
      endTime: end,
    );

    result.fold(
      (failure) => emit(AppointmentActionFailure(failure.errmessage)),
      (_) => emit(
        AppointmentActionSuccess(
          "the slot has been added to the schedule successfully",
        ),
      ),
    );
  }

  Future<void> bookFollowUp({
    required String originalId,
    String? slotId,
    DateTime? newDate,
    String? startTime,
    int? duration,
    required String instructions,
  }) async {
    emit(AppointmentActionLoading());

    late Either<Failure, void> result;

    if (slotId != null) {
      result = await followUpUseCase.existingSlot(
        originalId: originalId,
        slotId: slotId,
        notes: "Follow-up for previous appointment",
        instructions: instructions,
      );
    } else {
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
      (_) => emit(
        AppointmentActionSuccess(
          "the follow-up appointment has been booked successfully",
        ),
      ),
    );
  }

  Future<void> deleteAvailableSlot(String slotId) async {
    emit(AppointmentActionLoading());
    final doctorId = getIt<SessionManager>().userId;

    final result = await deleteSlotUseCase(doctorId, slotId);

    result.fold(
      (failure) => emit(AppointmentActionFailure(failure.errmessage)),
      (_) => emit(
        AppointmentActionSuccess(
          "the appointment slot has been deleted successfully",
        ),
      ),
    );
  }

  Future<void> blockAvailableSlot(String slotId) async {
    emit(AppointmentActionLoading());
    final doctorId = getIt<SessionManager>().userId;

    final result = await blockSlotUseCase(doctorId, slotId);

    result.fold(
      (failure) => emit(AppointmentActionFailure(failure.errmessage)),
      (_) => emit(
        AppointmentActionSuccess(
          "the appointment slot has been blocked successfully",
        ),
      ),
    );
  }

  Future<void> bookAndPay({
    required String slotId,
    required String reason,
    required bool grantAccess,
    String paymentMethod = "Card",
  }) async {
    emit(AppointmentActionLoading());

    final result = await createAppointmentUseCase(
      slotId: slotId,
      reason: reason,
      grantAccess: grantAccess,
      paymentMethod: paymentMethod,
    );

    result.fold(
      (failure) => emit(AppointmentActionFailure(failure.errmessage)),
      (data) {
        log("Booking Response: $data");

        final String paymentUrl = data['paymentUrl'];
        emit(PaymentNavigatedToWebView(paymentUrl, bookingData: data));
      },
    );
  }

  Future<void> createFirebaseChat(ChatEntity chat) async {
    await createChatRoomUseCase(chat);
  }
}
