import 'package:graduation_project/features/reminder/data/models/reminder_instance_model.dart';
import '../../../../core/database/local_database_service.dart';

class LocalOccurrenceDataSource {
  final dbService = LocalDatabaseService.instance;

  Future<void> saveOccurrences(
    List<ReminderInstanceModel> instances,
    String patientId,
  ) async {
    final db = await dbService.database;

    await db.transaction((txn) async {
      await txn.delete(
        'occurrences',
        where: 'patientId = ?',
        whereArgs: [int.tryParse(patientId) ?? 0],
      );

      final batch = txn.batch();
      for (var instance in instances) {
        batch.insert('occurrences', {
          'reminderId': instance.reminderId,
          'patientId': int.tryParse(patientId) ?? 0,
          'title': instance.title,
          'message': instance.message,
          'dueDateTime': instance.dueDateTime,
          'status': _mapStatusToEnum(instance.status),
          'type': instance.type,
          'canSnooze': instance.canSnooze ? 1 : 0,
          'canConfirm': instance.canConfirm ? 1 : 0,
          'syncStatus': 0,
        });
      }

      await batch.commit(noResult: true);
    });

    print(
      "✅ Transaction Completed: Cleared and Saved ${instances.length} reminders safely.",
    );
  }

  Future<List<Map<String, dynamic>>> getTodayOccurrences() async {
    final db = await dbService.database;
    final String today = DateTime.now().toIso8601String().split('T')[0];

    return await db.query(
      'occurrences',
      where: 'dueDateTime LIKE ?',
      whereArgs: ['$today%'],
      orderBy: 'dueDateTime ASC',
    );
  }

  Future<void> updateOccurrenceActionOffline({
    required int id,
    required int newStatus,
  }) async {
    final db = await dbService.database;
    final String now = DateTime.now().toIso8601String();

    await db.update(
      'occurrences',
      {'status': newStatus, 'syncStatus': 1, 'actionTime': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPendingSyncOccurrences() async {
    final db = await dbService.database;
    return await db.query(
      'occurrences',
      where: 'syncStatus = ?',
      whereArgs: [1],
    );
  }

  int _mapStatusToEnum(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'confirmed':
      case 'taken':
        return 2;
      case 'skipped':
        return 3;
      case 'snoozed':
        return 4;
      default:
        return 0;
    }
  }

  Future<void> updateSyncStatus(int id, int newSyncStatus) async {
    final db = await dbService.database;
    await db.update(
      'occurrences',
      {'syncStatus': newSyncStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllUpcomingFromDb() async {
    final db = await dbService.database;
    return await db.query('occurrences', orderBy: 'dueDateTime ASC');
  }

  Future<void> deleteAllForPatient(String patientId) async {
    final db = await dbService.database;
    await db.delete(
      'occurrences',
      where: 'patientId = ?',
      whereArgs: [int.tryParse(patientId) ?? 0],
    );
    print("🧹 Local database cleared for patient: $patientId");
  }
}
