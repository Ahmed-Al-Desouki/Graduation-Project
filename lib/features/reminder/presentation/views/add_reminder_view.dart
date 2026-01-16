import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/rrule_helper.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_state.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_duration_section.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_frequency_section.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_message_section.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_save_button.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_title_section.dart';

class AddReminderView extends StatefulWidget {
  final ReminderModel? reminderToEdit;
  final String? initialType;
  const AddReminderView({super.key, this.reminderToEdit, this.initialType});

  @override
  State<AddReminderView> createState() => _AddReminderViewState();
}

class _AddReminderViewState extends State<AddReminderView> {
  static const Color kPrimaryColor = Colors.green;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController intervalController = TextEditingController();

  String selectedType = 'Medication';
  String? selectedFrequency;

  DateTime startDate = DateTime.now();
  DateTime? endDate;
  bool isLifetime = false;

  List<TimeOfDay> selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
  final Set<int> selectedWeekDays = {};
  int? selectedMonthDay;

  bool get isEditing => widget.reminderToEdit != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      selectedType = widget.initialType!;
    }
    if (isEditing) {
      _initDataForEditing();
    } else {
      endDate = DateTime.now().add(const Duration(days: 7));
    }
  }

  void _initDataForEditing() {
    try {
      final r = widget.reminderToEdit!;
      print(
        "StartDate Hour: ${r.startDate.hour}, Minute: ${r.startDate.minute}",
      );
      titleController.text = r.title;
      messageController.text = r.message ?? "";

      setState(() {
        selectedType = r.type;
        startDate = r.startDate;
        endDate = r.endDate;

        if (endDate == null ||
            endDate!.year >= 2099 ||
            (r.rrule != null && r.rrule!.contains('COUNT=1'))) {
          isLifetime = true;
          endDate = null;
        } else {
          isLifetime = false;
        }

        if (r.simple != null) {
          selectedFrequency = 'Every X Hours';
          intervalController.text = r.simple!.intervalHours.toString();
          try {
            final parts = r.simple!.firstDoseTime.split(':');
            selectedTimes = [
              TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
            ];
          } catch (_) {
            selectedTimes = [
              TimeOfDay(hour: r.startDate.hour, minute: r.startDate.minute),
            ];
          }
        } else if (r.rrule != null && r.rrule!.isNotEmpty) {
          try {
            _extractDataFromRRule(r.rrule!);
          } catch (e) {
            print("❌ RRule Parsing Error: $e");
            selectedFrequency = 'Daily';
            selectedTimes = [
              TimeOfDay(hour: r.startDate.hour, minute: r.startDate.minute),
            ];
          }
        } else {
          selectedFrequency = 'Once Only';
          selectedTimes = [
            TimeOfDay(hour: r.startDate.hour, minute: r.startDate.minute),
          ];
          isLifetime = false;
          endDate = null;
        }
      });
    } catch (e) {
      print("❌ General Initialization Error: $e");
    }
  }

  void _extractDataFromRRule(String rruleStr) {
    final String cleanRule = rruleStr.toUpperCase();

    if (cleanRule.contains('COUNT=1')) {
      selectedFrequency = 'Once Only';
    } else if (cleanRule.contains('FREQ=DAILY')) {
      selectedFrequency = 'Daily';
    } else if (cleanRule.contains('FREQ=WEEKLY')) {
      selectedFrequency = 'Weekly';
    } else if (cleanRule.contains('FREQ=MONTHLY')) {
      selectedFrequency = 'Monthly';
    } else {
      selectedFrequency = 'Daily';
    }

    final hourMatch = RegExp(r'BYHOUR=([^;]+)').firstMatch(cleanRule);
    final minuteMatch = RegExp(r'BYMINUTE=([^;]+)').firstMatch(cleanRule);

    if (hourMatch != null && minuteMatch != null) {
      final List<int> hours =
          hourMatch.group(1)!.split(',').map(int.parse).toList();
      final List<int> minutes =
          minuteMatch.group(1)!.split(',').map(int.parse).toList();

      selectedTimes = [];

      if (hours.length == minutes.length) {
        for (int i = 0; i < hours.length; i++) {
          selectedTimes.add(TimeOfDay(hour: hours[i], minute: minutes[i]));
        }
      } else if (minutes.length == 1) {
        for (int h in hours) {
          selectedTimes.add(TimeOfDay(hour: h, minute: minutes[0]));
        }
      } else if (hours.isNotEmpty && minutes.isNotEmpty) {
        selectedTimes.add(TimeOfDay(hour: hours[0], minute: minutes[0]));
      }
    } else {
      selectedTimes = [
        TimeOfDay(hour: startDate.hour, minute: startDate.minute),
      ];
    }

    if (selectedFrequency == 'Weekly') {
      final byDayMatch = RegExp(r'BYDAY=([^;]+)').firstMatch(cleanRule);
      if (byDayMatch != null) {
        final daysStr = byDayMatch.group(1)!;
        final daysCodes = daysStr.split(',');
        final daysMap = {
          'MO': 1,
          'TU': 2,
          'WE': 3,
          'TH': 4,
          'FR': 5,
          'SA': 6,
          'SU': 7,
        };

        selectedWeekDays.clear();
        for (var code in daysCodes) {
          if (daysMap.containsKey(code)) selectedWeekDays.add(daysMap[code]!);
        }
      }
    }

    if (selectedFrequency == 'Monthly') {
      final monthDayMatch = RegExp(r'BYMONTHDAY=(\d+)').firstMatch(cleanRule);
      if (monthDayMatch != null) {
        selectedMonthDay = int.parse(monthDayMatch.group(1)!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? "Edit Reminder" : "Add Reminder",
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: BlocListener<ReminderCubit, ReminderState>(
        listener: (context, state) {
          if (state is ReminderCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("✅ Reminder Added Successfully"),
                backgroundColor: kPrimaryColor,
              ),
            );
            Navigator.pop(context);
          } else if (state is ReminderUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("✅ Reminder Updated Successfully"),
                backgroundColor: kPrimaryColor,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ReminderCreateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("❌ ${state.errMessage}"),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ReminderUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("❌ ${state.errMessage}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildSectionTitle("What type of reminder?"),
              // const SizedBox(height: 10),
              // IgnorePointer(
              //   ignoring: isEditing,
              //   child: Opacity(
              //     opacity: isEditing ? 0.4 : 1.0,
              //     child: _buildSectionCard(child: _buildTypeSelector()),
              //   ),
              // ),
              // const SizedBox(height: 25),
              ReminderTitleSection(
                selectedType: selectedType,
                titleController: titleController,
              ),

              const SizedBox(height: 25),
              ReminderFrequencySection(
                selectedFrequency: selectedFrequency,
                selectedTimes: selectedTimes,
                selectedWeekDays: selectedWeekDays,
                selectedMonthDay: selectedMonthDay,
                intervalController: intervalController,
                onFrequencyChanged:
                    (newFreq) => setState(() => selectedFrequency = newFreq),
                onTimesChanged:
                    (newTimes) => setState(() => selectedTimes = newTimes),
                onWeekDaysChanged: (newDays) {
                  setState(() {
                    selectedWeekDays.clear();
                    selectedWeekDays.addAll(newDays);
                  });
                },
                onMonthDayChanged:
                    (newDay) => setState(() => selectedMonthDay = newDay),
              ),

              const SizedBox(height: 25),
              ReminderDurationSection(
                selectedFrequency: selectedFrequency,
                startDate: startDate,
                endDate: endDate,
                isLifetime: isLifetime,
                onStartDateChanged:
                    (newDate) => setState(() => startDate = newDate),
                onEndDateChanged:
                    (newDate) => setState(() => endDate = newDate),
                onLifetimeChanged:
                    (val) => setState(() {
                      isLifetime = val;
                      if (isLifetime) endDate = null;
                    }),
              ),

              const SizedBox(height: 25),
              ReminderMessageSection(messageController: messageController),

              const SizedBox(height: 30),
              ReminderSaveButton(
                isEditing: isEditing,
                onPressed: _saveReminder,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildTypeSelector() {
  //   return Column(
  //     children: [
  //       _buildTypeRow("Medication", Icons.medication, Colors.blue),
  //       const Divider(height: 10, thickness: 0.5),
  //       _buildTypeRow("Appointment", Icons.calendar_month, kPrimaryColor),
  //       const Divider(height: 10, thickness: 0.5),
  //       _buildTypeRow("Custom", Icons.notifications, Colors.orange),
  //     ],
  //   );
  // }

  // Widget _buildTypeRow(String type, IconData icon, Color color) {
  //   final isSelected = selectedType == type;
  //   return InkWell(
  //     onTap: () => setState(() => selectedType = type),
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
  //       decoration: BoxDecoration(
  //         color: isSelected ? color.withOpacity(0.05) : Colors.transparent,
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(icon, color: color, size: 28),
  //           const SizedBox(width: 15),
  //           Text(
  //             type,
  //             style: TextStyle(
  //               color: isSelected ? color : Colors.black87,
  //               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //               fontSize: 16,
  //             ),
  //           ),
  //           const Spacer(),
  //           if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  String _formatToICalString(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${dt.year}${twoDigits(dt.month)}${twoDigits(dt.day)}T${twoDigits(dt.hour)}${twoDigits(dt.minute)}${twoDigits(dt.second)}";
  }

  void _saveReminder() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please enter a title"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedFrequency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please select a frequency"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedFrequency == 'Monthly' && selectedMonthDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please select a day of the month"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (selectedFrequency == 'Every X Hours' &&
        intervalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please enter an interval"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String? patientId = await SecureStorageHelper.getUserId();
    if (patientId == null || patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Error: No Patient ID"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedFrequency == 'Weekly' && selectedWeekDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please select at least one day"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final DateTime dtStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      selectedTimes[0].hour,
      selectedTimes[0].minute,
      0,
    );

    final DateTime? endD;
    if (isLifetime) {
      endD = DateTime(2099, 12, 31, 23, 59, 59);
    } else if (selectedFrequency! == 'Once Only') {
      endD = dtStart.add(const Duration(hours: 1));
    } else {
      DateTime baseEndDate = endDate ?? startDate;
      endD = DateTime(
        baseEndDate.year,
        baseEndDate.month,
        baseEndDate.day,
        23,
        59,
        59,
      );
    }

    String? rruleString;
    SimpleModel? simple;
    String firstDoseTimeStr = "";

    if (selectedFrequency! == 'Every X Hours') {
      final int interval = int.tryParse(intervalController.text) ?? 8;
      if (interval < 1 || interval > 23) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ The interval must be between 1 and 23 hours"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      firstDoseTimeStr =
          "${selectedTimes[0].hour.toString().padLeft(2, '0')}:${selectedTimes[0].minute.toString().padLeft(2, '0')}:00";

      simple = SimpleModel(
        intervalHours: interval,
        firstDoseTime: firstDoseTimeStr,
      );
    } else if (selectedFrequency! == 'Once Only') {
      rruleString = "FREQ=DAILY;COUNT=1";
    } else {
      rruleString = buildRRuleString();
    }

    String? finalRRuleToSend;
    if (rruleString != null) {
      finalRRuleToSend =
          "DTSTART:${_formatToICalString(dtStart)}\nRRULE:$rruleString";
    } else if (selectedFrequency! == 'Once Only') {
      finalRRuleToSend = "DTSTART:${_formatToICalString(dtStart)}";
    }

    if (mounted) {
      if (isEditing) {
        context.read<ReminderCubit>().updateReminder(
          patientId: patientId,
          reminderId: widget.reminderToEdit!.reminderId!,
          title: titleController.text.trim(),
          startDate: dtStart,
          endDate: endD,

          rrule: finalRRuleToSend,
          simple: simple,
          message: messageController.text.trim(),
          isEveryXHours: selectedFrequency! == 'Every X Hours',
        );
      } else {
        context.read<ReminderCubit>().createReminder(
          patientId: patientId,
          type: selectedType,
          title: titleController.text.trim(),
          message: messageController.text.trim(),
          startDate: dtStart,
          endDate: endD,
          rrule: finalRRuleToSend,
          simple: simple,
        );
      }
    }

    print("✅ Sending RRule: $finalRRuleToSend");
    print("✅ Sending reminder (Edit Mode: $isEditing)");
    print("✅ Sending reminder:");
    print("  Type: $selectedType");
    print("  Title: ${titleController.text}");
    print("  RRULE: $rruleString");
    print("  Simple: ${simple?.toJson()}");
    print("  Start: $dtStart");
    print("  End: $endD");
  }

  String buildRRuleString() {
    if (selectedTimes.isEmpty || selectedFrequency == null) return "";

    final List<int> hours = selectedTimes.map((t) => t.hour).toList();
    final List<int> minutes = selectedTimes.map((t) => t.minute).toList();

    final DateTime? untilDate =
        (!isLifetime && endDate != null)
            ? DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59)
            : null;

    switch (selectedFrequency!) {
      case 'Daily':
        return RRuleHelper.buildDaily(
          hours: hours,
          minutes: minutes,
          until: untilDate,
        );

      case 'Weekly':
        return RRuleHelper.buildWeekly(
          weekDays: selectedWeekDays,
          hours: hours,
          minutes: minutes,
          until: untilDate,
        );

      case 'Monthly':
        return RRuleHelper.buildMonthly(
          monthDay: selectedMonthDay!,
          hours: hours,
          minutes: minutes,
          until: untilDate,
        );

      default:
        return RRuleHelper.buildDaily(
          hours: hours,
          minutes: minutes,
          until: untilDate,
        );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    intervalController.dispose();
    super.dispose();
  }
}
