import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/booking/presentation/manager/schedule_management_cubit/schedule_management_cubit.dart';
import 'day_off_dialog.dart';
import 'custom_hours_dialog.dart';
import 'reset_day_dialog.dart';

class ExceptionsSection extends StatelessWidget {
  const ExceptionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Exceptions & Holidays",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildActionItem(
              context,
              "Day Off",
              Icons.beach_access,
              Colors.orange,
              () => _showDayOffDialog(context),
            ),
            const SizedBox(width: 8),
            _buildActionItem(
              context,
              "Custom",
              Icons.timer,
              Colors.blue,
              () => _showCustomHoursDialog(context),
            ),
            const SizedBox(width: 8),
            _buildActionItem(
              context,
              "Reset",
              Icons.restart_alt,
              Colors.redAccent,
              () => _showResetDayDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: color.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDayOffDialog(BuildContext context) {
    _openDialog(context, const DayOffDialog());
  }

  void _showCustomHoursDialog(BuildContext context) {
    _openDialog(context, const CustomHoursDialog());
  }

  void _showResetDayDialog(BuildContext context) {
    _openDialog(context, const ResetDayDialog());
  }

  void _openDialog(BuildContext context, Widget dialog) {
    final cubit = context.read<ScheduleManagementCubit>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(value: cubit, child: dialog),
    );
  }
}
