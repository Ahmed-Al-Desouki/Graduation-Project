import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/booking/domain/entities/schedule_entity.dart';
import 'package:graduation_project/features/booking/presentation/manager/schedule_management_cubit/schedule_management_cubit.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/exceptions_section.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/general_settings_section.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/day_settings_model.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/weekly_schedule_section.dart';
import 'package:intl/intl.dart';

class ScheduleSetupView extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? followUpData;
  const ScheduleSetupView({
    super.key,
    this.isEditing = false,
    this.followUpData,
  });

  @override
  State<ScheduleSetupView> createState() => _ScheduleSetupViewState();
}

class _ScheduleSetupViewState extends State<ScheduleSetupView> {
  final durationController = TextEditingController(text: '20');
  final bufferController = TextEditingController(text: '5');
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 90));
  List<int> initiallyEnabledDays = [];

  final List<DaySettings> weeklySettings = List.generate(
    7,
    (index) => DaySettings(dayIndex: index),
  );

  @override
  void initState() {
    super.initState();
    context.read<ScheduleManagementCubit>().fetchCurrentSchedule();
  }

  void _populateFields(ScheduleEntity schedule) {
    setState(() {
      durationController.text = schedule.slotDurationMinutes.toString();
      bufferController.text = schedule.bufferTimeMinutes.toString();
      startDate = schedule.effectiveFromDate;
      endDate = schedule.effectiveToDate;

      initiallyEnabledDays.clear();

      for (var day in weeklySettings) {
        day.isEnabled = false;
      }

      for (var range in schedule.timeRanges) {
        int index = range.dayOfWeek;
        if (range.isActive) {
          weeklySettings[index].isEnabled = true;
          weeklySettings[index].startTime = _parseTimeString(range.startTime);
          weeklySettings[index].endTime = _parseTimeString(range.endTime);
          initiallyEnabledDays.add(index);
        }
      }
    });
  }

  TimeOfDay _parseTimeString(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleManagementCubit, ScheduleManagementState>(
      listener: (context, state) {
        if (state is SlotsGeneratedSuccess) {
          // context.pushReplacement(
          //   AppRouter.kBookingCalendar,
          //   extra: {'isPatientView': false, ...?widget.followUpData},
          // );
          if (Navigator.canPop(context)) {
            Navigator.pop(context, true);
          } else {
            // لو دخلت الصفحة دي كأول صفحة (زي لو السكادول مش متظبط)، استخدم go عشان تمسح الـ stack
            context.go(
              AppRouter.kBookingCalendar,
              extra: {'isPatientView': false},
            );
          }
        } else if (state is ScheduleManagementFailure) {
          showSnackBar(context, state.errMessage, Colors.red);
        } else if (state is ScheduleFetchedSuccess) {
          if (!widget.isEditing) {
            context.pushReplacement(
              AppRouter.kBookingCalendar,
              extra: {'isPatientView': false, ...?widget.followUpData},
            );
          } else {
            _populateFields(state.schedule);
          }
        }
      },
      builder: (context, state) {
        if (state is ScheduleManagementLoading ||
            (state is ScheduleManagementInitial &&
                durationController.text.isEmpty)) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ScheduleFetchedSuccess && !widget.isEditing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Schedule Configuration')),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            child: Column(
              children: [
                GeneralSettingsSection(
                  durationController: durationController,
                  bufferController: bufferController,
                  startDateText: DateFormat('yyyy-MM-dd').format(startDate),
                  endDateText: DateFormat('yyyy-MM-dd').format(endDate),
                  onStartDateTap: () => _pickDate(true),
                  onEndDateTap: () => _pickDate(false),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                WeeklyScheduleSection(weeklySettings: weeklySettings),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                const ExceptionsSection(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                _buildSaveButton(state, MediaQuery.of(context).size.height),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton(ScheduleManagementState state, double screenHeight) {
    return ElevatedButton(
      onPressed: state is ScheduleManagementLoading ? null : _onSavePressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, screenHeight * 0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child:
          state is ScheduleManagementLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Save & Generate Slots'),
    );
  }

  void _onSavePressed() async {
    if (durationController.text.trim().isEmpty ||
        bufferController.text.trim().isEmpty) {
      showSnackBar(
        context,
        "Please enter slot duration and buffer time",
        Colors.red,
      );
      return;
    }
    final cubit = context.read<ScheduleManagementCubit>();

    for (int dayIndex in initiallyEnabledDays) {
      if (!weeklySettings[dayIndex].isEnabled) {
        await cubit.deleteDayConfig(dayIndex);
      }
    }

    final enabledDays = weeklySettings.where((day) => day.isEnabled).toList();

    if (enabledDays.isEmpty) {
      showSnackBar(
        context,
        "Please enable at least one working day",
        Colors.red,
      );
      return;
    }

    final schedule = ScheduleEntity(
      id: getIt<SessionManager>().userId,
      templateName: "Main Schedule",
      slotDurationMinutes: int.tryParse(durationController.text) ?? 30,
      bufferTimeMinutes: int.tryParse(bufferController.text) ?? 5,
      effectiveFromDate: startDate,
      effectiveToDate: endDate,
      timeRanges:
          enabledDays
              .map(
                (day) => TimeRangeEntity(
                  dayOfWeek: day.dayIndex,
                  startTime: _formatTime(day.startTime),
                  endTime: _formatTime(day.endTime),
                ),
              )
              .toList(),
    );

    await cubit.saveDoctorSchedule(schedule: schedule);
    // await cubit.fetchCurrentSchedule();
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _pickDate(bool isStart) async {
    DateTime initial = isStart ? startDate : endDate;
    DateTime first =
        initial.isBefore(DateTime.now()) ? initial : DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (startDate.isAfter(endDate)) {
            endDate = startDate.add(const Duration(days: 1));
          }
        } else {
          endDate = picked;
        }
      });
    }
  }
}
