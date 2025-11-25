class ReminderInstanceModel {
  final int instanceID;
  final int reminderID;
  final String dueDateTime;
  final String status;
  final String? name;
  final String? message;
  final String type;
  final bool isMedication;
  final String? dosage;

  ReminderInstanceModel({
    required this.instanceID,
    required this.reminderID,
    required this.dueDateTime,
    required this.status,
    required this.name,
    required this.message,
    required this.type,
    required this.isMedication,
    this.dosage,
  });

  factory ReminderInstanceModel.fromJson(Map<String, dynamic> json) {
    return ReminderInstanceModel(
      instanceID: json['instanceID'],
      reminderID: json['reminderID'],
      dueDateTime: json['dueDateTime'],
      status: json['status'],
      name: json['name'],
      message: json['message'],
      type: json['type'],
      isMedication: json['isMedication'],
      dosage: json['dosage'],
    );
  }
}
