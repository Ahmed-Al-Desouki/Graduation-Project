import 'package:graduation_project/features/booking/domain/entities/medication_item_entity.dart';

class PrescriptionEntity {
  final String? prescriptionId;
  final String? prescriptionNumber; // الكود اللي بيبدأ بـ RX-
  final DateTime? issuedAt; // تاريخ الصدور
  final DateTime? validUntil; // تاريخ انتهاء الصلاحية
  final String? specialInstructions; // تعليمات خاصة من الدكتور
  final List<MedicationItemEntity> items; // قائمة الأدوية

  PrescriptionEntity({
    this.prescriptionId,
    this.prescriptionNumber,
    this.issuedAt,
    this.validUntil,
    this.specialInstructions,
    required this.items,
  });
}
