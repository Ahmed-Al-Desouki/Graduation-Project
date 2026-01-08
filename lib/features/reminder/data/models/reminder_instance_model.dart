class ReminderInstanceModel {
  final int? id;
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
    this.id,
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
