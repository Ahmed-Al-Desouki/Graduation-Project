class BookingEntity {
  final String timeSlotId;
  final String? patientNotes;
  final bool grantMedicalHistoryAccess;
  final String paymentMethod;

  BookingEntity({
    required this.timeSlotId,
    this.patientNotes,
    this.grantMedicalHistoryAccess = true,
    required this.paymentMethod,
  });
}
