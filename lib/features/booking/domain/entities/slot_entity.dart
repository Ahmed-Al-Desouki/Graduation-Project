// 1. يمثل الفترة الزمنية (الموعد)
class SlotEntity {
  final String slotId;
  final DateTime date;
  final String startTime;
  final String status; // Available, Booked, Completed, etc.
  final String? patientName;
  final String? appointmentId;

  SlotEntity({
    required this.slotId,
    required this.date,
    required this.startTime,
    required this.status,
    this.patientName,
    this.appointmentId,
  });
}
