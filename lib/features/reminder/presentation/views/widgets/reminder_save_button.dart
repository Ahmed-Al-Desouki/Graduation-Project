import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_state.dart';

class ReminderSaveButton extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onPressed;

  const ReminderSaveButton({
    super.key,
    required this.isEditing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: BlocBuilder<ReminderCubit, ReminderState>(
        builder: (context, state) {
          return ElevatedButton(
            onPressed: state is ReminderLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                state is ReminderLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                      isEditing ? "Update Reminder" : "Save Reminder",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
          );
        },
      ),
    );
  }
}
