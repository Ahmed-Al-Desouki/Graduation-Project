import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_instance_model.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';
import 'package:graduation_project/features/reminder/data/services/reminder_web_service.dart';

abstract class ReminderRepository {
  ReminderRepository(ReminderWebService reminderWebService);

  Future<Either<Failure, ReminderModel>> createReminder({
    required String patientId,
    required String type,
    required String title,
    required DateTime startDate, // ← بقى DateTime
    required DateTime endDate,
    String? rrule,
    SimpleModel? simple,
    required String message,
  });

  // Future<Either<Failure, List<ReminderInstanceModel>>> getUpcomingReminders({
  //   required String patientId,
  //   required int hours,
  // });

  Future<Either<Failure, List<ReminderInstanceModel>>> getTodayReminders({
    required String patientId,
  });

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
  });

  Future<Either<Failure, void>> deleteReminder({
    required String patientId,
    required String reminderId,
  });

  Future<Either<Failure, List<ReminderInstanceModel>>> getUpcomingReminders({
    required String patientId,
    int days = 14,
  });

  Future<Either<Failure, void>> syncOfflineActions();
}
