import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../manager/schedule_management_cubit/schedule_management_cubit.dart';
import 'modern_selector_widget.dart';

class ResetDayDialog extends StatefulWidget {
  const ResetDayDialog({super.key});

  @override
  State<ResetDayDialog> createState() => _ResetDayDialogState();
}

class _ResetDayDialogState extends State<ResetDayDialog> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.red.shade50,
            child: const Icon(
              Icons.restart_alt,
              size: 35,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Reset Day Schedule",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Select a date to remove all custom changes (Day Offs or Custom Hours) and return to your weekly schedule.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ModernSelectorWidget(
            label: "Target Date",
            value: DateFormat('EEEE, dd MMM yyyy').format(selectedDate),
            icon: Icons.calendar_month,
            color: Colors.red.shade50,
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
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          onPressed: () {
            context.read<ScheduleManagementCubit>().clearException(
              selectedDate,
            );
            Navigator.pop(context);
          },
          child: const Text(
            "Confirm Reset",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
