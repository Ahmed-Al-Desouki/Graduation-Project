import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_instance_model.dart';
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
    required DateTime startDate,
    required DateTime? endDate,
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
        print("CREATE REMINDER FAILED: ${failure.errmessage}");
        emit(ReminderCreateFailure(errMessage: failure.errmessage));
      },
      (reminder) async {
        emit(ReminderCreateSuccess(reminder: reminder));
        await getUpcomingReminders(patientId: patientId);
      },
    );
  }

  Future<void> getTodayReminders({required String patientId}) async {
    if (isClosed) return;
    emit(ReminderLoading());

    final localData = await repo.getTodayReminders(patientId: patientId);
    localData.fold((failure) {}, (allReminders) => _emitSuccess(allReminders));
    await getUpcomingReminders(patientId: patientId);
  }

  void _emitSuccess(List<ReminderInstanceModel> allReminders) {
    if (isClosed) return;
    final meds = allReminders.where((e) => e.type == 'Medication').toList();
    final appts = allReminders.where((e) => e.type == 'Appointment').toList();
    final customs =
        allReminders
            .where((e) => e.type != 'Medication' && e.type != 'Appointment')
            .toList();

    emit(
      UpcomingRemindersSuccess(
        medications: meds,
        appointments: appts,
        customs: customs,
      ),
    );
  }

  Future<void> getAllReminders({required String patientId}) async {
    emit(GetAllRemindersLoading());

    final result = await repo.getAllReminders(patientId: patientId);

    result.fold(
      (failure) => emit(GetAllRemindersFailure(errMessage: failure.errmessage)),
      (reminders) => emit(GetAllRemindersSuccess(reminders: reminders)),
    );
  }

  Future<void> updateReminder({
    required String patientId,
    required String reminderId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    String? rrule,
    SimpleModel? simple,
    required String message,
    required bool isEveryXHours,
  }) async {
    emit(ReminderLoading());

    final result = await repo.updateReminder(
      patientId: patientId,
      reminderId: reminderId,
      title: title,
      startDate: startDate,
      endDate: endDate,
      rrule: rrule,
      simple: simple,
      message: message,
      isSimpleEveryXHours: isEveryXHours,
    );

    result.fold(
      (failure) => emit(ReminderUpdateFailure(errMessage: failure.errmessage)),
      (reminder) async {
        emit(ReminderUpdateSuccess(reminder: reminder));
        await getAllReminders(patientId: patientId);
      },
    );
  }

  Future<void> deleteReminder({
    required String reminderId,
    required String patientId,
  }) async {
    emit(ReminderDeleteLoading());

    final result = await repo.deleteReminder(
      patientId: patientId,
      reminderId: reminderId,
    );

    result.fold(
      (failure) => emit(ReminderDeleteFailure(errMessage: failure.errmessage)),
      (_) =>
          emit(ReminderDeleteSuccess(message: 'Reminder deleted successfully')),
    );
  }

  Future<void> getUpcomingReminders({required String patientId}) async {
    final result = await repo.getUpcomingReminders(
      patientId: patientId,
      days: 14,
    );

    result.fold(
      (failure) =>
          print("❌ Failed to sync upcoming reminders: ${failure.errmessage}"),
      (instances) async {
        print("✅ Synced ${instances.length} reminders");
        final updatedData = await repo.getTodayReminders(patientId: patientId);
        updatedData.fold(
          (failure) => null,
          (allReminders) => _emitSuccess(allReminders),
        );
      },
    );
  }

  Future<void> syncOfflineActions() async {
    final result = await repo.syncOfflineActions();

    result.fold(
      (failure) {
        print("⚠️ Offline sync failed: ${failure.errmessage}");
      },
      (_) {
        print("✅ Offline actions processed successfully.");
      },
    );
  }
}
