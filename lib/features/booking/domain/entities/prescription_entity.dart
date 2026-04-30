import 'package:graduation_project/features/booking/domain/entities/medication_item_entity.dart';

class PrescriptionEntity {
  final String? prescriptionId;
  final String? prescriptionNumber;
  final DateTime? issuedAt;
  final DateTime? validUntil;
  final String? specialInstructions;
  final List<MedicationItemEntity> items;

  PrescriptionEntity({
    this.prescriptionId,
    this.prescriptionNumber,
    this.issuedAt,
    this.validUntil,
    this.specialInstructions,
    required this.items,
  });
}
