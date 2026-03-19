import 'package:graduation_project/core/constant.dart';
import 'package:graduation_project/features/booking/data/models/requests/day_slots_model.dart';
import 'package:hive/hive.dart';
import 'booking_local_data_source.dart';

class BookingLocalDataSourceImpl implements BookingLocalDataSource {
  final Box _box; // تمرير الـ Box المحقون عبر GetIt

  BookingLocalDataSourceImpl(this._box);

  @override
  Future<void> cacheDaySlots(List<DaySlotsModel> slots) async {
    // نحول القائمة لـ JSON String أو نترك Hive يتعامل مع الـ Map مباشرة
    final data = slots.map((slot) => _mapFromDaySlotsModel(slot)).toList();
    await _box.put(kCachedSlotsKey, data);
  }

  @override
  Future<List<DaySlotsModel>> getCachedDaySlots() async {
    final List? data = _box.get(kCachedSlotsKey);
    if (data != null) {
      return data
          .map((i) => DaySlotsModel.fromJson(Map<String, dynamic>.from(i)))
          .toList();
    }
    throw Exception("No cached slots found"); // يتم معالجتها في الـ Repo
  }

  @override
  Future<void> cacheActiveSchedule(List<dynamic> config) async {
    await _box.put(kCachedScheduleKey, config);
  }

  // @override
  // Future<Map<String, dynamic>> getCachedActiveSchedule() async {
  //   final Map? data = _box.get(kCachedScheduleKey);
  //   if (data != null) return Map<String, dynamic>.from(data);
  //   throw Exception("No cached schedule found");
  // }
  @override
  Future<List<dynamic>> getCachedActiveSchedule() async {
    // ✅ التغيير من Map? لـ List?
    final List? data = _box.get(kCachedScheduleKey);

    if (data != null) {
      // ✅ نرجعه كـ List<dynamic> عشان الموديل (fromV2List) يعرف يقراه
      return List<dynamic>.from(data);
    }

    throw Exception("No cached schedule found");
  }

  @override
  Future<void> clearCache() async {
    await _box.clear();
  }

  // دالة مساعدة لتحويل الموديل لـ Map متوافقة مع Hive
  Map<String, dynamic> _mapFromDaySlotsModel(DaySlotsModel model) {
    // هنا يمكنك استخدام toJson() لو كنت عرفتها في الموديل
    return {
      'date': model.date.toIso8601String(),
      'slots':
          model.slots
              .map(
                (s) => {
                  'slotId': s.slotId,
                  'slotDate': s.date.toIso8601String(),
                  'startTime': s.startTime,
                  'status': s.status,
                  'patientFullName': s.patientName,
                  'appointmentId': s.appointmentId,
                  'patientNote':
                      s.patientNote, // ✅ لازم نضيف السطر ده عشان الملاحظات متضيعش
                },
              )
              .toList(),
    };
  }
}
