// features/booking/domain/entities/booking_entity.dart
class BookingEntity {
  final String timeSlotId; // ✅ تم التعديل حسب الـ JSON
  final String? patientNotes;
  final bool grantMedicalHistoryAccess; // ✅ إضافة الحقل الجديد
  final String paymentMethod; // ✅ إضافة حقل طريقة الدفع

  BookingEntity({
    required this.timeSlotId,
    this.patientNotes,
    this.grantMedicalHistoryAccess = true, // افتراضياً موافق
    required this.paymentMethod, // ✅ تمرير طريقة الدفع
  });
}
