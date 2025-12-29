import 'package:flutter/material.dart';
import 'package:graduation_project/features/medical_history/domain/models/surgery_model.dart';
import 'package:intl/intl.dart';

class SurgeryCard extends StatelessWidget {
  final SurgeryModel surgery;
  final VoidCallback? onEdit; // لو null مش هيظهر الزرار
  final VoidCallback? onDelete; // لو null مش هيظهر الزرار

  const SurgeryCard({
    super.key,
    required this.surgery,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    String displayDate = "Unknown Date";
    if (surgery.date != null) {
      try {
        displayDate = DateFormat(
          'MMM dd, yyyy',
        ).format(DateTime.parse(surgery.date!));
      } catch (e) {
        displayDate = surgery.date!.split('T')[0];
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // أو White حسب المكان
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.medical_services_outlined,
                color: Color(0xFF00ACC1),
                size: 24,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surgery.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayDate,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // أزرار التحكم (Edit / Delete)
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.edit, color: Colors.blue, size: 20),
                  ),
                ),
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onDelete,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // التفاصيل الإضافية
          if ((surgery.notes != null && surgery.notes!.isNotEmpty) ||
              (surgery.complications != null &&
                  surgery.complications!.isNotEmpty)) ...[
            const Divider(height: 20),
            if (surgery.notes != null && surgery.notes!.isNotEmpty)
              Text(
                "📝 ${surgery.notes}",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            if (surgery.complications != null &&
                surgery.complications!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "⚠️ ${surgery.complications}",
                  style: const TextStyle(fontSize: 13, color: Colors.redAccent),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
