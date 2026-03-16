import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/booking/presentation/manager/appointment_action_cubit/appointment_action_cubit.dart';
import 'package:intl/intl.dart';

class AddManualSlotSheet extends StatefulWidget {
  final DateTime selectedDate;
  final String? originalAppointmentId; // ✅ أضفنا ده
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Add Manual Slot for ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  "Start Time",
                  startTime,
                  (t) => setState(() => startTime = t),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTimePicker(
                  "End Time",
                  endTime,
                  (t) => setState(() => endTime = t),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              _onConfirm();
            },
            child: const Text("Confirm & Create"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _onConfirm() {
    // final cubit = context.read<AppointmentActionCubit>();

    // if (widget.originalAppointmentId != null) {
    //   // ✅ لو في وضع متابعة: نادى ميثود الـ bookFollowUp (الـ New Slot branch)
    //   cubit.bookFollowUp(
    //     originalId: widget.originalAppointmentId!,
    //     newDate: widget.selectedDate,
    //     startTime: _formatTime(startTime),
    //     duration: 30, // أو المدة اللي الدكتور يحددها
    //     instructions: "Manual follow-up session",
    //   );
    // } else {
    //   // 🟢 لو وضع عادي: نادى الـ addManualSlot العادية
    //   cubit.addManualSlot(
    //     date: widget.selectedDate,
    //     start: _formatTime(startTime),
    //     end: _formatTime(endTime),
    //   );
    // }
    // Navigator.pop(context);
    if (widget.originalAppointmentId != null) {
      // ✅ إحنا في وضع متابعة -> احجز ميعاد يدوي للمريض ده فوراً
      context.read<AppointmentActionCubit>().bookFollowUp(
        originalId: widget.originalAppointmentId!,
        newDate: widget.selectedDate,
        startTime: _formatTime(
          startTime,
        ), // الوقت اللي الدكتور اختاره من الـ Picker
        duration: 30,
        instructions: "Manual Follow-up",
      );
    } else {
      // 🟢 وضع عادي -> كريت سلوت فاضي بس
      context.read<AppointmentActionCubit>().addManualSlot(
        date: widget.selectedDate,
        start: _formatTime(startTime),
        end: _formatTime(endTime),
      );
    }
    Navigator.pop(context);
  }

  Widget _buildTimePicker(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onPick,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              time.format(context),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
}
