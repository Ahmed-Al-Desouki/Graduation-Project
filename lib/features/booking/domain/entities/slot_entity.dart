class SlotEntity {
  final String slotId;
  final DateTime date;
  final String startTime;
  final String status; // Available, Booked, Blocked, Completed, Cancelled
  final String? patientName;
  final String? appointmentId;
  final String? patientNote;

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
