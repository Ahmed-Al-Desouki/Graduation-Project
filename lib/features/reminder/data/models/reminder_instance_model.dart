// class ReminderInstanceModel {
//   final int instanceID;
//   final int reminderID;
//   final String dueDateTime;
//   final String status;
//   final String? name;
//   final String? message;
//   final String type;
//   final bool isMedication;
//   final String? dosage;

//   ReminderInstanceModel({
//     required this.instanceID,
//     required this.reminderID,
//     required this.dueDateTime,
//     required this.status,
//     required this.name,
//     required this.message,
//     required this.type,
//     required this.isMedication,
//     this.dosage,
//   });

//   factory ReminderInstanceModel.fromJson(Map<String, dynamic> json) {
//     return ReminderInstanceModel(
//       instanceID: json['instanceID'],
//       reminderID: json['reminderID'],
//       dueDateTime: json['dueDateTime'],
//       status: json['status'],
//       name: json['name'],
//       message: json['message'],
//       type: json['type'],
//       isMedication: json['isMedication'],
//       dosage: json['dosage'],
//     );
//   }
// }
// class ReminderInstanceModel {
//   final int reminderId;
//   final String title;
//   final String? message;
//   final String dueDateTime;
//   final String type;
//   final bool isMedication;
//   final String? dosage;
//   final String status;
//   final bool canSnooze;
//   final bool canConfirm;

//   ReminderInstanceModel({
//     required this.reminderId,
//     required this.title,
//     this.message,
//     required this.dueDateTime,
//     required this.type,
//     required this.isMedication,
//     this.dosage,
//     required this.status,
//     required this.canSnooze,
//     required this.canConfirm,
//   });

//   factory ReminderInstanceModel.fromJson(Map<String, dynamic> json) {
//     return ReminderInstanceModel(
//       reminderId:
//           json['reminderId'] is int
//               ? json['reminderId']
//               : int.tryParse(json['reminderId'].toString()) ?? 0,
//       title: json['title'] ?? 'No Title',
//       message: json['message'] ?? '',
//       dueDateTime: json['dueDateTime'] ?? '',
//       type: json['type'] ?? 'Custom',
//       isMedication: json['isMedication'] ?? false,
//       dosage: json['dosage'],
//       status: json['status'] ?? 'Pending',
//       // canSnooze: json['canSnooze'] ?? true,
//       // canConfirm: json['canConfirm'] ?? true,
//       canConfirm:
//           json['canConfirm'] is int
//               ? json['canConfirm'] == 1
//               : (json['canConfirm'] ?? false),
//       canSnooze:
//           json['canSnooze'] is int
//               ? json['canSnooze'] == 1
//               : (json['canSnooze'] ?? false),
//     );
//   }
// }

// class ReminderInstanceModel {
//   // final int id;
//   final int reminderId;
//   final String title;
//   final String? message;
//   final String dueDateTime;
//   final String type;
//   final bool isMedication;
//   final String? dosage;
//   final String status;
//   final bool canSnooze; // رجعناها bool
//   final bool canConfirm; // رجعناها bool

//   ReminderInstanceModel({
//     // required this.id,
//     required this.reminderId,
//     required this.title,
//     this.message,
//     required this.dueDateTime,
//     required this.type,
//     required this.isMedication,
//     this.dosage,
//     required this.status,
//     required this.canSnooze,
//     required this.canConfirm,
//   });

//   factory ReminderInstanceModel.fromJson(Map<String, dynamic> json) {
//     return ReminderInstanceModel(
//       // id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
//       // reminderId:
//       //     json['reminderId'] is int
//       //         ? json['reminderId']
//       //         : int.tryParse(json['reminderId'].toString()) ?? 0,
//       reminderId: int.tryParse(json['reminderId']?.toString() ?? '0') ?? 0,
//       title: json['title']?.toString() ?? 'No Title', // تأمين تحويل لـ String
//       message: json['message']?.toString() ?? '',
//       dueDateTime: json['dueDateTime']?.toString() ?? '',
//       type: json['type']?.toString() ?? 'Custom',
//       isMedication:
//           json['isMedication'] is bool
//               ? json['isMedication']
//               : (json['isMedication'] == 1), // لو جاي من SQLite كـ int
//       dosage: json['dosage']?.toString(),
//       status: json['status']?.toString() ?? 'Pending',
//       // ✅ الحل السحري لقراءة الـ Boolean من أي مصدر:
//       canConfirm:
//           json['canConfirm'] is int
//               ? json['canConfirm'] == 1
//               : (json['canConfirm'] == true),
//       canSnooze:
//           json['canSnooze'] is int
//               ? json['canSnooze'] == 1
//               : (json['canSnooze'] == true),
//     );
//   }
// }

class ReminderInstanceModel {
  final int? id; // 👈 اجعله اختياري (لأنه يأتي من قاعدة البيانات لاحقاً)
  final int reminderId;
  final String title;
  final String? message;
  final String dueDateTime;
  final String type;
  final bool isMedication;
  final String? dosage;
  final String status;
  final bool canSnooze;
  final bool canConfirm;

  ReminderInstanceModel({
    this.id, // 👈
    required this.reminderId,
    required this.title,
    this.message,
    required this.dueDateTime,
    required this.type,
    required this.isMedication,
    this.dosage,
    required this.status,
    required this.canSnooze,
    required this.canConfirm,
  });

  factory ReminderInstanceModel.fromJson(Map<String, dynamic> json) {
    return ReminderInstanceModel(
      // ❌ لا نقرأ id من هنا لأن السيرفر لا يرسله
      reminderId: int.tryParse(json['reminderId']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'No Title',
      message: json['message']?.toString() ?? '',
      dueDateTime: json['dueDateTime']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Medication',
      isMedication: json['isMedication'] == true || json['isMedication'] == 1,
      dosage: json['dosage']?.toString(),
      status: json['status']?.toString() ?? 'Pending',
      canConfirm: json['canConfirm'] == true || json['canConfirm'] == 1,
      canSnooze: json['canSnooze'] == true || json['canSnooze'] == 1,
    );
  }
}
