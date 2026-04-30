import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/modern_selector_widget.dart';
import 'package:intl/intl.dart';
import '../../manager/schedule_management_cubit/schedule_management_cubit.dart';

class DayOffDialog extends StatefulWidget {
  const DayOffDialog({super.key});

  @override
  State<DayOffDialog> createState() => _DayOffDialogState();
}

class _DayOffDialogState extends State<DayOffDialog> {
  DateTime selectedDate = DateTime.now();
  final reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.orange.shade50,
            child: const Icon(
              Icons.beach_access_rounded,
              size: 35,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Set a Holiday",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ModernSelectorWidget(
            label: "Holiday Date",
            value: DateFormat('EEEE, dd MMM').format(selectedDate),
            icon: Icons.event_available,
            color: Colors.orange.shade50,
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
          TextField(
            controller: reasonController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: "Holiday Reason (Optional)",
              hintText: "e.g. Travel, Personal break...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            elevation: 0,
          ),
          onPressed: () {
            context.read<ScheduleManagementCubit>().setDayOff(
              selectedDate,
              reasonController.text,
            );
            Navigator.pop(context);
          },
          child: const Text(
            "Confirm Holiday",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
