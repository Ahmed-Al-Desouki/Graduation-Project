import 'package:flutter/material.dart';
import 'package:graduation_project/features/medical_history/domain/models/family_history_model.dart';

class FamilyHistoryCard extends StatelessWidget {
  final FamilyHistoryModel item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FamilyHistoryCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.diversity_1, color: Colors.grey, size: 24),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.condition,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (item.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, size: 14, color: Colors.blue),
                    ],
                  ],
                ),
                Text(
                  "${item.relative} ${item.onsetAge != null ? '• Onset Age: ${item.onsetAge}' : ''}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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

          if (onEdit != null)
            InkWell(
              onTap: onEdit,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.edit, size: 18, color: Colors.blue),
              ),
            ),
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onDelete,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.delete_outline, size: 18, color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
