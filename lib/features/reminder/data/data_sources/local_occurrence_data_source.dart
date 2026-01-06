import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_instance_model.dart';
import '../../../../core/database/local_database_service.dart';

class LocalOccurrenceDataSource {
  final dbService = LocalDatabaseService.instance;

  // Future<void> saveOccurrences(
  //   List<ReminderInstanceModel> instances,
  //   String patientId,
  // ) async {
  //   final db = await dbService.database;
  //   final batch = db.batch();

  //   // 1. مسح شامل لكل المواعيد القديمة قبل إضافة أي شيء جديد
  //   // ده بيضمن إن لو السيرفر بعت 0 بيانات، الموبايل ينضف تماماً
  //   await db.delete(
  //     'occurrences',
  //     where: 'patientId = ?',
  //     whereArgs: [int.tryParse(patientId) ?? 0],
  //   );

  //   for (var instance in instances) {
  //     batch.insert('occurrences', {
  //       'reminderId': instance.reminderId,
  //       'patientId': int.tryParse(patientId) ?? 0,
  //       'title': instance.title,
  //       'message': instance.message,
  //       'dueDateTime': instance.dueDateTime,
  //       'status': _mapStatusToEnum(instance.status),
  //       'type': instance.type,
  //       'canSnooze': instance.canSnooze ? 1 : 0,
  //       'canConfirm': instance.canConfirm ? 1 : 0,
  //       'syncStatus': 0,
  //     });
  //   }
  //   await batch.commit(noResult: true);
  // }
  Future<void> saveOccurrences(
    List<ReminderInstanceModel> instances,
    String patientId,
  ) async {
    final db = await dbService.database;

    // 🔥 استخدام Transaction: يضمن أن المسح والإضافة يتمان كعملية واحدة ذرية
    await db.transaction((txn) async {
      // 1. المسح (نستخدم txn بدلاً من db)
      await txn.delete(
        'occurrences',
        where: 'patientId = ?',
        whereArgs: [int.tryParse(patientId) ?? 0],
      );

      // 2. الإضافة (نستخدم txn لإنشاء الـ batch)
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

      // تنفيذ الإضافة
      await batch.commit(noResult: true);
    });

    print(
      "✅ Transaction Completed: Cleared and Saved ${instances.length} reminders safely.",
    );
  }

  // 2. جلب مواعيد اليوم فقط (لعرضها في الـ UI)
  Future<List<Map<String, dynamic>>> getTodayOccurrences() async {
    final db = await dbService.database;
    final String today = DateTime.now().toIso8601String().split('T')[0];

    // كويري يجيب أي موعد بيبدأ بتاريخ النهاردة
    return await db.query(
      'occurrences',
      where: 'dueDateTime LIKE ?',
      whereArgs: ['$today%'],
      orderBy: 'dueDateTime ASC',
    );
  }

  // 3. تحديث الحالة "أوفلاين" (Taken, Snoozed, Skipped)
  Future<void> updateOccurrenceActionOffline({
    required int id,
    required int newStatus, // [cite: 140]
  }) async {
    final db = await dbService.database;
    final String now = DateTime.now().toIso8601String();

    await db.update(
      'occurrences',
      {
        'status': newStatus,
        'syncStatus': 1, // علامة إننا محتاجين نرفع الأكشن ده للسيرفر
        'actionTime': now, // الوقت المحلي الفعلي للأكشن [cite: 223]
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 4. جلب الأكشنز اللي لسه ماترفعتش للسيرفر (لعمل Sync)
  Future<List<Map<String, dynamic>>> getPendingSyncOccurrences() async {
    final db = await dbService.database;
    return await db.query(
      'occurrences',
      where: 'syncStatus = ?',
      whereArgs: [1],
    );
  }

  // دالة مساعدة لتحويل الـ Status من String لرقم Enum كما في الدوكيومنتشن
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

  // 5. تحديث حالة المزامنة بعد نجاح الرفع للسيرفر
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
