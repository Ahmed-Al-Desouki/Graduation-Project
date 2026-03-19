import 'package:graduation_project/features/booking/domain/entities/schedule_entity.dart';

// class ScheduleModel extends ScheduleEntity {
//   ScheduleModel({
//     required super.id,
//     required super.templateName,
//     required super.slotDurationMinutes,
//     required super.bufferTimeMinutes,
//     required super.effectiveFromDate,
//     required super.effectiveToDate,
//     required super.timeRanges,
//   });

//   factory ScheduleModel.fromJson(Map<String, dynamic> map) {
//     print(
//       "Parsing field slotDuration: ${map['slotDurationMinutes'].runtimeType}",
//     );
//     return ScheduleModel(
//       id: map['id'],
//       templateName: map['templateName'],
//       slotDurationMinutes: _toInt(map['slotDurationMinutes']),
//       bufferTimeMinutes: _toInt(map['bufferTimeMinutes']),
//       effectiveFromDate: DateTime.parse(map['effectiveFromDate']),
//       effectiveToDate: DateTime.parse(map['effectiveToDate']),
//       timeRanges:
//           (map['timeRanges'] as List)
//               .map((e) => TimeRangeModel.fromJson(e))
//               .toList(),
//     );
//   }
// }

// class TimeRangeModel extends TimeRangeEntity {
//   TimeRangeModel({
//     required super.dayOfWeek,
//     required super.startTime,
//     required super.endTime,
//   });

//   factory TimeRangeModel.fromJson(Map<String, dynamic> map) {
//     return TimeRangeModel(
//       dayOfWeek: _parseDayToIndex(map['dayOfWeek']),
//       startTime: map['startTime'],
//       endTime: map['endTime'],
//     );
//   }

//   // 🛠️ دالة تحويل أيام الأسبوع من String لـ int
//   static int _parseDayToIndex(dynamic value) {
//     if (value is int) return value; // لو جاي رقم أصلاً

//     if (value is String) {
//       switch (value.toLowerCase()) {
//         case 'sunday':
//           return 0;
//         case 'monday':
//           return 1;
//         case 'tuesday':
//           return 2;
//         case 'wednesday':
//           return 3;
//         case 'thursday':
//           return 4;
//         case 'friday':
//           return 5;
//         case 'saturday':
//           return 6;
//         default:
//           // لو باعت رقم كـ String "1"
//           return int.tryParse(value) ?? 0;
//       }
//     }
//     return 0;
//   }
// }

// schedule_model.dart

// class ScheduleModel extends ScheduleEntity {
//   ScheduleModel({
//     required super.id,
//     required super.templateName,
//     required super.slotDurationMinutes,
//     required super.bufferTimeMinutes,
//     required super.effectiveFromDate,
//     required super.effectiveToDate,
//     required super.timeRanges,
//   });

//   // ✅ التعديل السحري هنا: الـ factory دلوقتي هياخد List مش Map
//   factory ScheduleModel.fromV2List(List<dynamic> list) {
//     // لو مفيش بيانات راجعة، نرجع أوبجكت فاضي
//     if (list.isEmpty) {
//       return ScheduleModel(
//         id: '',
//         templateName: 'Default Config',
//         slotDurationMinutes: 30,
//         bufferTimeMinutes: 5,
//         effectiveFromDate: DateTime.now(),
//         effectiveToDate: DateTime.now().add(const Duration(days: 90)),
//         timeRanges: [],
//       );
//     }

//     // بناخد أول يوم عشان نعرف الـ duration والـ buffer (لأنهم غالباً ثابتين للدكتور)
//     final firstDay = list.first;

//     return ScheduleModel(
//       id: 'active_config', // الـ ID مابقاش يرجع من السيرفر كـ UUID للجدول
//       templateName: 'My Working Hours',
//       slotDurationMinutes: _toInt(firstDay['slotDurationMinutes']),
//       bufferTimeMinutes: _toInt(firstDay['bufferTimeMinutes']),
//       effectiveFromDate: DateTime.now(), // السيرفر بقى بيعتبره فعال دائماً
//       effectiveToDate: DateTime.now().add(const Duration(days: 180)),
//       timeRanges: list.map((e) => TimeRangeModel.fromJson(e)).toList(),
//     );
//   }
// }

// class TimeRangeModel extends TimeRangeEntity {
//   TimeRangeModel({
//     required super.dayOfWeek,
//     required super.startTime,
//     required super.endTime,
//   });

//   factory TimeRangeModel.fromJson(Map<String, dynamic> map) {
//     return TimeRangeModel(
//       // السيرفر في v2.0 بيرجع الحقل ده باسم 'dayOfWeek' كـ int مباشرة
//       dayOfWeek: _toInt(map['dayOfWeek']),
//       startTime: map['startTime'] ?? "09:00:00",
//       endTime: map['endTime'] ?? "17:00:00",
//     );
//   }
// }

// schedule_model.dart

class ScheduleModel extends ScheduleEntity {
  ScheduleModel({
    required super.id,
    required super.templateName,
    required super.slotDurationMinutes,
    required super.bufferTimeMinutes,
    required super.effectiveFromDate,
    required super.effectiveToDate,
    required super.timeRanges,
  });

  factory ScheduleModel.fromV2List(List<dynamic> list) {
    if (list.isEmpty) {
      return ScheduleModel(
        id: '',
        templateName: 'Default',
        slotDurationMinutes: 30,
        bufferTimeMinutes: 5,
        effectiveFromDate: DateTime.now(),
        effectiveToDate: DateTime.now().add(const Duration(days: 90)),
        timeRanges: [],
      );
    }

    // بناخد أول يوم لسحب الإعدادات العامة
    final firstDay = list.first;

    return ScheduleModel(
      id: 'active_config',
      templateName: 'My Working Hours',
      slotDurationMinutes: _toInt(firstDay['slotDurationMinutes']),
      bufferTimeMinutes: _toInt(firstDay['bufferTimeMinutes']),
      // ✅ سحب التاريخ من أول يوم في الرد (لو موجود)
      effectiveFromDate:
          DateTime.tryParse(firstDay['effectiveFromDate'] ?? "") ??
          DateTime.now(),
      effectiveToDate:
          DateTime.tryParse(firstDay['effectiveToDate'] ?? "") ??
          DateTime.now().add(const Duration(days: 180)),
      timeRanges: list.map((e) => TimeRangeModel.fromJson(e)).toList(),
    );
  }
}

class TimeRangeModel extends TimeRangeEntity {
  TimeRangeModel({
    required super.dayOfWeek,
    required super.startTime,
    required super.endTime,
  });

  factory TimeRangeModel.fromJson(Map<String, dynamic> map) {
    // 🔍 طباعة الـ Map عشان نتأكد من الـ Keys (شيلها بعد ما تتأكد)
    print("DEBUG: Server Map Data: $map");

    return TimeRangeModel(
      // ✅ استخدام الـ Helper الذكي لقراءة اليوم سواء رقم أو نص
      dayOfWeek: _parseDayToIndex(map['dayOfWeek'] ?? map['day']),
      startTime: map['startTime'] ?? "09:00:00",
      endTime: map['endTime'] ?? "17:00:00",
    );
  }

  // 🛠️ دالة التحويل الذكية للأيام
  static int _parseDayToIndex(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'sunday':
          return 0;
        case 'monday':
          return 1;
        case 'tuesday':
          return 2;
        case 'wednesday':
          return 3;
        case 'thursday':
          return 4;
        case 'friday':
          return 5;
        case 'saturday':
          return 6;
        default:
          return int.tryParse(value) ?? 0;
      }
    }
    return 0;
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
