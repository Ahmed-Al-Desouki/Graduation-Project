import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/booking/domain/entities/medication_item_entity.dart';

class MedicationItemCard extends StatelessWidget {
  final MedicationItemEntity item;
  final bool hideDelete;
  final VoidCallback? onDelete;

  const MedicationItemCard({
    super.key,
    required this.item,
    required this.hideDelete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF3E8FF),
                child: Icon(Icons.medication, color: Color(0xFF9333EA)),
              ),
              title: Text(
                item.medicationName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text("Quantity: ${item.quantity} units"),
              trailing:
                  hideDelete
                      ? null
                      : IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: onDelete,
                      ),
            ),
            const Divider(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: [
                _buildDetailItem(Icons.shutter_speed, item.dosage),
                _buildDetailItem(Icons.calendar_today, item.duration),
                _buildDetailItem(
                  Icons.repeat,
                  _getFrequencyName(item.reminderFrequencyType),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: Colors.grey),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 12.sp, color: Colors.black87)),
    ],
  );

  String _getFrequencyName(int type) {
    switch (type) {
      case 0:
        return "Once";
      case 1:
        return "Daily";
      case 2:
        return "Weekly";
      case 3:
        return "Monthly";
      case 4:
        return "Every X Hours";
      default:
        return "As prescribed";
    }
  }
}
