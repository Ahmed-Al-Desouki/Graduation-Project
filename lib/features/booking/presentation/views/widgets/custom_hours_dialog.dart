import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/modern_selector_widget.dart';
import 'package:intl/intl.dart';
import '../../manager/schedule_management_cubit/schedule_management_cubit.dart';

class CustomHoursDialog extends StatefulWidget {
  const CustomHoursDialog({super.key});

  @override
  State<CustomHoursDialog> createState() => _CustomHoursDialogState();
}

class _CustomHoursDialogState extends State<CustomHoursDialog> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 13, minute: 0);
  final reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          const Icon(Icons.timer_outlined, size: 40, color: Colors.blue),
          const SizedBox(height: 10),
          const Text(
            "Custom Work Hours",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModernSelectorWidget(
              label: "Working Date",
              value: DateFormat('EEE, dd MMM yyyy').format(selectedDate),
              icon: Icons.calendar_today,
              color: Colors.blue.shade50,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ModernSelectorWidget(
                    label: "From",
                    value: startTime.format(context),
                    icon: Icons.login,
                    color: Colors.green.shade50,
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: startTime,
                      );
                      if (picked != null) setState(() => startTime = picked);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ModernSelectorWidget(
                    label: "To",
                    value: endTime.format(context),
                    icon: Icons.logout,
                    color: Colors.red.shade50,
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: endTime,
                      );
                      if (picked != null) setState(() => endTime = picked);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: "Reason",
                prefixIcon: const Icon(Icons.edit_note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Discard", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            context.read<ScheduleManagementCubit>().setCustomHours(
              selectedDate,
              _formatTime(startTime),
              _formatTime(endTime),
              reasonController.text,
            );
            Navigator.pop(context);
          },
          child: const Text(
            "Apply Change",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) =>
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
}
