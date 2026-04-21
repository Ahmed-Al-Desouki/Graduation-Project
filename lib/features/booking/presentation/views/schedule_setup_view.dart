import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/booking/domain/entities/schedule_entity.dart';
import 'package:graduation_project/features/booking/presentation/manager/schedule_management_cubit/schedule_management_cubit.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/general_settings_section.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/day_settings_model.dart';
import 'package:graduation_project/features/booking/presentation/views/widgets/weekly_schedule_section.dart';
import 'package:intl/intl.dart';

class ScheduleSetupView extends StatefulWidget {
  const ScheduleSetupView({super.key});

  @override
  State<ScheduleSetupView> createState() => _ScheduleSetupViewState();
}

class _ScheduleSetupViewState extends State<ScheduleSetupView> {
  final durationController = TextEditingController();
  final bufferController = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 90));

  // قائمة الأيام (مبدئياً كلها مقفولة)
  final List<DaySettings> weeklySettings = List.generate(
    7,
    (index) => DaySettings(dayIndex: index),
  );

  @override
  void initState() {
    super.initState();
    // ✅ نداء جلب البيانات فور فتح الشاشة
    context.read<ScheduleManagementCubit>().fetchCurrentSchedule();
  }

  List<int> initiallyEnabledDays = [];
  // ✅ دالة سحرية لملء البيانات فور وصولها من السيرفر
  // void _populateFields(ScheduleEntity schedule) {
  //   setState(() {
  //     durationController.text = schedule.slotDurationMinutes.toString();
  //     bufferController.text = schedule.bufferTimeMinutes.toString();
  //     startDate = schedule.effectiveFromDate;
  //     endDate = schedule.effectiveToDate;

  //     // تصفير الأيام أولاً
  //     for (var day in weeklySettings) {
  //       day.isEnabled = false;
  //     }

  //     // ملء الأيام بناءً على ما جاء من السيرفر
  //     for (var range in schedule.timeRanges) {
  //       int index = range.dayOfWeek;
  //       if (index >= 0 && index < 7) {
  //         weeklySettings[index].isEnabled = true;
  //         weeklySettings[index].startTime = _parseTimeString(range.startTime);
  //         weeklySettings[index].endTime = _parseTimeString(range.endTime);
  //       }
  //     }
  //   });
  // }

  void _populateFields(ScheduleEntity schedule) {
    setState(() {
      durationController.text = schedule.slotDurationMinutes.toString();
      bufferController.text = schedule.bufferTimeMinutes.toString();
      startDate = schedule.effectiveFromDate;
      endDate = schedule.effectiveToDate;

      initiallyEnabledDays.clear(); // تصفير القائمة

      for (var day in weeklySettings) {
        day.isEnabled = false;
      }

      for (var range in schedule.timeRanges) {
        log("DEBUG: Range DayIndex: ${range.dayOfWeek}");
        int index = range.dayOfWeek;
        if (index >= 0 && index < 7) {
          weeklySettings[index].isEnabled = true;
          weeklySettings[index].startTime = _parseTimeString(range.startTime);
          weeklySettings[index].endTime = _parseTimeString(range.endTime);

          // ✅ سجل إن اليوم ده كان موجود فعلاً في السيرفر
          initiallyEnabledDays.add(index);
        }
      }
    });
  }

  // دالة مساعدة لتحويل "09:00" إلى TimeOfDay
  TimeOfDay _parseTimeString(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Configuration')),
      body: BlocConsumer<ScheduleManagementCubit, ScheduleManagementState>(
        listener: (context, state) {
          if (state is SlotsGeneratedSuccess) {
            context.pushReplacement(AppRouter.kDoctorSchedule);
          } else if (state is ScheduleManagementFailure) {
            showSnackBar(context, state.errMessage, Colors.red);
          }
          // ✅ أهم جزء: لما الداتا ترجع بنجاح، املأ الـ UI
          else if (state is ScheduleFetchedSuccess) {
            _populateFields(state.schedule);
          }
        },
        builder: (context, state) {
          // ✅ لو لسه بيجيب الداتا، اظهر لودينج
          if (state is ScheduleManagementLoading &&
              durationController.text.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
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

                SizedBox(height: screenHeight * 0.03),

                WeeklyScheduleSection(weeklySettings: weeklySettings),
                SizedBox(height: screenHeight * 0.03),

                // 3. ✅ إضافة قسم الاستثناءات (إجازات / ساعات خاصة)
                _buildExceptionsSection(context),
                SizedBox(height: screenHeight * 0.04),

                ElevatedButton(
                  onPressed:
                      state is ScheduleManagementLoading
                          ? null
                          : _onSavePressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, screenHeight * 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      state is ScheduleManagementLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save & Generate Slots'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // void _onSavePressed() {
  //   final enabledDays = weeklySettings.where((day) => day.isEnabled).toList();

  //   if (enabledDays.isEmpty) {
  //     showSnackBar(
  //       context,
  //       "Please enable at least one working day",
  //       Colors.red,
  //     );
  //     return;
  //   }
  //   final doctorId = getIt<SessionManager>().userId;
  //   // ✅ تجميع البيانات داخل Entity واحدة
  //   final schedule = ScheduleEntity(
  //     id: doctorId,
  //     templateName: "Main Doctor Schedule",
  //     slotDurationMinutes: int.tryParse(durationController.text) ?? 30,
  //     bufferTimeMinutes: int.tryParse(bufferController.text) ?? 5,
  //     effectiveFromDate: startDate,
  //     effectiveToDate: endDate,
  //     timeRanges:
  //         enabledDays
  //             .map(
  //               (day) => TimeRangeEntity(
  //                 dayOfWeek: day.dayIndex,
  //                 startTime: _formatTime(day.startTime),
  //                 endTime: _formatTime(day.endTime),
  //               ),
  //             )
  //             .toList(),
  //   );

  //   // نداء الكيوبت بإرسال الـ Entity فقط
  //   context.read<ScheduleManagementCubit>().saveDoctorSchedule(
  //     schedule: schedule,
  //   );
  // }

  void _onSavePressed() async {
    final cubit = context.read<ScheduleManagementCubit>();

    // 1. تحديد الأيام اللي اتمسحت (كانت enabled وبقت disabled)
    for (int dayIndex in initiallyEnabledDays) {
      if (!weeklySettings[dayIndex].isEnabled) {
        await cubit.deleteDayConfig(dayIndex);
      }
    }

    // 2. تجميع الأيام المفعلة حالياً للحفظ
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

    cubit.saveDoctorSchedule(schedule: schedule);
  }

  Widget _buildExceptionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Exceptions & Holidays",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showDayOffDialog(context),
                icon: const Icon(Icons.beach_access, color: Colors.orange),
                label: const Text("Add Day Off"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showCustomHoursDialog(context),
                icon: const Icon(Icons.timer, color: Colors.blue),
                label: const Text("Custom Hours"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCustomHoursDialog(BuildContext context) {
    final cubit = context.read<ScheduleManagementCubit>();
    DateTime selectedDate = DateTime.now();
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 13, minute: 0);
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: cubit,
            child: StatefulBuilder(
              builder:
                  (context, setDialogState) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Column(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 40,
                          color: Colors.blue,
                        ),
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
                          _buildModernSelector(
                            label: "Working Date",
                            value: DateFormat(
                              'EEE, dd MMM yyyy',
                            ).format(selectedDate),
                            icon: Icons.calendar_today,
                            color: Colors.blue.shade50,
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                setDialogState(() => selectedDate = picked);
                              }
                            },
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _buildModernSelector(
                                  label: "From",
                                  value: startTime.format(context),
                                  icon: Icons.login,
                                  color: Colors.green.shade50,
                                  onTap: () async {
                                    TimeOfDay? picked = await showTimePicker(
                                      context: context,
                                      initialTime: startTime,
                                    );
                                    if (picked != null)
                                      setDialogState(() => startTime = picked);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildModernSelector(
                                  label: "To",
                                  value: endTime.format(context),
                                  icon: Icons.logout,
                                  color: Colors.red.shade50,
                                  onTap: () async {
                                    TimeOfDay? picked = await showTimePicker(
                                      context: context,
                                      initialTime: endTime,
                                    );
                                    if (picked != null)
                                      setDialogState(() => endTime = picked);
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
                    actionsPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Discard",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          context
                              .read<ScheduleManagementCubit>()
                              .setCustomHours(
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
                  ),
            ),
          ),
    );
  }

  void _showDayOffDialog(BuildContext context) {
    final cubit = context.read<ScheduleManagementCubit>();
    DateTime selectedDate = DateTime.now();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: cubit,
            child: StatefulBuilder(
              builder:
                  (context, setDialogState) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                        _buildModernSelector(
                          label: "Holiday Date",
                          value: DateFormat(
                            'EEEE, dd MMM',
                          ).format(selectedDate),
                          icon: Icons.event_available,
                          color: Colors.orange.shade50,
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (picked != null)
                              setDialogState(() => selectedDate = picked);
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
                  ),
            ),
          ),
    );
  }

  Widget _buildModernSelector({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black54),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  // // دالة اختيار التاريخ (Start/End Date)
  // Future<void> _pickDate(bool isStart) async {
  //   DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: isStart ? startDate : endDate,
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime.now().add(const Duration(days: 365)),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       if (isStart)
  //         startDate = picked;
  //       else
  //         endDate = picked;
  //     });
  //   }
  // }
  // ابحث عن دالة _pickDate وعدلها لتصبح هكذا:
  Future<void> _pickDate(bool isStart) async {
    // 1. تحديد التاريخ اللي الكالندر هيبدأ منه (initial)
    DateTime initial = isStart ? startDate : endDate;

    // 2. تحديد "أول تاريخ مسموح" (أيهما أقرب: النهارده ولا تاريخ الجدول؟)
    // ده عشان لو الدكتور بيعدل جدول قديم، الكالندر يرضى يفتح على التاريخ القديم
    DateTime first =
        initial.isBefore(DateTime.now()) ? initial : DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first, // ✅ تم تعديله ليكون مرن
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          // حماية إضافية: لو تاريخ البداية بقى بعد النهاية، حرك النهاية معاه
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
