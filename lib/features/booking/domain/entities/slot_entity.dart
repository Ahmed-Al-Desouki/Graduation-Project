// 1. يمثل الفترة الزمنية (الموعد)
class SlotEntity {
  final String slotId;
  final DateTime date;
  final String startTime;
  final String status; // Available, Booked, Completed, etc.
  final String? patientName;
  final String? appointmentId;
  final String? patientNote; // ملاحظة المريض (اختياري)

  SlotEntity({
    required this.slotId,
    required this.date,
    required this.startTime,
    required this.status,
    this.patientName,
    this.appointmentId,
    this.patientNote,
  });
}
