import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/core/widgets/tutorial_tooltip_widget.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_instance_model.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_state.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_appointment_card.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_custom_card.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_header.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_medication_card.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_section_header.dart';
import 'package:hive/hive.dart';
import 'package:showcaseview/showcaseview.dart';

class ReminderView extends StatefulWidget {
  const ReminderView({super.key});

  @override
  State<ReminderView> createState() => _ReminderViewState();
}

class _ReminderViewState extends State<ReminderView> {
  bool isHovering = false;
  final GlobalKey _viewAllKey = GlobalKey();
  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _appointmentsKey = GlobalKey();
  final GlobalKey _medicationsKey = GlobalKey();
  final GlobalKey _customsKey = GlobalKey();

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

  void _checkAndStartShowcase(BuildContext localContext) async {
    String? userId = await SecureStorageHelper.getUserId();
    if (userId != null) {
      var box =
          Hive.isBoxOpen('settings')
              ? Hive.box('settings')
              : await Hive.openBox('settings');
      String key = 'reminder_today_tutorial_shown_$userId';
      if (!box.get(key, defaultValue: false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ShowCaseWidget.of(localContext).startShowCase([
            _viewAllKey,
            _headerKey,
            _appointmentsKey,
            _medicationsKey,
            _customsKey,
          ]);
        });
        await box.put(key, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      enableAutoScroll: true,
      scrollDuration: const Duration(milliseconds: 800),
      builder: (context) {
        _checkAndStartShowcase(context);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => AppRouter.router.go(AppRouter.kHomePatient),
            ),
            actions: [
              _buildShowcase(
                key: _viewAllKey,
                step: 1,
                title: "View All Reminders",
                desc:
                    "Click here to see your full history and all scheduled reminders.",
                context: context,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: TextButton(
                    onPressed:
                        () => AppRouter.router
                            .push(
                              AppRouter.kAllReminders,
                              extra: context.read<ReminderCubit>(),
                            )
                            .then((_) => _fetchReminders()),
                    child: const Text(
                      "View All",
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                      ),
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
              if (state is ReminderLoading)
                return const Center(child: CircularProgressIndicator());
              if (state is UpcomingRemindersFailure)
                return Center(child: Text('Error: ${state.errMessage}'));

              List<ReminderInstanceModel> meds = [], appts = [], customs = [];
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
                    _buildShowcase(
                      key: _headerKey,
                      step: 2,
                      title: "Today's Schedule",
                      desc:
                          "This page only displays reminders that are due for Today.",
                      context: context,
                      child: const ReminderHeader(),
                    ),

                    _buildShowcase(
                      key: _appointmentsKey,
                      step: 3,
                      title: "Today's Appointments",
                      desc:
                          "View your doctor visits for today. Tap the '+' icon to add a new appointment reminder.",
                      context: context,
                      child: ReminderSectionHeader(
                        title: 'Appointments',
                        count: appts.length,
                        isUpcoming: true,
                        onAddPressed:
                            () => navigateToAddReminder('Appointment'),
                      ),
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

                    _buildShowcase(
                      key: _medicationsKey,
                      step: 4,
                      title: "Daily Medications",
                      desc:
                          "Track your doses for today. Use the '+' icon to schedule a new medication reminder.",
                      context: context,
                      child: ReminderSectionHeader(
                        title: 'Medication',
                        count: meds.length,
                        isUpcoming: false,
                        onAddPressed: () => navigateToAddReminder('Medication'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (meds.isEmpty)
                      const Text(
                        "No medication reminders",
                        style: TextStyle(color: Colors.grey),
                      ),
                    for (var m in meds)
                      ReminderMedicationCard(
                        title: m.title,
                        date: m.dueDateTime.split('T')[0],
                        subtitle: m.message ?? '',
                        time: formatTime(m.dueDateTime),
                        frequency: m.type,
                      ),

                    const SizedBox(height: 25),

                    _buildShowcase(
                      key: _customsKey,
                      step: 5,
                      title: "Custom Reminders",
                      desc:
                          "Any other health tasks (drinking water, etc.) appear here. Tap '+' to create a custom one.",
                      context: context,
                      child: ReminderSectionHeader(
                        title: 'Custom',
                        count: customs.length,
                        isUpcoming: false,
                        customColor: Colors.orange.shade700,
                        onAddPressed: () => navigateToAddReminder('Custom'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (customs.isEmpty)
                      const Text(
                        "No custom reminders",
                        style: TextStyle(color: Colors.grey),
                      ),
                    for (var c in customs)
                      ReminderCustomCard(
                        title: c.title,
                        date: c.dueDateTime.split('T')[0],
                        subtitle: c.message ?? '',
                        time: formatTime(c.dueDateTime),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
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

  Widget _buildShowcase({
    required GlobalKey key,
    required int step,
    required String title,
    required String desc,
    required Widget child,
    required BuildContext context,
  }) {
    return Showcase.withWidget(
      key: key,
      width: 280.w,
      container: TutorialTooltipWidget(
        title: title,
        description: desc,
        currentStep: step,
        totalSteps: 5,
        onNext:
            () =>
                step == 5
                    ? ShowCaseWidget.of(context).dismiss()
                    : ShowCaseWidget.of(context).next(),
        onSkip: () => ShowCaseWidget.of(context).dismiss(),
      ),
      height: null,
      child: child,
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
