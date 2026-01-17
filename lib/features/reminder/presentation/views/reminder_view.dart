import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_instance_model.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_state.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_appointment_card.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_custom_card.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_header.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_medication_card.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_section_header.dart';

class ReminderView extends StatefulWidget {
  const ReminderView({super.key});

  @override
  State<ReminderView> createState() => _ReminderViewState();
}

class _ReminderViewState extends State<ReminderView> {
  bool isHovering = false;

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    final patientId = await SecureStorageHelper.getUserId();
    print("DEBUG: Fetched Patient ID is: $patientId");
    if (patientId != null && patientId.isNotEmpty && mounted) {
      context.read<ReminderCubit>().getTodayReminders(patientId: patientId);
    } else {
      print("DEBUG: patientId is invalid or missing, cannot fetch reminders.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            AppRouter.router.go(AppRouter.kHomePatient);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: () {
                AppRouter.router
                    .push(
                      AppRouter.kAllReminders,
                      extra: context.read<ReminderCubit>(),
                    )
                    .then((_) => _fetchReminders());
              },
              child: const Text(
                "View All",
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ReminderCubit, ReminderState>(
        listener: (context, state) {
          if (state is ReminderCreateSuccess ||
              state is ReminderUpdateSuccess ||
              state is ReminderDeleteSuccess) {
            _fetchReminders();
          }
        },
        builder: (context, state) {
          if (state is ReminderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UpcomingRemindersFailure) {
            return Center(child: Text('Error: ${state.errMessage}'));
          }

          List<ReminderInstanceModel> meds = [];
          List<ReminderInstanceModel> appts = [];
          List<ReminderInstanceModel> customs = [];

          if (state is UpcomingRemindersSuccess) {
            meds = state.medications;
            appts = state.appointments;
            customs = state.customs;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const ReminderHeader(),

                ReminderSectionHeader(
                  title: 'Appointments',
                  count: appts.length,
                  isUpcoming: true,
                  onAddPressed: () => navigateToAddReminder('Appointment'),
                ),
                const SizedBox(height: 10),

                if (appts.isEmpty)
                  const Text(
                    "No upcoming appointments",
                    style: TextStyle(color: Colors.grey),
                  ),

                for (var appt in appts)
                  ReminderAppointmentCard(
                    name: appt.title,
                    subtitle: appt.message ?? '',
                    date: appt.dueDateTime.split('T')[0],
                    time: formatTime(appt.dueDateTime),
                  ),

                const SizedBox(height: 25),

                ReminderSectionHeader(
                  title: 'Medication',
                  count: meds.length,
                  isUpcoming: false,
                  onAddPressed: () => navigateToAddReminder('Medication'),
                ),
                const SizedBox(height: 10),

                if (meds.isEmpty)
                  const Text(
                    "No medication reminders",
                    style: TextStyle(color: Colors.grey),
                  ),

                for (var reminder in meds)
                  ReminderMedicationCard(
                    title: reminder.title,
                    date: reminder.dueDateTime.split('T')[0],
                    subtitle: reminder.message ?? '',
                    time: formatTime(reminder.dueDateTime),
                    frequency: reminder.type,
                  ),

                const SizedBox(height: 25),

                ReminderSectionHeader(
                  title: 'Custom',
                  count: customs.length,
                  isUpcoming: false,
                  customColor: Colors.orange.shade700,
                  onAddPressed: () => navigateToAddReminder('Custom'),
                ),
                const SizedBox(height: 10),

                if (customs.isEmpty)
                  const Text(
                    "No custom reminders",
                    style: TextStyle(color: Colors.grey),
                  ),

                for (var custom in customs)
                  ReminderCustomCard(
                    title: custom.title,
                    date: custom.dueDateTime.split('T')[0],
                    subtitle: custom.message ?? '',
                    time: formatTime(custom.dueDateTime),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      // floatingActionButton: Container(
      //   width: 60,
      //   height: 60,
      //   decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(10),
      //     gradient: const LinearGradient(
      //       colors: [Color.fromARGB(255, 4, 249, 12), Color(0xFF1B4E8C)],
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //     ),
      //   ),
      //   child: FloatingActionButton(
      //     elevation: 0,
      //     backgroundColor: Colors.transparent,
      //     onPressed: () async {
      //       await Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder:
      //               (_) => BlocProvider.value(
      //                 value: context.read<ReminderCubit>(),
      //                 child: const AddReminderView(),
      //               ),
      //         ),
      //       );
      //       _fetchReminders();
      //     },
      //     child: const Icon(Icons.add, color: Colors.white, size: 30),
      //   ),
      // ),
    );
  }

  void navigateToAddReminder(String type) {
    AppRouter.router
        .push(
          AppRouter.kAddReminder,
          extra: {'cubit': context.read<ReminderCubit>(), 'initialType': type},
        )
        .then((_) => _fetchReminders());
  }

  String formatTime(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "--:--";
    }
  }
}
