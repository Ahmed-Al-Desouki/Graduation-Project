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
class ReminderInstanceModel {
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
      reminderId: json['reminderId'] is int 
          ? json['reminderId'] 
          : int.tryParse(json['reminderId'].toString()) ?? 0,
      title: json['title'] ?? 'No Title',
      message: json['message'] ?? '',
      dueDateTime: json['dueDateTime'] ?? '',
      type: json['type'] ?? 'Custom',
      isMedication: json['isMedication'] ?? false,
      dosage: json['dosage'],
      status: json['status'] ?? 'Pending',
      canSnooze: json['canSnooze'] ?? true,
      canConfirm: json['canConfirm'] ?? true,
    );
  }
}
