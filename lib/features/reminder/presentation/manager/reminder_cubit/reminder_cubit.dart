// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graduation_project/features/auth/data/repo/reminder_repo.dart';
// import 'package:graduation_project/features/auth/presentation/manger/reminder_cubit/reminder_state.dart';
// import 'reminder_states.dart';

// class ReminderCubit extends Cubit<ReminderState> {
//   final ReminderRepository _repo;

//   ReminderCubit(this._repo) : super(ReminderInitial());

//   Future<void> createReminder(
//     String patientId, {
//     required String type,
//     required String name,
//     required String startDate,
//     required String endDate,
//     required String frequency,
//     required String intervalHours,
//     required String baseTime,
//     required String message,
//   }) async {
//     emit(ReminderLoading());

//     final result = await _repo.createReminder(
//       patientId,
//       type: type,
//       name: name,
//       startDate: startDate,
//       endDate: endDate,
//       frequency: frequency,
//       intervalHours: intervalHours,
//       baseTime: baseTime,
//       message: message,
//     );

//     result.fold(
//       (failure) => emit(ReminderError(failure.message)),
//       (reminder) => emit(ReminderCreated(reminder)),
//     );
//   }

//   Future<void> getUpcomingReminders(String patientId) async {
//     emit(ReminderLoading());

//     final res = await _repo.getUpcomingReminders(patientId);

//     res.fold(
//       (failure) => emit(ReminderError(failure.message)),
//       (instance) => emit(UpcomingRemindersLoaded(instance)),
//     );
//   }

//   Future<void> updateReminder(
//     String patientId,
//     String reminderId, {
//     required String name,
//     required String startDate,
//     required String endDate,
//     required String frequency,
//     required String intervalHours,
//     required String baseTime,
//     required String message,
//   }) async {
//     emit(ReminderLoading());

//     final res = await _repo.updateReminder(
//       patientId,
//       reminderId,
//       name: name,
//       startDate: startDate,
//       endDate: endDate,
//       frequency: frequency,
//       intervalHours: intervalHours,
//       baseTime: baseTime,
//       message: message,
//     );

//     res.fold(
//       (failure) => emit(ReminderError(failure.message)),
//       (reminder) => emit(ReminderUpdated(reminder)),
//     );
//   }
// }
// ---------------------------------------------------------------------
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:meta/meta.dart';
// import '../../../data/repo/reminder_repo.dart';

// part 'reminder_state.dart';

// class ReminderCubit extends Cubit<ReminderState> {
//   final ReminderRepository repo;

//   ReminderCubit(this.repo) : super(ReminderInitial());

//   Future<void> addReminder(String patientId, Map<String, dynamic> data) async {
//     emit(ReminderLoading());

//     final result = await repo.createReminder(patientId, data);

//     result.fold(
//       (failure) => emit(ReminderFailure(failure.errmessage)),
//       (_) => loadUpcoming(patientId),
//     );
//   }

//   Future<void> loadUpcoming(String patientId) async {
//     emit(ReminderLoading());

//     final result = await repo.getUpcoming(patientId);

//     result.fold(
//       (failure) => emit(ReminderFailure(failure.errmessage)),
//       (reminders) => emit(ReminderLoaded(reminders)),
//     );
//   }
// }
// lib/features/auth/presentation/manger/reminder_cubit/reminder_cubit.dart
// ----------------------------------------------------------------
// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:dartz/dartz.dart';

// import 'package:graduation_project/core/errors/failures.dart';
// import 'package:graduation_project/features/auth/data/models/reminder_model.dart';
// import 'package:graduation_project/features/auth/data/models/reminder_instance_model.dart';
// import 'package:graduation_project/features/auth/data/repo/reminder_repo.dart';

// part 'reminder_state.dart';

// class ReminderCubit extends Cubit<ReminderState> {
//   final ReminderRepository _repository;

//   ReminderCubit(this._repository) : super(ReminderInitial());

//   /// Create a new reminder on server
//   Future<void> createReminder({
//     required String patientId,
//     required String type,
//     required String name,
//     required String startDate, // ISO string expected by backend
//     required String endDate,
//     required String frequency,
//     required String intervalHours, // pass string if repo expects string
//     required String baseTime, // e.g. "08:00:00"
//     required String message,
//   }) async {
//     emit(ReminderLoading());

//     final Either<Failure, ReminderModel> result = await _repository.createReminder(
//       patientId: patientId,
//       type: type,
//       name: name,
//       startDate: startDate,
//       endDate: endDate,
//       frequency: frequency,
//       intervalHours: intervalHours,
//       baseTime: baseTime,
//       message: message,
//     );

//     result.fold(
//       (failure) => emit(ReminderError(failure.errmessage)),
//       (reminder) => emit(ReminderCreated(reminder)),
//     );
//   }

//   /// Fetch upcoming reminder instances for a patient (hours parameter optional / repo-dependent)
//   Future<void> getUpcomingReminders({
//     required String patientId,
//     int hours = 24,
//   }) async {
//     emit(ReminderLoading());

//     final Either<Failure, ReminderInstanceModel> result =
//         await _repository.getUpcomingReminders(patientId: patientId, hours: hours);

//     result.fold(
//       (failure) => emit(ReminderError(failure.errmessage)),
//       (instance) => emit(UpcomingRemindersLoaded(instance)),
//     );
//   }

