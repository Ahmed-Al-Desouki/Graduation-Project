// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graduation_project/features/booking/presentation/manager/appointment_action_cubit/appointment_action_cubit.dart';
// import 'package:intl/intl.dart';

// class AddManualSlotSheet extends StatefulWidget {
//   final DateTime selectedDate;
//   final String? originalAppointmentId; // ✅ أضفنا ده
//   const AddManualSlotSheet({
//     super.key,
//     required this.selectedDate,
//     this.originalAppointmentId,
//   });

//   @override
//   State<AddManualSlotSheet> createState() => _AddManualSlotSheetState();
// }

// class _AddManualSlotSheetState extends State<AddManualSlotSheet> {
//   TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
//   TimeOfDay endTime = const TimeOfDay(hour: 9, minute: 30);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//         left: 20,
//         right: 20,
//         top: 20,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             "Add Manual Slot for ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}",
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildTimePicker(
//                   "Start Time",
//                   startTime,
//                   (t) => setState(() => startTime = t),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _buildTimePicker(
//                   "End Time",
//                   endTime,
//                   (t) => setState(() => endTime = t),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 30),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               minimumSize: const Size(double.infinity, 50),
//             ),
//             onPressed: () {
//               _onConfirm();
//             },
//             child: const Text("Confirm & Create"),
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   void _onConfirm() {
//     // final cubit = context.read<AppointmentActionCubit>();

//     // if (widget.originalAppointmentId != null) {
//     //   // ✅ لو في وضع متابعة: نادى ميثود الـ bookFollowUp (الـ New Slot branch)
//     //   cubit.bookFollowUp(
//     //     originalId: widget.originalAppointmentId!,
//     //     newDate: widget.selectedDate,
//     //     startTime: _formatTime(startTime),
//     //     duration: 30, // أو المدة اللي الدكتور يحددها
//     //     instructions: "Manual follow-up session",
//     //   );
//     // } else {
//     //   // 🟢 لو وضع عادي: نادى الـ addManualSlot العادية
//     //   cubit.addManualSlot(
//     //     date: widget.selectedDate,
//     //     start: _formatTime(startTime),
//     //     end: _formatTime(endTime),
//     //   );
//     // }
//     // Navigator.pop(context);
//     if (widget.originalAppointmentId != null) {
//       // ✅ إحنا في وضع متابعة -> احجز ميعاد يدوي للمريض ده فوراً
//       context.read<AppointmentActionCubit>().bookFollowUp(
//         originalId: widget.originalAppointmentId!,
//         newDate: widget.selectedDate,
//         startTime: _formatTime(
//           startTime,
//         ), // الوقت اللي الدكتور اختاره من الـ Picker
//         duration: 30,
//         instructions: "Manual Follow-up",
//       );
//     } else {
//       // 🟢 وضع عادي -> كريت سلوت فاضي بس
//       context.read<AppointmentActionCubit>().addManualSlot(
//         date: widget.selectedDate,
//         start: _formatTime(startTime),
//         end: _formatTime(endTime),
//       );
//     }
//     Navigator.pop(context);
//   }

//   Widget _buildTimePicker(
//     String label,
//     TimeOfDay time,
//     Function(TimeOfDay) onPick,
//   ) {
//     return InkWell(
//       onTap: () async {
//         final picked = await showTimePicker(
//           context: context,
//           initialTime: time,
//         );
//         if (picked != null) onPick(picked);
//       },
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             Text(
//               label,
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//             Text(
//               time.format(context),
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatTime(TimeOfDay t) =>
//       "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/booking/presentation/manager/appointment_action_cubit/appointment_action_cubit.dart';
import 'package:intl/intl.dart';

class AddManualSlotSheet extends StatefulWidget {
  final DateTime selectedDate;
  final String? originalAppointmentId;

  const AddManualSlotSheet({
    super.key,
    required this.selectedDate,
    this.originalAppointmentId,
  });

  @override
  State<AddManualSlotSheet> createState() => _AddManualSlotSheetState();
}

class _AddManualSlotSheetState extends State<AddManualSlotSheet> {
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 9, minute: 30);
  final TextEditingController instructionsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool isFollowUp = widget.originalAppointmentId != null;
    final Color themeColor =
        isFollowUp ? Colors.orange : const Color(0xFF9333EA);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1️⃣ الهيدر الشيك
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Icon(
            isFollowUp ? Icons.history_edu : Icons.add_alarm,
            size: 40,
            color: themeColor,
          ),
          const SizedBox(height: 12),
          Text(
            isFollowUp ? "Create Manual Follow-up" : "Add New Time Slot",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            DateFormat('EEEE, dd MMM yyyy').format(widget.selectedDate),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // 2️⃣ اختيار الوقت بتنسيق مودرن
          Row(
            children: [
              Expanded(
                child: _buildModernTimeTile(
                  "Starts at",
                  startTime,
                  Colors.blue.shade50,
                  () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (t != null) setState(() => startTime = t);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernTimeTile(
                  "Ends at",
                  endTime,
                  Colors.red.shade50,
                  () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (t != null) setState(() => endTime = t);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3️⃣ خانة التعليمات (بتظهر أكتر في المتابعة)
          isFollowUp
              ? TextField(
                controller: instructionsController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Follow-up Instructions",
                  prefixIcon: const Icon(Icons.notes),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              )
              : const SizedBox.shrink(),
          const SizedBox(height: 24),

          // 4️⃣ زرار التأكيد
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: _onConfirm,
            child: Text(
              isFollowUp ? "Confirm Follow-up" : "Create Slot",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _onConfirm() {
    final cubit = context.read<AppointmentActionCubit>();
    final String startStr = _formatTime(startTime);
    final String endStr = _formatTime(endTime);

    if (widget.originalAppointmentId != null) {
      // ✅ وضع المتابعة: حجز مباشر لمريض سابق
      cubit.bookFollowUp(
        originalId: widget.originalAppointmentId!,
        newDate: widget.selectedDate,
        startTime: startStr,
        duration: _calculateDuration(), // دالة لحساب المدة تلقائياً
        instructions:
            instructionsController.text.isEmpty
                ? "Manual Follow-up"
                : instructionsController.text,
      );
    } else {
      // 🟢 وضع عادي: فتح سلوت فاضي في الجدول
      cubit.addManualSlot(
        date: widget.selectedDate,
        start: startStr,
        end: endStr,
      );
    }
    Navigator.pop(context);
  }

  // ويدجت اختيار الوقت بشكل شيك
  Widget _buildModernTimeTile(
    String label,
    TimeOfDay time,
    Color bgColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00";

  int _calculateDuration() {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final diff = endMinutes - startMinutes;
    return diff > 0 ? diff : 30; // لو الوقت غلط، نثبتها 30 دقيقة
  }
}
