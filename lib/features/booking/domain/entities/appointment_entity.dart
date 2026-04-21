class AppointmentEntity {
  final String appointmentId;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final String status; // Pending, Confirmed, InProgress, etc.
  final String? patientNotes;
  final String doctorName;
  final String patientName;
  final List<dynamic>? prescriptions;
  final int patientId; // ✅ أضفنا هذا السطر

  AppointmentEntity({
    required this.appointmentId,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.patientNotes,
    required this.doctorName,
    required this.patientName,
    required this.patientId, // ✅ أضفنا هذا السطر
    this.prescriptions,
  });
}
