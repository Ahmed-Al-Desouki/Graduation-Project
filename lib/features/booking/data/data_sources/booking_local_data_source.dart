import 'package:graduation_project/features/booking/data/models/requests/day_slots_model.dart';

abstract class BookingLocalDataSource {
  // حفظ وجلب قائمة المواعيد (للكالندر)
  Future<void> cacheDaySlots(List<DaySlotsModel> slots);
  Future<List<DaySlotsModel>> getCachedDaySlots();

  // حفظ وجلب الجدول النشط للدكتور
  Future<void> cacheActiveSchedule(Map<String, dynamic> schedule);
  Future<Map<String, dynamic>> getCachedActiveSchedule();

  // مسح الكاش عند تسجيل الخروج أو التحديث الإجباري
  Future<void> clearCache();
}
