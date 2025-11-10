class ReminderModel {
  final String type;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String frequency;
  final int? intervalHours;
  final String baseTime;
  final String? message;

  ReminderModel({
    required this.type,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.frequency,
    this.intervalHours,
    required this.baseTime,
    this.message,
  });
  
}