//   /// Update an existing reminder
//   Future<void> updateReminder({
//     required String patientId,
//     required String reminderId,
//     required String name,
//     required String startDate,
//     required String endDate,
//     required String frequency,
//     required String intervalHours,
//     required String baseTime,
//     required String message,
//   }) async {
//     emit(ReminderLoading());

//     final Either<Failure, ReminderModel> result = await _repository.updateReminder(
//       patientId: patientId,
//       reminderId: reminderId,
//       name: name,
//       startDate: startDate,
//       endDate: endDate,
//       frequency: frequency,
//       intervalHours: intervalHours,
//       baseTime: baseTime,
//       message: message,
//     );

//     result.fold(
//       (failure) => emit(ReminderError(failure.errmessage)),
//       (reminder) => emit(ReminderUpdated(reminder)),
//     );
//   }
// }
// -----------------------------------------------------
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';
import 'package:graduation_project/features/reminder/data/repo/reminder_repo.dart';
import 'reminder_state.dart';

class ReminderCubit extends Cubit<ReminderState> {
  final ReminderRepository repo;

  ReminderCubit(this.repo) : super(ReminderInitial());

  Future<void> createReminder({
    required String patientId,
    required String type,
    required String title,
    required DateTime startDate,    // ← بقى DateTime
  required DateTime endDate,
    required String? rrule,
    required SimpleModel? simple,
    required String message,
  }) async {
    emit(ReminderLoading());

    final result = await repo.createReminder(
      patientId: patientId,
      type: type,
      title: title,
      startDate: startDate,
      endDate: endDate,
      rrule: rrule,
      simple: simple,
      message: message,
    );

    result.fold(
      (failure) {
    // طبّع الإيرور في الكونسول عشان نشوف إيه اللي بيحصل بالظبط
    print("CREATE REMINDER FAILED: ${failure.errmessage}");
    emit(ReminderCreateFailure(errMessage: failure.errmessage));
  },
      // (reminder) => emit(ReminderCreateSuccess(reminder: reminder)),
      (reminder) {
    // حتى لو الـ reminder ناقص بيانات، خلينا نعتبره ناجح
    emit(ReminderCreateSuccess(reminder: reminder));
    // نعيد تحميل التذكيرات اليومية عشان تظهر فورًا
    getTodayReminders(patientId: patientId);
  },
    );
  }

  // Future<void> getUpcomingReminders({
  //   required String patientId,
  //   required int hours,
  // }) async {
  //   emit(ReminderLoading());

  //   final result = await repo.getUpcomingReminders(
  //     patientId: patientId,
  //     hours: hours,
  //   );

  //   result.fold(
  //     (failure) => emit(UpcomingRemindersFailure(errMessage: failure.errmessage)),
  //     (allReminders) {
  //       final meds = allReminders
  //           .where((element) => element.type == 'Medication')
  //           .toList();
  //       final appts = allReminders
  //           .where((element) => element.type == 'Appointment')
  //           .toList();

  //       emit(UpcomingRemindersSuccess(
  //         medications: meds,
  //         appointments: appts,
  //       ));
  //     },
  //   );
  // }

  Future<void> getTodayReminders({
    required String patientId,
  }) async {
  emit(ReminderLoading());

  final result = await repo.getTodayReminders(patientId: patientId);

  result.fold(
    (failure) => emit(UpcomingRemindersFailure(errMessage: failure.errmessage)),
    (allReminders) {
      final meds = allReminders
            .where((element) => element.type == 'Medication')
            .toList();
      final appts = allReminders
            .where((element) => element.type == 'Appointment')
            .toList();
      final customs = allReminders
            .where((element) => element.type != 'Medication' && element.type != 'Appointment')
            .toList();
      emit(UpcomingRemindersSuccess(
        medications: meds,
        appointments: appts,
        customs: customs,
      ));
    },
  );
}

  Future<void> updateReminder({
    required String patientId,
    required String reminderId,
    required String name,
    required String startDate,
    required String endDate,
    required String frequency,
    required String intervalHours,
    required String baseTime,
    required String message,
  }) async {
    emit(ReminderLoading());

    final result = await repo.updateReminder(
      patientId: patientId,
      reminderId: reminderId,
      name: name,
      startDate: startDate,
      endDate: endDate,
      frequency: frequency,
      intervalHours: intervalHours,
      baseTime: baseTime,
      message: message,
    );

    result.fold(
      (failure) => emit(ReminderUpdateFailure(errMessage: failure.errmessage)),
      (reminder) => emit(ReminderUpdateSuccess(reminder: reminder)),
    );
  }

  Future<void> deleteReminder({
    required String reminderId,
  }) async {
    final patientId = await SecureStorageHelper.getUserId();
    if (patientId == null || patientId.isEmpty) {
      emit(ReminderDeleteFailure(errMessage: "User ID is missing or invalid."));
      return;
    }

    emit(ReminderDeleteLoading());
    
    final result = await repo.deleteReminder(
      patientId: patientId,
      reminderId: reminderId,
    );

    result.fold(
      (failure) => emit(ReminderDeleteFailure(errMessage: failure.errmessage)),
      (_) => emit(
        ReminderDeleteSuccess(
          message: 'Reminder deleted successfully',
        ),
      ),
    );
  }
}
