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

  // ✅ دالة سحرية لملء البيانات فور وصولها من السيرفر
  void _populateFields(ScheduleEntity schedule) {
    setState(() {
      durationController.text = schedule.slotDurationMinutes.toString();
      bufferController.text = schedule.bufferTimeMinutes.toString();
      startDate = schedule.effectiveFromDate;
      endDate = schedule.effectiveToDate;

      // تصفير الأيام أولاً
      for (var day in weeklySettings) {
        day.isEnabled = false;
      }

      // ملء الأيام بناءً على ما جاء من السيرفر
      for (var range in schedule.timeRanges) {
        int index = range.dayOfWeek;
        if (index >= 0 && index < 7) {
          weeklySettings[index].isEnabled = true;
          weeklySettings[index].startTime = _parseTimeString(range.startTime);
          weeklySettings[index].endTime = _parseTimeString(range.endTime);
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

  void _onSavePressed() {
    final enabledDays = weeklySettings.where((day) => day.isEnabled).toList();

    if (enabledDays.isEmpty) {
      showSnackBar(
        context,
        "Please enable at least one working day",
        Colors.red,
      );
      return;
    }
    final doctorId = getIt<SessionManager>().userId;
    // ✅ تجميع البيانات داخل Entity واحدة
    final schedule = ScheduleEntity(
      id: doctorId,
      templateName: "Main Doctor Schedule",
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

    // نداء الكيوبت بإرسال الـ Entity فقط
    context.read<ScheduleManagementCubit>().saveDoctorSchedule(
      schedule: schedule,
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
