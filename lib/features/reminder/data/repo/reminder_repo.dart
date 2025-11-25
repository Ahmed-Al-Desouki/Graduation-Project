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
    required String name,
    required String startDate,
    required String endDate,
    required String frequency,
    required String intervalHours,
    required String baseTime,
    required String message,
  });

  Future<Either<Failure, ReminderInstanceModel>> getUpcomingReminders({
    required String patientId,
    required int hours,
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
}

// import '../services/reminder_web_service.dart';

// class ReminderRepository {
//   final ReminderWebService api;

//   ReminderRepository(this.api);

//   Future<Either<Failure, dynamic>> createReminder(
//     String patientId,
//     Map<String, dynamic> data,
//   ) async {
//     try {
//       final res = await api.createReminder(patientId, data);
//       return Right(res);
//     } catch (e) {
//       return Left(ServerFailure(e.toString()));
//     }
//   }

//   Future<Either<Failure, List<dynamic>>> getUpcoming(String patientId) async {
//     try {
//       final res = await api.getUpcomingReminders(patientId);
//       return Right(res);
//     } catch (e) {
//       return Left(ServerFailure(e.toString()));
//     }
//   }
// }
