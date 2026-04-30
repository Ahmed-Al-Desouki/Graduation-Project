import 'package:graduation_project/features/booking/data/models/requests/day_slots_model.dart';

abstract class BookingLocalDataSource {
  Future<void> cacheDaySlots(List<DaySlotsModel> slots);
  Future<List<DaySlotsModel>> getCachedDaySlots();

  Future<void> cacheActiveSchedule(List<dynamic> config);

  Future<List<dynamic>> getCachedActiveSchedule();

  Future<void> clearCache();
}
