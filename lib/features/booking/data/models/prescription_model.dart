import '../../domain/entities/prescription_entity.dart';
import 'medication_item_model.dart';

class PrescriptionModel extends PrescriptionEntity {
  PrescriptionModel({
    super.prescriptionId,
    super.prescriptionNumber,
    super.issuedAt,
    super.validUntil,
    super.specialInstructions,
    required super.items,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      prescriptionId: json['prescriptionId'],
      prescriptionNumber: json['prescriptionNumber'],
      issuedAt:
          json['issuedAt'] != null ? DateTime.parse(json['issuedAt']) : null,
      validUntil:
          json['validUntil'] != null
              ? DateTime.parse(json['validUntil'])
              : null,
      specialInstructions: json['specialInstructions'],
      items:
          (json['items'] as List?)
              ?.map((e) => MedicationItemModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson(String appointmentId) {
    return {
      'appointmentId': appointmentId,
      'validUntil': validUntil?.toIso8601String(),
      'specialInstructions': specialInstructions,
      'items': items.map((e) => (e as MedicationItemModel).toJson()).toList(),
    };
  }
}
