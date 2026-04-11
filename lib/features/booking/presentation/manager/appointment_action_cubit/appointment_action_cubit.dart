import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/booking/domain/entities/booking_entity.dart';
import 'package:graduation_project/features/booking/domain/use_cases/block_slot_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/book_follow_up_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_appointment_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_manual_slot_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/create_payment_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/delete_slot_use_case.dart';
import 'package:graduation_project/features/booking/domain/use_cases/update_appointment_status_use_case.dart';
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

  AppointmentActionCubit(
    this.updateStatusUseCase,
    this.createManualSlotUseCase,
    this.followUpUseCase,
    this.deleteSlotUseCase,
    this.blockSlotUseCase,
    this.createPaymentUseCase,
    this.createAppointmentUseCase,
  ) : super(AppointmentActionInitial());

  // 1. تغيير حالة الموعد (Confirm, Start, Complete, Cancel)
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

  // 2. كنسلة الطبيب (Cancel & Block) - الـ Logic الجديد
  Future<void> doctorCancel(String appointmentId, String reason) async {
    emit(AppointmentActionLoading());
    // نمرر الـ doctorCancel من الـ Enum اللي عدلناه في الـ UseCase
    final result = await updateStatusUseCase(
      appointmentId,
      AppointmentAction.doctorCancel,
      cancelReason: reason,
    );

    result.fold(
      (failure) => emit(AppointmentActionFailure(failure.errmessage)),
      (_) => emit(AppointmentActionSuccess("تم إلغاء الموعد وحظر الوقت بنجاح")),
    );
  }

  // 3. كنسلة المريض (Cancel & Available)
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
          emit(AppointmentActionSuccess("تم إلغاء الموعد وإعادة إتاحة الوقت")),
    );
  }

  // 2. إضافة موعد يدوي (Manual Slot) خارج الجدول
  Future<void> addManualSlot({
    // required String doctorId,
    required DateTime date,
    required String start,
    required String end,
  }) async {
    emit(AppointmentActionLoading());
    final doctorId = getIt<SessionManager>().userId; // ✅ سحب الـ ID أوتوماتيك
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

  Future<void> deleteAvailableSlot(String slotId) async {
    emit(AppointmentActionLoading());
    final doctorId = getIt<SessionManager>().userId; // بنجيب الـ ID من الكاش

    final result = await deleteSlotUseCase(doctorId, slotId);

    result.fold(
      (failure) => emit(AppointmentActionFailure(failure.errmessage)),
      (_) => emit(AppointmentActionSuccess("تم حذف الموعد من الجدول نهائياً")),
    );
  }

  // --- 2. ميثود الحظر (للسلوت المتاح) ---
  Future<void> blockAvailableSlot(String slotId) async {
    emit(AppointmentActionLoading());
    final doctorId = getIt<SessionManager>().userId;

    final result = await blockSlotUseCase(doctorId, slotId);

    result.fold(
      (failure) => emit(AppointmentActionFailure(failure.errmessage)),
      (_) => emit(AppointmentActionSuccess("تم حظر هذا الوقت بنجاح")),
    );
  }

  // ميثود حجز المريض (الدفع)
  // Future<void> processPayment(String appointmentId) async {
  //   emit(AppointmentActionLoading());

  //   final result = await createPaymentUseCase(
  //     appointmentId: appointmentId,
  //     method: "Card", // الباك مستنيها سترينج كدة
  //   );

  //   result.fold(
  //     (failure) => emit(AppointmentActionFailure(failure.errmessage)),
  //     (paymentResponse) => emit(
  //       PaymentNavigatedToWebView(
  //         paymentResponse.paymentUrl,
  //       ), // ✅ ستيت جديدة تفتح الويب فيو
  //     ),
  //   );
  // }

  // داخل AppointmentActionCubit
  // Future<void> createBookingAndPay({
  //   required String slotId,
  //   required String reason,
  //   bool grantAccess = true, // ✅ نمرر الاختيار من الـ UI
  // }) async {
  //   emit(AppointmentActionLoading());

  //   final bookingResult = await createAppointmentUseCase(
  //     slotId: slotId,
  //     reason: reason,
  //     grantAccess: grantAccess, // ✅ نمرر القيمة اللي المستخدم اختارها
  //   );

  //   bookingResult.fold(
  //     (failure) => emit(AppointmentActionFailure(failure.errmessage)),
  //     (appointmentId) async {
  //       // بعد ما الـ ID رجع، نطلب الدفع
  //       processPayment(appointmentId);
  //     },
  //   );
  // }

  // داخل AppointmentActionCubit

  Future<void> bookAndPay({
    required String slotId,
    required String reason,
    required bool grantAccess,
    String paymentMethod = "Card", // القيمة الافتراضية
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
        // سحب الـ URL من الرد اللي راجع
        final String paymentUrl = data['paymentUrl'];
        emit(
          PaymentNavigatedToWebView(paymentUrl, bookingData: data),
        ); // نفتح الـ WebView فوراً
      },
    );
  }
}
