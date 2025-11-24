import 'package:flutter/material.dart';
import 'package:graduation_project/features/medical_history/domain/models/health_item_model.dart';

class HealthItemCard extends StatelessWidget {
  final HealthItem item;
  final bool isEditing;
  final VoidCallback onDelete;

  const HealthItemCard({
    super.key,
    required this.item,
    required this.isEditing,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    bool isCondition = item.type == HealthType.condition;
    Color bgColor =
        isCondition ? const Color(0xFFFFF1F2) : const Color(0xFFF5F3FF);
    Color accentColor =
        isCondition ? const Color(0xFFF43F5E) : const Color(0xFF8B5CF6);
    IconData icon = isCondition ? Icons.circle : Icons.spa;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          if (isEditing) ...[
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          Icon(icon, size: 14, color: accentColor),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
