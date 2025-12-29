import 'package:flutter/material.dart';
import 'package:graduation_project/features/medical_history/domain/models/medication_model.dart';

class MedicationCard extends StatelessWidget {
  final MedicationModel item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MedicationCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    String dateText = "";
    if (item.startDate != null) {
      dateText += "Start: ${item.startDate!.split('T')[0]}";
    }
    if (item.endDate != null) {
      if (dateText.isNotEmpty) dateText += "  |  ";
      dateText += "End: ${item.endDate!.split('T')[0]}";
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.medication, color: Colors.purple),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.isSelfMedication
                          ? Icons.person
                          : Icons.local_hospital,
                      size: 14,
                      color: item.isSelfMedication ? Colors.blue : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.medicationName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${item.dosage} • ${item.doseInstruction}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (dateText.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dateText,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    item.isSelfMedication
                        ? "Added by You"
                        : "Prescribed by Doctor",
                    style: TextStyle(
                      fontSize: 11,
                      color: item.isSelfMedication ? Colors.blue : Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Note: ${item.notes}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Actions (Edit & Delete) - Only for Self Medication
            if (item.isSelfMedication) ...[
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
