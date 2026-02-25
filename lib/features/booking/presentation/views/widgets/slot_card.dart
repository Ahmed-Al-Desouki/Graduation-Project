import 'package:flutter/material.dart';
import '../../../domain/entities/slot_entity.dart';

class SlotCard extends StatelessWidget {
  final SlotEntity slot;
  final VoidCallback? onConfirm;
  final VoidCallback? onStart;
  final VoidCallback? onDelete;

  const SlotCard({
    super.key,
    required this.slot,
    this.onConfirm,
    this.onStart,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: _getSlotColor().withOpacity(0.1), // لون خفيف حسب الحالة
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildTimeLeading(),
        title: _buildTitle(),
        subtitle:
            slot.patientName != null
                ? Text("Patient: ${slot.patientName}")
                : null,
        trailing: _buildActions(),
      ),
    );
  }

  // تحديد اللون بناءً على الحالة
  Color _getSlotColor() {
    switch (slot.status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'booked':
        return Colors.blue;
      case 'inprogress':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTimeLeading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          slot.startTime,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const Text(
          "AM",
          style: TextStyle(fontSize: 10),
        ), // محتاجة بارسينج للـ AM/PM
      ],
    );
  }

  Widget _buildTitle() {
    String title = slot.status.toUpperCase();
    if (slot.patientName != null) title = slot.patientName!;
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  // داخل ملف slot_card.dart - ميثود الـ _buildActions المحدثة

  Widget _buildActions() {
    final String status = slot.status.toLowerCase();

    switch (status) {
      case 'available':
        return IconButton(
          icon: const Icon(
            Icons.block_flipped,
            color: Colors.redAccent,
            size: 20,
          ),
          onPressed: onDelete, // عمل Block للسلوت
        );

      case 'pending':
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onConfirm,
          child: const Text("Confirm", style: TextStyle(fontSize: 12)),
        );

      case 'confirmed':
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onStart,
          child: const Text("Start Session", style: TextStyle(fontSize: 12)),
        );

      case 'inprogress':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple),
          ),
          child: const Text(
            "Live",
            style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
          ),
        );

      default:
        return const Icon(Icons.check_circle, color: Colors.grey);
    }
  }
}
