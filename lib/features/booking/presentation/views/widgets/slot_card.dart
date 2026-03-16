import 'package:flutter/material.dart';
import '../../../domain/entities/slot_entity.dart';

class SlotCard extends StatelessWidget {
  final SlotEntity slot;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancelByDoctor; // ✅ ميثود جديدة لكنسلة الدكتور

  final VoidCallback? onDetails;
  final VoidCallback? onDelete;
  final VoidCallback? onBlock; // ✅ ميثود جديدة للبلوك
  final bool isFollowUpMode; // ✅ لتحديد وضع المتابعة
  final VoidCallback? onBookFollowUp; // ✅ ميثود جديدة لحجز المتابعة

  const SlotCard({
    super.key,
    required this.slot,
    this.onConfirm,
    this.onCancelByDoctor, // ✅ ميثود جديدة لكنسلة الدكتور
    this.onDetails,
    this.onDelete,
    this.onBlock,
    this.isFollowUpMode = false,
    this.onBookFollowUp,
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
      case 'blocked': // حالة الحظر
      case 'cancelled': // حالة الإلغاء من الطبيب
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTimeLeading() {
    // تفكيك الوقت (مثلاً لو جاي 14:30 يحوله لـ 02:30 PM)
    final timeParts = slot.startTime.split(':');
    int hour = int.parse(timeParts[0]);
    String minute = timeParts[1];
    String period = hour >= 12 ? "PM" : "AM";

    // تحويل الساعة لنظام 12 ساعة
    int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    String formattedHour = displayHour.toString().padLeft(2, '0');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$formattedHour:$minute",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF2D3142),
          ),
        ),
        Text(
          period,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    String title = slot.status.toUpperCase();
    if (slot.patientName != null) title = slot.patientName!;
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  Widget _buildActions() {
    final String status = slot.status.toLowerCase();

    // 1. حالات "نهاية الطريق" - أحمر وبدون أكشنز
    if (status == 'cancelled' || status == 'blocked') {
      return const Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: Text(
          "No Actions",
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // ✅ لو في وضع متابعة والسلوت متاح، اظهر زرار "Book Follow-up" فقط
    if (isFollowUpMode && status == 'available') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        onPressed: onBookFollowUp,
        child: const Text(
          "Book",
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      );
    }

    switch (status) {
      case 'available':
        // 2. سلوت فاضي - يقدر يمسحه أو يقفله
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.delete_forever,
                color: Colors.red,
                size: 22,
              ),
              onPressed: onDelete,
              tooltip: 'Delete Slot',
            ),
            IconButton(
              icon: const Icon(Icons.block, color: Colors.orange, size: 22),
              onPressed: onBlock,
              tooltip: 'Block Slot',
            ),
          ],
        );

      case 'booked':
      case 'confirmed':
      case 'pending': // دمجناهم كلهم في أكشن واحد
      case 'completed':
        // 3. موعد محجوز - زرار "التفاصيل" هو البطل هنا
        // return Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     ElevatedButton(
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Colors.blue,
        //         foregroundColor: Colors.white,
        //         padding: const EdgeInsets.symmetric(horizontal: 16),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(8),
        //         ),
        //       ),
        //       onPressed: onDetails, // هنا هيروح لصفحة الـ Details
        //       child: const Text(
        //         "Details",
        //         style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        //       ),
        //     ),
        //     const SizedBox(width: 4),
        //     IconButton(
        //       icon: const Icon(
        //         Icons.cancel_outlined,
        //         color: Colors.redAccent,
        //         size: 22,
        //       ),
        //       onPressed: onCancelByDoctor,
        //       //  () {
        //       //   // نداء ميثود كنسلة الدكتور (اللي بتبلوك الموعد)
        //       //   context.read<AppointmentActionCubit>().doctorCancel(
        //       //     slot.appointmentId!,
        //       //     "Doctor Request",
        //       //   );
        //       // },
        //       tooltip: 'Cancel Appointment',
        //     ),
        //   ],
        // );
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    status == 'completed'
                        ? Colors.grey
                        : Colors.blue, // لون مختلف للتمييز
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onDetails,
              child: Text(
                status == 'completed' ? "View Report" : "Details", // نص مختلف
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (status != 'completed') ...[
              // ✅ لا تظهر زرار الكنسلة للمواعيد المنتهية
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.redAccent,
                  size: 22,
                ),
                onPressed: onCancelByDoctor,
                tooltip: 'Cancel Appointment',
              ),
            ],
          ],
        );

      case 'inprogress':
        // 4. الدكتور شغال حالياً
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple),
          ),
          child: const Text(
            "LIVE",
            style: TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        );

      default:
        return const Icon(Icons.check_circle, color: Colors.grey);
    }
  }
}
