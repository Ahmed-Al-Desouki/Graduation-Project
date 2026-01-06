import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/services/notification_service.dart';
import 'package:graduation_project/features/reminder/data/data_sources/local_occurrence_data_source.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_instance_model.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';
import 'package:graduation_project/features/reminder/data/repo/reminder_repo.dart';
import 'package:graduation_project/features/reminder/data/services/reminder_web_service.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderWebService _webService;
  final LocalOccurrenceDataSource _localDataSource;

  ReminderRepositoryImpl(this._webService, this._localDataSource);

  // @override
  // Future<Either<Failure, List<ReminderInstanceModel>>> getUpcomingReminders({
  //   required String patientId,
  //   int days = 20,
  // }) async {
  //   try {
  //     final response = await _webService.getUpcomingReminders(
  //       patientId,
  //       days: days,
  //     );
  //     await AwesomeNotifications().cancelAllSchedules();
  //     await _localDataSource.deleteAllForPatient(patientId);
  //     if (response.isNotEmpty) {
  //       // 1. 🔥 أهم خطوة: الغي كل المنبهات المجدولة "قديم" في السيستم قبل ما تعمل الجداد
  //       // ده عشان لو الـ Sync نزل نفس المواعيد تاني ميتكرروش
  //       // await AwesomeNotifications().cancelAllSchedules();

  //       // 2. احفظ في الـ SQLite (اللي بيمسح القديم برضه بفضل الـ delete اللي عملناه)
  //       await _localDataSource.saveOccurrences(response, patientId);

  //       // 3. اسحب اللي اتحفظ بالـ IDs الجديدة
  //       final List<Map<String, dynamic>> savedRows =
  //           await _localDataSource.getAllUpcomingFromDb();

  //       for (var row in savedRows) {
  //         final scheduledTime = DateTime.parse(row['dueDateTime']).toLocal();
  //         final String uniqueString =
  //             "${row['reminderId']}_${scheduledTime.year}${scheduledTime.month}${scheduledTime.day}${scheduledTime.hour}${scheduledTime.minute}";
  //         final int deterministicId = uniqueString.hashCode.abs();
  //         // if (scheduledTime.isAfter(DateTime.now())) {
  //         await NotificationService.scheduleNotification(
  //           id: deterministicId,
  //           title: row['title'],
  //           body: row['message'] ?? "موعد الجرعة",
  //           scheduledDate: scheduledTime,
  //           type: row['type'],
  //         );
  //         // }
  //       }
  //     }
  //     return Right(response);
  //   } catch (e) {
  //     return Left(ServerFailure(e.toString()));
  //   }
  // }

  @override
  Future<Either<Failure, List<ReminderInstanceModel>>> getUpcomingReminders({
    required String patientId,
    int days = 14,
  }) async {
    try {
      // 1. حاول تجيب الداتا من السيرفر الأول (بدون مسح أي شيء)
      final response = await _webService.getUpcomingReminders(
        patientId,
        days: days,
      );

      // 2. 🔥 لو السيرفر رد (سواء بقائمة مليانة أو فاضية)، هنا بس نمسح الموبايل
      // لأن ده معناه إننا "مزامنين" مع السيرفر حالياً
      await AwesomeNotifications().cancelAllSchedules();
      await _localDataSource.deleteAllForPatient(patientId);

      if (response.isNotEmpty) {
        // 3. احفظ الجديد
        await _localDataSource.saveOccurrences(response, patientId);

        // 4. اسحب وجدول بـ IDs ثابتة (Deterministic IDs)
        final List<Map<String, dynamic>> savedRows =
            await _localDataSource.getAllUpcomingFromDb();

        for (var row in savedRows) {
          final scheduledTime = DateTime.parse(row['dueDateTime']).toLocal();

          String timePart =
              "${scheduledTime.day}${scheduledTime.hour}${scheduledTime.minute}";
          int deterministicId = int.parse("${row['reminderId']}$timePart");

          // تأكد أن الموعد في المستقبل بـ 5 ثوانٍ على الأقل لتجنب تداخل الأصوات فوراً
          if (scheduledTime.isAfter(
            DateTime.now().add(const Duration(seconds: 5)),
          )) {
            await NotificationService.scheduleNotification(
              id: deterministicId,
              title: row['title'],
              body: row['message'] ?? "موعد الجرعة",
              scheduledDate: scheduledTime,
              type: row['type'],
            );
          }
        }
      }
      return Right(response);
    } catch (e) {
      // لو مفيش نت أو حصل Error، الداتا اللوكال هتفضل زي ما هي مش هتتمسح
      return Left(ServerFailure(e.toString()));
    }
  }

  // @override
  // Future<Either<Failure, List<ReminderInstanceModel>>> getTodayReminders({
  //   required String patientId,
  // }) async {
  //   try {
  //     // 1. محاولة تحديث البيانات من السيرفر أولاً (Download)
  //     // حطينا timeout عشان لو النت ضعيف الـ UI ميقفش
  //     try {
  //       await getUpcomingReminders(
  //         patientId: patientId,
  //       ).timeout(const Duration(seconds: 8));
  //       print("✅ Fresh data synced from server.");
  //     } catch (e) {
  //       print("⚠️ Sync timed out or failed, showing local data only: $e");
  //     }

  //     // 2. اسحب البيانات من الـ SQLite (سواء اتحدثت أو لا)
  //     // دي أهم خطوة لأن الـ SQLite هو "المصدر الوحيد للحقيقة" حالياً
  //     final localData = await _localDataSource.getTodayOccurrences();

  //     if (localData.isEmpty) {
  //       print("ℹ️ No reminders found in local database for today.");
  //     }

  //     // 3. تحويل الخريطة (Map) لموديل (Model)
  //     final instances =
  //         localData.map((e) => ReminderInstanceModel.fromJson(e)).toList();

  //     return Right(instances);
  //   } catch (e) {
  //     // 4. في حالة حدوث خطأ غير متوقع، نحاول برضه نجيب اللي في الداتا بيز
  //     print("❌ Error in getTodayReminders: $e");
  //     final backupData = await _localDataSource.getTodayOccurrences();
  //     return Right(
  //       backupData.map((e) => ReminderInstanceModel.fromJson(e)).toList(),
  //     );
  //   }
  // }

  @override
  Future<Either<Failure, List<ReminderInstanceModel>>> getTodayReminders({
    required String patientId,
  }) async {
    try {
      // // 1. المزامنة مع السيرفر
      // final syncResult = await getUpcomingReminders(
      //   patientId: patientId,
      // ).timeout(const Duration(seconds: 8));

      // // ✅ تشيك حقيقي على النتيجة
      // syncResult.fold(
      //   (failure) => print("⚠️ Sync failed: ${failure.errmessage}"), // لو فشل
      //   (_) => print("✅ Fresh data synced from server."), // لو نجح فعلاً
      // );

      // // 2. اسحب من SQLite (سواء المزامنة نجحت أو فشلت)
      final localData = await _localDataSource.getTodayOccurrences();

      // باقي الكود كما هو...
      final instances =
          localData.map((e) => ReminderInstanceModel.fromJson(e)).toList();
      return Right(instances);
    } catch (e) {
      // في حالة الـ Timeout أو أي Error غير متوقع
      print("❌ Error in getTodayReminders: $e");
      final backupData = await _localDataSource.getTodayOccurrences();
      return Right(
        backupData.map((e) => ReminderInstanceModel.fromJson(e)).toList(),
      );
    }
  }

  // --- 3. مزامنة الأفعال (الأكشنز) التي تمت أوفلاين ---
  // @override
  // Future<void> syncOfflineActions() async {
  //   final pendingActions = await _localDataSource.getPendingSyncOccurrences();

  //   for (var action in pendingActions) {
  //     try {
  //       final int reminderId = action['reminderId'];
  //       final String dueDateTime =
  //           action['dueDateTime']; // وقت الموعد المحلي [cite: 223]
  //       final int status = action['status'];

  //       if (status == 2) {
  //         // Taken/Confirm [cite: 140, 162]
  //         await _webService.confirmOccurrence(
  //           reminderId: reminderId,
  //           occurrenceDateTime: dueDateTime,
  //         );
  //       } else if (status == 4) {
  //         // Snoozed [cite: 140, 180]
  //         await _webService.snoozeOccurrence(
  //           reminderId: reminderId,
  //           occurrenceDateTime: dueDateTime,
  //         );
  //       } else if (status == 3) {
  //         // Skipped [cite: 140, 194]
  //         await _webService.skipOccurrence(
  //           reminderId: reminderId,
  //           occurrenceDateTime: dueDateTime,
  //         );
  //       }

  //       await _localDataSource.updateSyncStatus(action['id'], 0);
  //     } catch (e) {
  //       print("Sync failed: $e");
  //     }
  //   }
  // }
  @override
  Future<Either<Failure, void>> syncOfflineActions() async {
    final pendingActions = await _localDataSource.getPendingSyncOccurrences();

    if (pendingActions.isEmpty) {
      return const Right(null); // مفيش حاجة تترفع، نعتبره نجاح "صامت"
    }

    for (var action in pendingActions) {
      try {
        final int reminderId = action['reminderId'];
        final String dueDateTime = action['dueDateTime'];
        final int status = action['status'];

        // إرسال البيانات للسيرفر
        if (status == 2) {
          await _webService.confirmOccurrence(
            reminderId: reminderId,
            occurrenceDateTime: dueDateTime,
          );
        } else if (status == 4) {
          await _webService.snoozeOccurrence(
            reminderId: reminderId,
            occurrenceDateTime: dueDateTime,
          );
        } else if (status == 3) {
          await _webService.skipOccurrence(
            reminderId: reminderId,
            occurrenceDateTime: dueDateTime,
          );
        }

        // لو العملية نجحت، حدث حالة المزامنة في SQLite
        await _localDataSource.updateSyncStatus(action['id'], 0);
      } catch (e) {
        // 🔥 لو حصل أي خطأ (زي إن النت فصل)، وقف اللوب وارجع بالخطأ فوراً
        print("❌ Sync failed for an action: $e");
        return Left(
          ServerFailure("Failed to sync some actions due to network error."),
        );
      }
    }

    return const Right(null); // كل الأكشنز اترفعت بنجاح
  }

  // --- 4. إنشاء ريمندر جديد ---
  @override
  Future<Either<Failure, ReminderModel>> createReminder({
    required String patientId,
    required String type,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    String? rrule,
    SimpleModel? simple,
    required String message,
  }) async {
    try {
      final res = await _webService.createReminder(
        patientId,
        type: type,
        title: title,
        startDate: startDate,
        endDate: endDate,
        rrule: rrule,
        simple: simple,
        message: message,
      );
      return Right(res);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // --- 5. تحديث ريمندر موجود ---
  @override
  Future<Either<Failure, ReminderModel>> updateReminder({
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
    try {
      final res = await _webService.updateReminder(
        patientId,
        reminderId,
        name: name,
        startDate: startDate,
        endDate: endDate,
        frequency: frequency,
        intervalHours: intervalHours,
        baseTime: baseTime,
        message: message,
      );
      return Right(res);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // --- 6. حذف ريمندر ---
  @override
  Future<Either<Failure, void>> deleteReminder({
    required String patientId,
    required String reminderId,
  }) async {
    try {
      await _webService.deleteReminder(
        patientId: patientId,
        reminderId: reminderId,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
