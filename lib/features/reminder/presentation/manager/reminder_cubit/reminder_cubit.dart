import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
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
    required DateTime startDate, // ← بقى DateTime
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
      (reminder) async {
        // حتى لو الـ reminder ناقص بيانات، خلينا نعتبره ناجح
        emit(ReminderCreateSuccess(reminder: reminder));
        // نعيد تحميل التذكيرات اليومية عشان تظهر فورًا
        // getTodayReminders(patientId: patientId);
        // نطلب المزامنة فوراً (ده هيجيب الداتا ويجدول المنبه ويعرضه)
        await getUpcomingReminders(patientId: patientId);
      },
    );
  }

  // Future<void> getTodayReminders({required String patientId}) async {
  //   if (isClosed) return;
  //   emit(ReminderLoading());

  //   // 1. اسحب الداتا من الـ SQLite
  //   final result = await repo.getTodayReminders(patientId: patientId);

  //   if (isClosed) return;

  //   result.fold(
  //     (failure) =>
  //         emit(UpcomingRemindersFailure(errMessage: failure.errmessage)),
  //     (allReminders) {
  //       // ✅ الصح: نادي _emitSuccess دايماً حتى لو القائمة فاضية []
  //       // الـ UI هيستلم قائمة فاضية ويوقف الـ Loading ويعرض "No Reminders"
  //       _emitSuccess(allReminders);
  //     },
  //   );
  // }

  // دالة جلب اليوم (قراءة + تحديث خلفي)
  Future<void> getTodayReminders({required String patientId}) async {
    if (isClosed) return;
    emit(ReminderLoading());

    // 1. اعرض اللوكال فوراً (عشان المستخدم ميحسش ببطء)
    final localData = await repo.getTodayReminders(patientId: patientId);
    localData.fold((failure) {
      /* لا تفعل شيء، انتظر السيرفر */
    }, (allReminders) => _emitSuccess(allReminders));

    // 2. دلوقتي روح هات التحديثات من السيرفر (في الخلفية)
    // الدالة دي هي اللي هتحدث الـ SQLite وتجدول المنبهات
    await getUpcomingReminders(patientId: patientId);
  }

  // دالة مساعدة عشان م نكررش الكود
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

  Future<void> deleteReminder({required String reminderId}) async {
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
      (_) =>
          emit(ReminderDeleteSuccess(message: 'Reminder deleted successfully')),
    );
  }

  // داخل reminder_cubit.dart

  Future<void> getUpcomingReminders({required String patientId}) async {
    // لا نحتاج لعمل emit لـ Loading هنا لأن العملية تحدث في الخلفية عند فتح الهوم
    final result = await repo.getUpcomingReminders(
      patientId: patientId,
      days: 14,
    );

    result.fold(
      (failure) =>
          print("❌ Failed to sync upcoming reminders: ${failure.errmessage}"),
      (instances) async {
        // print("✅ Successfully synced ${instances.length} occurrences");
        // getTodayReminders(patientId: patientId);
        print("✅ Synced ${instances.length} reminders");

        // 3. بعد ما السيرفر حدث الـ SQLite، اقرأ منها تاني وحدث الـ UI
        final updatedData = await repo.getTodayReminders(patientId: patientId);
        updatedData.fold(
          (failure) => null, // خلاص عرضنا القديم
          (allReminders) => _emitSuccess(allReminders), // اعرض الجديد
        );
      },
    );
  }

  // Future<void> syncOfflineActions() async {
  //   // لا نحتاج لإصدار حالات Loading لأن المزامنة تتم في الخلفية
  //   try {
  //     // استدعاء دالة المزامنة من الـ Repository
  //     await repo.syncOfflineActions();
  //     print("✅ Offline actions synced successfully.");
  //   } catch (e) {
  //     print("❌ Sync error: $e");
  //   }
  // }

  Future<void> syncOfflineActions() async {
    // بننادي الريبو ونشوف النتيجة
    final result = await repo.syncOfflineActions();

    result.fold(
      (failure) {
        // هيطبع الفشل لو النت فاصل
        print("⚠️ Offline sync failed: ${failure.errmessage}");
      },
      (_) {
        // هيطبع النجاح فقط لو الداتا اترفعت فعلاً أو القائمة كانت فاضية
        print("✅ Offline actions processed successfully.");
      },
    );
  }
}
