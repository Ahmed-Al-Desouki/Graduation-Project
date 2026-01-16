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

  @override
  Future<Either<Failure, List<ReminderInstanceModel>>> getUpcomingReminders({
    required String patientId,
    int days = 14,
  }) async {
    try {
      final response = await _webService.getUpcomingReminders(
        patientId,
        days: days,
      );

      await AwesomeNotifications().cancelAllSchedules();
      await _localDataSource.deleteAllForPatient(patientId);

      if (response.isNotEmpty) {
        await _localDataSource.saveOccurrences(response, patientId);

        final List<Map<String, dynamic>> savedRows =
            await _localDataSource.getAllUpcomingFromDb();

        for (var row in savedRows) {
          final scheduledTime = DateTime.parse(row['dueDateTime']).toLocal();

          String timePart =
              "${scheduledTime.day}${scheduledTime.hour}${scheduledTime.minute}";
          int deterministicId = int.parse("${row['reminderId']}$timePart");

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
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReminderInstanceModel>>> getTodayReminders({
    required String patientId,
  }) async {
    try {
      final localData = await _localDataSource.getTodayOccurrences();

      final instances =
          localData.map((e) => ReminderInstanceModel.fromJson(e)).toList();
      return Right(instances);
    } catch (e) {
      print("❌ Error in getTodayReminders: $e");
      final backupData = await _localDataSource.getTodayOccurrences();
      return Right(
        backupData.map((e) => ReminderInstanceModel.fromJson(e)).toList(),
      );
    }
  }

  @override
  Future<Either<Failure, void>> syncOfflineActions() async {
    final pendingActions = await _localDataSource.getPendingSyncOccurrences();

    if (pendingActions.isEmpty) {
      return const Right(null);
    }

    for (var action in pendingActions) {
      try {
        final int reminderId = action['reminderId'];
        final String dueDateTime = action['dueDateTime'];
        final int status = action['status'];

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
        await _localDataSource.updateSyncStatus(action['id'], 0);
      } catch (e) {
        print("❌ Sync failed for an action: $e");
        return Left(
          ServerFailure("Failed to sync some actions due to network error."),
        );
      }
    }

    return const Right(null);
  }

  @override
  Future<Either<Failure, ReminderModel>> createReminder({
    required String patientId,
    required String type,
    required String title,
    required DateTime startDate,
    required DateTime? endDate,
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

  @override
  Future<Either<Failure, List<ReminderModel>>> getAllReminders({
    required String patientId,
  }) async {
    try {
      final res = await _webService.getAllReminders(patientId);
      return Right(res);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReminderModel>> updateReminder({
    required String patientId,
    required String reminderId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    String? rrule,
    SimpleModel? simple,
    required String message,
    required bool isSimpleEveryXHours,
  }) async {
    try {
      final res = await _webService.updateReminder(
        patientId,
        reminderId,
        title: title,
        startDate: startDate.toIso8601String(),
        endDate: endDate.toIso8601String(),
        rrule: rrule,
        simple: simple,
        message: message,
        isSimpleEveryXHours: isSimpleEveryXHours,
      );
      return Right(res);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

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
