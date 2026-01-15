import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/rrule_helper.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_state.dart';

class AddReminderView extends StatefulWidget {
  // ✅ إضافة متغير لاستقبال الريمندر في حالة التعديل
  final ReminderModel? reminderToEdit;
  // ✅ إضافة جديدة: متغير للنوع الابتدائي (لو من زر فئة معينة)
  final String? initialType;

  // const AddReminderView({super.key, this.reminderToEdit});
  const AddReminderView({super.key, this.reminderToEdit, this.initialType});

  @override
  State<AddReminderView> createState() => _AddReminderViewState();
}

class _AddReminderViewState extends State<AddReminderView> {
  static const Color kPrimaryColor = Colors.green;
  static const Color kCardBackgroundColor = Color(0xffE8F7F2);
  static const Color kFieldBackgroundColor = Color(0xFFF8F9FA);

  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController intervalController = TextEditingController();

  String selectedType = 'Medication';
  String selectedFrequency = 'Daily';

  DateTime startDate = DateTime.now();
  DateTime? endDate;
  bool isLifetime = false;

  List<TimeOfDay> selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
  final Set<int> selectedWeekDays = {};
  int selectedMonthDay = 1;

  // ✅ هل نحن في وضع التعديل؟
  bool get isEditing => widget.reminderToEdit != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      selectedType = widget.initialType!; // ✅ حدد النوع الابتدائي لو موجود
    }
    if (isEditing) {
      _initDataForEditing(); // 🔹 ملء البيانات في حالة التعديل
    } else {
      endDate = DateTime.now().add(const Duration(days: 7));
    }
  }

  // // 🔹 دالة لملء الحقول عند التعديل
  // void _initDataForEditing() {
  //   final r = widget.reminderToEdit!;
  //   titleController.text = r.title;
  //   messageController.text = r.message ?? "";
  //   selectedType = r.type; // سيتم قفل تغييره في الـ UI
  //   startDate = r.startDate;
  //   endDate = r.endDate;

  //   // محاولة استنتاج التكرار والأوقات
  //   if (r.simple != null) {
  //     selectedFrequency = 'Every X Hours';
  //     intervalController.text = r.simple!.intervalHours.toString();
  //     // استخراج وقت الجرعة الأولى
  //     try {
  //       final parts = r.simple!.firstDoseTime.split(':');
  //       selectedTimes = [TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]))];
  //     } catch (_) {}
  //   } else if (r.rrule != null) {
  //     // تحليل بسيط للـ RRULE (الأفضل استخدام RRule.fromString لو متاح)
  //     if (r.rrule!.contains('WEEKLY')) {
  //       selectedFrequency = 'Weekly';
  //       // هنا المفروض نستخرج الأيام المختارة من الـ RRULE String
  //       // (للتبسيط سنتركها فارغة أو نعتمد على startDate)
  //     } else if (r.rrule!.contains('MONTHLY')) {
  //       selectedFrequency = 'Monthly';
  //     } else {
  //       selectedFrequency = 'Daily';
  //     }

  //     // استخراج الوقت (أيضاً يحتاج RRule Parsing، سنستخدم وقت البداية مؤقتاً)
  //     selectedTimes = [TimeOfDay(hour: r.startDate.hour, minute: r.startDate.minute)];
  //   }
  // }
  // 🔹 دالة محسّنة لملء الحقول عند التعديل
  // 🔹 دالة محسّنة لملء الحقول عند التعديل
  // void _initDataForEditing() {
  //   final r = widget.reminderToEdit!;
  //   print("DEBUG: Editing Reminder -> Title: ${r.title}, Message: ${r.message}");
  //   // 1. البيانات النصية
  //   titleController.text = r.title;
  //   messageController.text = r.message ?? "";
  //   selectedType = r.type;

  //   // 2. التواريخ
  //   startDate = r.startDate;
  //   endDate = r.endDate;

  //   // تحديد Lifetime
  //   if (endDate == null || endDate!.year >= 2099) {
  //     isLifetime = true;
  //     endDate = null;
  //   } else {
  //     isLifetime = false;
  //   }

  //   // 3. معالجة التكرار والوقت
  //   if (r.simple != null) {
  //     // ✅ حالة Simple (Every X Hours)
  //     selectedFrequency = 'Every X Hours';
  //     intervalController.text = r.simple!.intervalHours.toString();
  //     try {
  //       final parts = r.simple!.firstDoseTime.split(':');
  //       selectedTimes = [TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]))];
  //     } catch (_) {
  //       selectedTimes = [TimeOfDay(hour: r.startDate.hour, minute: r.startDate.minute)];
  //     }
  //   } else if (r.rrule != null && r.rrule!.isNotEmpty) {
  //     // ✅ حالة RRULE (استخدام RRuleHelper)
  //     _extractDataFromRRule(r.rrule!);
  //   } else {
  //     // ✅ حالة Once Only (أو Fallback)
  //     selectedFrequency = 'Once Only';
  //     selectedTimes = [TimeOfDay(hour: r.startDate.hour, minute: r.startDate.minute)];
  //   }
  // }
  // void _initDataForEditing() {
  //   try {
  //     final r = widget.reminderToEdit!;

  //     // 1. ملء الحقول النصية (خارج setState لضمان السرعة)
  //     titleController.text = r.title;
  //     messageController.text = r.message ?? "";

  //     // 2. تحديث باقي المتغيرات داخل setState عشان الـ UI يحس بيهم
  //     setState(() {
  //       selectedType = r.type;
  //       startDate = r.startDate;
  //       endDate = r.endDate;

  //       // تحديد هل هو Lifetime
  //       if (endDate == null || endDate!.year >= 2099) {
  //         isLifetime = true;
  //         endDate = null;
  //       } else {
  //         isLifetime = false;
  //       }

  //       // 3. معالجة التكرار والوقت بحذر
  //       if (r.simple != null) {
  //         selectedFrequency = 'Every X Hours';
  //         intervalController.text = r.simple!.intervalHours.toString();
  //         try {
  //           final parts = r.simple!.firstDoseTime.split(':');
  //           selectedTimes = [
  //             TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
  //           ];
  //         } catch (_) {
  //           selectedTimes = [
  //             TimeOfDay(hour: r.startDate.hour, minute: r.startDate.minute),
  //           ];
  //         }
  //       } else if (r.rrule != null && r.rrule!.isNotEmpty) {
  //         // نغلف الـ RRule Parsing بالذات عشان لو فشل ميعطلش الباقي
  //         try {
  //           _extractDataFromRRule(r.rrule!);
  //         } catch (e) {
  //           print("RRule Parsing Error: $e");
  //           selectedFrequency = 'Daily'; // Fallback
  //         }
  //       } else {
  //         selectedFrequency = 'Once Only';
  //         selectedTimes = [
  //           TimeOfDay(hour: r.startDate.hour, minute: r.startDate.minute),
  //         ];
  //       }
  //     });
  //   } catch (e) {
  //     print("General Initialization Error: $e");
  //   }
  // }
  void _initDataForEditing() {
    try {
      final r = widget.reminderToEdit!;
      print(
        "StartDate Hour: ${r.startDate.hour}, Minute: ${r.startDate.minute}",
      );
      // 1. ملء الحقول النصية
      titleController.text = r.title;
      messageController.text = r.message ?? "";

      setState(() {
        selectedType = r.type;
        startDate = r.startDate;
        endDate = r.endDate;

        // تحديد Lifetime - أضف تحقق إضافي لـ Once Only
        if (endDate == null ||
            endDate!.year >= 2099 ||
            (r.rrule != null && r.rrule!.contains('COUNT=1'))) {
          isLifetime = true;
          endDate = null;
        } else {
          isLifetime = false;
        }

        // 2. معالجة التكرار والوقت
        if (r.simple != null) {
          // --- حالة Simple (Every X Hours) ---
          selectedFrequency = 'Every X Hours';
          intervalController.text = r.simple!.intervalHours.toString();
          try {
            final parts = r.simple!.firstDoseTime.split(':');
            selectedTimes = [
              TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
            ];
          } catch (_) {
            // ✅ تعديل: أزل toLocal()، استخدم hour/minute مباشرة (الآن local)
            selectedTimes = [
              TimeOfDay(hour: r.startDate.hour, minute: r.startDate.minute),
            ];
          }
        } else if (r.rrule != null && r.rrule!.isNotEmpty) {
          // --- حالة RRULE (Daily, Weekly, Monthly, Once Only) ---
          try {
            _extractDataFromRRule(r.rrule!);
          } catch (e) {
            print("❌ RRule Parsing Error: $e");
            selectedFrequency = 'Daily'; // Fallback
            // ✅ تعديل: أزل toLocal()، استخدم hour/minute مباشرة
            selectedTimes = [
              TimeOfDay(hour: r.startDate.hour, minute: r.startDate.minute),
            ];
          }
        } else {
          // --- حالة Once Only (Fallback إذا مش لاقي rrule أو simple) ---
          selectedFrequency = 'Once Only';
          // ✅ تعديل: أزل toLocal()، استخدم hour/minute مباشرة
          selectedTimes = [
            TimeOfDay(hour: r.startDate.hour, minute: r.startDate.minute),
          ];
          isLifetime = false; // Once Only ليس Lifetime
          endDate = null; // أو اجعله يساوي startDate إذا كان مطلوب
        }
      });
    } catch (e) {
      print("❌ General Initialization Error: $e");
    }
  }

  // 🔹 دالة مساعدة جديدة لاستخراج البيانات باستخدام RRuleHelper
  // void _extractDataFromRRule(String rruleStr) {
  //   // 1. استخراج التردد
  //   String freq = RRuleHelper.getFrequency(
  //     rruleStr,
  //   ); // تأكد ان الدالة دي public في Helper
  //   // توحيد المسميات مع الـ UI
  //   if (freq == 'Daily')
  //     selectedFrequency = 'Daily';
  //   else if (freq == 'Weekly')
  //     selectedFrequency = 'Weekly';
  //   else if (freq == 'Monthly')
  //     selectedFrequency = 'Monthly';
  //   else if (rruleStr.contains('COUNT=1'))
  //     selectedFrequency = 'Once Only';
  //   else
  //     selectedFrequency = 'Daily'; // Default

  //   // 2. استخراج الأوقات (Hours & Minutes)
  //   // RRuleHelper.getHour بيرجع ساعة واحدة، لو عندك دالة تجيب لستة يفضل استخدامها
  //   // لو مفيش، هنستخدم Regex بسيط هنا لدعم Multiple Times لو الـ Helper مش بيدعمها
  //   try {
  //     final hourMatch = RegExp(r'BYHOUR=([\d,]+)').firstMatch(rruleStr);
  //     final minuteMatch = RegExp(r'BYMINUTE=([\d,]+)').firstMatch(rruleStr);

  //     if (hourMatch != null && minuteMatch != null) {
  //       final hours = hourMatch.group(1)!.split(',').map(int.parse).toList();
  //       final minutes =
  //           minuteMatch.group(1)!.split(',').map(int.parse).toList();

  //       selectedTimes = [];
  //       // لو الدقائق واحدة لكل الساعات (السيناريو الشائع)
  //       if (minutes.length == 1) {
  //         for (var h in hours) {
  //           selectedTimes.add(TimeOfDay(hour: h, minute: minutes[0]));
  //         }
  //       } else if (hours.length == minutes.length) {
  //         for (int i = 0; i < hours.length; i++) {
  //           selectedTimes.add(TimeOfDay(hour: hours[i], minute: minutes[i]));
  //         }
  //       }
  //     } else {
  //       // Fallback: استخدام getHour من Helper لو الـ Regex فشل
  //       int? h = RRuleHelper.getHour(rruleStr);
  //       int? m = RRuleHelper.getMinute(rruleStr);
  //       if (h != null && m != null) {
  //         selectedTimes = [TimeOfDay(hour: h, minute: m)];
  //       }
  //     }
  //   } catch (e) {
  //     print("Error parsing times: $e");
  //     // Fallback لوقت البداية
  //     selectedTimes = [
  //       TimeOfDay(hour: startDate.hour, minute: startDate.minute),
  //     ];
  //   }

  //   // 3. استخراج الأيام (للـ Weekly)
  //   if (selectedFrequency == 'Weekly') {
  //     Set<int>? days = RRuleHelper.getWeekDays(rruleStr);
  //     if (days != null) {
  //       selectedWeekDays.clear();
  //       selectedWeekDays.addAll(days);
  //     }
  //   }

  //   // 4. استخراج يوم الشهر (للـ Monthly)
  //   if (selectedFrequency == 'Monthly') {
  //     // حاول استخراج BYMONTHDAY
  //     final match = RegExp(r'BYMONTHDAY=(\d+)').firstMatch(rruleStr);
  //     if (match != null) {
  //       selectedMonthDay = int.parse(match.group(1)!);
  //     }
  //   }
  // }
  //   void _extractDataFromRRule(String rruleStr) {
  //   // تنظيف النص من أي زيادات
  //   final String cleanRule = rruleStr.toUpperCase();

  //   setState(() {
  //     // 1. استخراج التردد (Frequency)
  //     if (cleanRule.contains('FREQ=DAILY')) {
  //       selectedFrequency = 'Daily';
  //     } else if (cleanRule.contains('FREQ=WEEKLY')) {
  //       selectedFrequency = 'Weekly';
  //     } else if (cleanRule.contains('FREQ=MONTHLY')) {
  //       selectedFrequency = 'Monthly';
  //     } else if (cleanRule.contains('COUNT=1')) {
  //       selectedFrequency = 'Once Only';
  //     }

  //     // 2. استخراج الساعة والدقيقة باستخدام Regex (أضمن طريقة)
  //     final hourMatch = RegExp(r'BYHOUR=(\d+)').firstMatch(cleanRule);
  //     final minuteMatch = RegExp(r'BYMINUTE=(\d+)').firstMatch(cleanRule);

  //     if (hourMatch != null && minuteMatch != null) {
  //       int h = int.parse(hourMatch.group(1)!);
  //       int m = int.parse(minuteMatch.group(1)!);
  //       selectedTimes = [TimeOfDay(hour: h, minute: m)];
  //     } else {
  //       // Fallback لوقت بداية الريمندر الأصلي
  //       selectedTimes = [TimeOfDay(hour: startDate.hour, minute: startDate.minute)];
  //     }

  //     // 3. استخراج أيام الأسبوع (للـ Weekly)
  //     if (selectedFrequency == 'Weekly') {
  //       final byDayMatch = RegExp(r'BYDAY=([^;]+)').firstMatch(cleanRule);
  //       if (byDayMatch != null) {
  //         final daysStr = byDayMatch.group(1)!;
  //         final daysCodes = daysStr.split(',');
  //         final daysMap = {'MO': 1, 'TU': 2, 'WE': 3, 'TH': 4, 'FR': 5, 'SA': 6, 'SU': 7};

  //         selectedWeekDays.clear();
  //         for (var code in daysCodes) {
  //           if (daysMap.containsKey(code)) selectedWeekDays.add(daysMap[code]!);
  //         }
  //       }
  //     }

  //     // 4. استخراج يوم الشهر (للـ Monthly)
  //     if (selectedFrequency == 'Monthly') {
  //       final monthDayMatch = RegExp(r'BYMONTHDAY=(\d+)').firstMatch(cleanRule);
  //       if (monthDayMatch != null) {
  //         selectedMonthDay = int.parse(monthDayMatch.group(1)!);
  //       }
  //     }
  //   });
  // }
  void _extractDataFromRRule(String rruleStr) {
    final String cleanRule = rruleStr.toUpperCase();

    // 1. استخراج التردد (Frequency) - ضع COUNT=1 أولاً لمسك Once Only
    if (cleanRule.contains('COUNT=1')) {
      selectedFrequency = 'Once Only';
    } else if (cleanRule.contains('FREQ=DAILY')) {
      selectedFrequency = 'Daily';
    } else if (cleanRule.contains('FREQ=WEEKLY')) {
      selectedFrequency = 'Weekly';
    } else if (cleanRule.contains('FREQ=MONTHLY')) {
      selectedFrequency = 'Monthly';
    } else {
      selectedFrequency = 'Daily'; // Fallback
    }

    // 2. استخراج الأوقات (يدعم التعدد) - مع fallback أفضل
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
        // حالة نادرة: استخدم أول قيمة
        selectedTimes.add(TimeOfDay(hour: hours[0], minute: minutes[0]));
      }
    } else {
      // Fallback إذا مش لاقي BYHOUR/BYMINUTE (شائع في Once Only)
      // ✅ تعديل: أزل toLocal()، استخدم hour/minute مباشرة
      selectedTimes = [
        TimeOfDay(hour: startDate.hour, minute: startDate.minute),
      ];
    }

    // 3. استخراج أيام الأسبوع (للـ Weekly)
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

    // 4. استخراج يوم الشهر (للـ Monthly)
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
            Navigator.pop(context, true); // إرجاع true لتحديث القائمة السابقة
          } else if (state is ReminderCreateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("❌ ${state.errMessage}"),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ReminderUpdateFailure) {
            // ✅ حالة فشل التعديل
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
              // // ✅ منع تغيير النوع أثناء التعديل
              // IgnorePointer(
              //   ignoring: isEditing,
              //   child: Opacity(
              //     opacity: isEditing ? 0.4 : 1.0,
              //     child: _buildSectionCard(child: _buildTypeSelector()),
              //   ),
              // ),
              // const SizedBox(height: 25),
              _buildSectionTitle("Reminder Title"),
              const SizedBox(height: 10),
              _buildSectionCard(child: _buildTitleField()),

              const SizedBox(height: 25),
              _buildSectionTitle("When do you take this?"),
              const SizedBox(height: 10),
              _buildSectionCard(
                child: Column(
                  children: [
                    _buildFrequencySelector(),
                    const Divider(height: 25, thickness: 1),
                    _buildFrequencyOptions(),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              _buildSectionTitle("Duration"),
              const SizedBox(height: 10),
              _buildSectionCard(child: _buildDurationSection()),

              const SizedBox(height: 25),
              _buildSectionTitle("Message (Optional)"),
              const SizedBox(height: 10),
              _buildSectionCard(child: _buildMessageField()),

              const SizedBox(height: 30),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      color: kCardBackgroundColor,
      child: Padding(padding: const EdgeInsets.all(15.0), child: child),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: kPrimaryColor,
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

  Widget _buildTitleField() {
    String hint = "Reminder Title";
    IconData icon = Icons.edit;
    if (selectedType == 'Medication') {
      hint = "e.g. Panadol 500mg";
      icon = Icons.medication_liquid;
    } else if (selectedType == 'Appointment') {
      hint = "e.g. Dentist Checkup";
      icon = Icons.person;
    } else if (selectedType == 'Custom') {
      hint = "e.g. Check blood pressure";
      icon = Icons.notifications;
    }

    return TextField(
      controller: titleController,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: kFieldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    final options = [
      "Once Only",
      "Daily",
      "Weekly",
      "Monthly",
      "Every X Hours",
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          options.map((option) {
            final isSelected = selectedFrequency == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => setState(() => selectedFrequency = option),
              selectedColor: kPrimaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              backgroundColor: kFieldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildFrequencyOptions() {
    switch (selectedFrequency) {
      case 'Daily':
        return _buildTimeSelector();
      case 'Weekly':
        return _buildWeeklySelector();
      case 'Monthly':
        return _buildMonthlySelector();
      case 'Every X Hours':
        return _buildEveryXHoursSelector();
      case 'Once Only':
        return _buildTimeSelector();
      default:
        return const SizedBox.shrink();
    }
  }

  // ✅ تعديل 2: دعم Add Time في Daily, Weekly, Monthly
  Widget _buildTimeSelector() {
    // ✅ Add Time متاح في Daily, Weekly, Monthly
    final bool canAddTime =
        selectedFrequency == 'Daily' ||
        selectedFrequency == 'Weekly' ||
        selectedFrequency == 'Monthly';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Time:",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        _buildTimeList(
          times: selectedTimes,
          canAdd: canAddTime,
          onChanged: (newTimes) {
            setState(() {
              selectedTimes = newTimes;
            });
          },
        ),
      ],
    );
  }

  // ✅ Widget لعرض قائمة الأوقات وزر الإضافة (من الكود القديم)
  Widget _buildTimeList({
    required List<TimeOfDay> times,
    required bool canAdd,
    required Function(List<TimeOfDay>) onChanged,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...List.generate(times.length, (index) {
          return _buildTimeChip(
            time: times[index],
            onSelect: (newTime) {
              List<TimeOfDay> updatedList = List.from(times);
              updatedList[index] = newTime;
              onChanged(updatedList);
            },
            onDelete:
                canAdd && times.length > 1
                    ? () {
                      List<TimeOfDay> updatedList = List.from(times);
                      updatedList.removeAt(index);
                      onChanged(updatedList);
                    }
                    : null,
          );
        }),
        if (canAdd)
          InkWell(
            onTap: () {
              List<TimeOfDay> updatedList = List.from(times);
              updatedList.add(const TimeOfDay(hour: 8, minute: 0));
              onChanged(updatedList);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: kPrimaryColor),
                borderRadius: BorderRadius.circular(8),
                color: kPrimaryColor.withOpacity(0.1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, size: 18, color: kPrimaryColor),
                  SizedBox(width: 5),
                  Text(
                    "Add Time",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeChip({
    required TimeOfDay time,
    required Function(TimeOfDay) onSelect,
    VoidCallback? onDelete,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) onSelect(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: kFieldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time.format(context),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.access_time, size: 16, color: Colors.grey),
            if (onDelete != null) ...[
              const SizedBox(width: 10),
              InkWell(
                onTap: onDelete,
                child: const Icon(Icons.close, size: 16, color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySelector() {
    const daysMap = {
      DateTime.saturday: 'Saturday',
      DateTime.sunday: 'Sunday',
      DateTime.monday: 'Monday',
      DateTime.tuesday: 'Tuesday',
      DateTime.wednesday: 'Wednesday',
      DateTime.thursday: 'Thursday',
      DateTime.friday: 'Friday',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Days:",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        ...daysMap.entries.map((entry) {
          final dayNum = entry.key;
          final dayName = entry.value;
          final isSelected = selectedWeekDays.contains(dayNum);

          return CheckboxListTile(
            title: Text(dayName),
            value: isSelected,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  selectedWeekDays.add(dayNum);
                } else {
                  selectedWeekDays.remove(dayNum);
                }
              });
            },
            activeColor: kPrimaryColor,
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        }),
        const SizedBox(height: 10),
        // ✅ استخدام نفس الـ widget مع Add Time
        _buildTimeSelector(),
      ],
    );
  }

  Widget _buildMonthlySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Day of Month:",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(31, (index) {
            final day = index + 1;
            final isSelected = selectedMonthDay == day;

            return ChoiceChip(
              label: Text('$day'),
              selected: isSelected,
              onSelected: (_) {
                setState(() => selectedMonthDay = day);
              },
              selectedColor: kPrimaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }),
        ),
        const SizedBox(height: 15),
        // ✅ استخدام نفس الـ widget مع Add Time
        _buildTimeSelector(),
      ],
    );
  }

  Widget _buildEveryXHoursSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Interval (hours):",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: intervalController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "e.g. 8",
            filled: true,
            fillColor: kFieldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          "First Dose Time:",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: selectedTimes[0],
            );
            if (picked != null) {
              setState(() {
                selectedTimes[0] = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: kFieldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Text(
                  selectedTimes[0].format(context),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    if (selectedFrequency == 'Once Only') {
      return _buildDateCard("Date", startDate, (date) {
        setState(() => startDate = date);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDateCard(
                "Start Date",
                startDate,
                (date) => setState(() => startDate = date),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDateCard(
                "End Date",
                endDate ?? DateTime.now(),
                (date) => setState(() => endDate = date),
                isEnabled: !isLifetime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        CheckboxListTile(
          title: const Text(
            "Lifetime (no end date)",
            style: TextStyle(fontSize: 14),
          ),
          value: isLifetime,
          onChanged: (val) {
            setState(() {
              isLifetime = val ?? false;
              if (isLifetime) endDate = null;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      ],
    );
  }

  Widget _buildDateCard(
    String label,
    DateTime date,
    Function(DateTime) onSelect, {
    bool isEnabled = true,
  }) {
    return InkWell(
      onTap:
          isEnabled
              ? () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (picked != null) onSelect(picked);
              }
              : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: isEnabled ? kFieldBackgroundColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEnabled
                      ? "${date.year}-${date.month}-${date.day}"
                      : "--/--/----",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isEnabled ? Colors.black : Colors.grey,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: isEnabled ? Colors.black : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageField() {
    return TextField(
      controller: messageController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: "e.g. Take with food...",
        filled: true,
        fillColor: kFieldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: BlocBuilder<ReminderCubit, ReminderState>(
        builder: (context, state) {
          return ElevatedButton(
            // ✅ استخدام دالة الحفظ الموحدة
            onPressed: state is ReminderLoading ? null : _saveReminder,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                state is ReminderLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                      isEditing
                          ? "Update Reminder"
                          : "Save Reminder", // ✅ تغيير نص الزر
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

  // ==================== 🛠️ دالة مساعدة لتنسيق الوقت ====================
  String _formatToICalString(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${dt.year}${twoDigits(dt.month)}${twoDigits(dt.day)}T${twoDigits(dt.hour)}${twoDigits(dt.minute)}${twoDigits(dt.second)}";
  }

  // ==================== 🟢 SAVE LOGIC (Unified Create & Update) ====================

  void _saveReminder() async {
    // 1. Validation
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please enter a title"),
          backgroundColor: Colors.red,
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

    // 2. Prepare Data
    // ---------------
    // .toIso8601String()
    // تاريخ ووقت البداية (يعتمد على أول وقت)
    final DateTime dtStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      selectedTimes[0].hour,
      selectedTimes[0].minute,
      0,
    );

    // تواريخ البداية والنهاية (للحقول المنفصلة)
    // final DateTime startD = DateTime(
    //   startDate.year,
    //   startDate.month,
    //   startDate.day,
    // );
    // final DateTime? endD =
    //     isLifetime
    //         ? null
    //         : (selectedFrequency == 'Once Only'
    //             ? startD.add(const Duration(hours: 1))
    //             : endDate ?? DateTime(2099, 12, 31));
    final DateTime? endD;
    if (isLifetime) {
       // 1️⃣ حالة مدى الحياة: نضع تاريخ بعيد جداً (سنة 2099)
       // ده بيخلي الباك إند يفهم إنها مستمرة
      endD = DateTime(2099, 12, 31, 23, 59, 59);
    } else if (selectedFrequency == 'Once Only') {
       // 2️⃣ حالة المرة الواحدة: ساعة بعد البداية
      endD = dtStart.add(const Duration(hours: 1));
    } else {
      // في الحالات الأخرى، نستخدم تاريخ النهاية المحدد أو نفس يوم البداية لو مفيش
      DateTime baseEndDate = endDate ?? startDate;
      // نخليه ينتهي في آخر اليوم (الساعة 23:59) عشان يغطي اليوم كله
      endD = DateTime(
        baseEndDate.year,
        baseEndDate.month,
        baseEndDate.day,
        23, 59, 59 
      );
    }

    String? rruleString;
    SimpleModel? simple;
    // int intervalHours = 0;
    String firstDoseTimeStr = "";

    // بناء اللوجيك (RRule vs Simple)
    if (selectedFrequency == 'Every X Hours') {
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
      // int intervalHours = interval;
      firstDoseTimeStr =
          "${selectedTimes[0].hour.toString().padLeft(2, '0')}:${selectedTimes[0].minute.toString().padLeft(2, '0')}:00";

      simple = SimpleModel(
        intervalHours: interval,
        firstDoseTime: firstDoseTimeStr,
      );
    } else if (selectedFrequency == 'Once Only') {
      rruleString = "FREQ=DAILY;COUNT=1";
    } else {
      // بناء الـ RRule Body باستخدام الدالة المساعدة
      rruleString = _buildRRuleString();
    }

    // تجهيز الـ RRule النهائي (مع DTSTART)
    String? finalRRuleToSend;
    if (rruleString != null) {
      finalRRuleToSend =
          "DTSTART:${_formatToICalString(dtStart)}\nRRULE:$rruleString";
    } else if (selectedFrequency == 'Once Only') {
      finalRRuleToSend = "DTSTART:${_formatToICalString(dtStart)}";
    }

    // 3. Execution (Create or Update)
    // --------------------------------
    if (mounted) {
      if (isEditing) {
        // 🟡 وضع التعديل (Update)
        context.read<ReminderCubit>().updateReminder(
          patientId: patientId,
          reminderId: widget.reminderToEdit!.reminderId!, // الـ ID من الموديل
          title: titleController.text.trim(),
          startDate: dtStart, // DateTime مباشر
          endDate: endD, // DateTime مباشر (للأمان لو null)

          rrule: finalRRuleToSend,
          simple: simple,
          message: messageController.text.trim(),
          isEveryXHours: selectedFrequency == 'Every X Hours', // للتمييز
        );
      } else {
        // 🟢 وضع الإضافة (Create)
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

  String _buildRRuleString() {
    // ✅ حساب until إذا لم يكن Lifetime
    final DateTime? untilDate =
        (!isLifetime && endDate != null)
            ? DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59)
            : null;

    switch (selectedFrequency) {
      case 'Daily':
        // ✅ دعم Multiple Times
        if (selectedTimes.length > 1) {
          // بناء يدوي للـ Multiple Times (RRuleHelper لا يدعمه مباشرة)
          final hours = selectedTimes.map((t) => t.hour).join(',');
          final minutes = selectedTimes.map((t) => t.minute).join(',');
          String rrule = "FREQ=DAILY;BYHOUR=$hours;BYMINUTE=$minutes";
          if (untilDate != null) {
            rrule += ";UNTIL=${_formatToICalString(untilDate)}";
          }
          return rrule;
        } else {
          // ✅ وقت واحد - استخدم RRuleHelper
          return RRuleHelper.buildDaily(
            hour: selectedTimes[0].hour,
            minute: selectedTimes[0].minute,
            until: untilDate,
          );
        }

      case 'Weekly':
        // ✅ دعم Multiple Times
        if (selectedTimes.length > 1) {
          final daysMap = {
            DateTime.monday: 'MO',
            DateTime.tuesday: 'TU',
            DateTime.wednesday: 'WE',
            DateTime.thursday: 'TH',
            DateTime.friday: 'FR',
            DateTime.saturday: 'SA',
            DateTime.sunday: 'SU',
          };
          final selectedDaysStr = selectedWeekDays
              .map((day) => daysMap[day])
              .where((d) => d != null)
              .join(',');
          final hours = selectedTimes.map((t) => t.hour).join(',');
          final minutes = selectedTimes.map((t) => t.minute).join(',');
          String rrule =
              "FREQ=WEEKLY;BYDAY=$selectedDaysStr;BYHOUR=$hours;BYMINUTE=$minutes";
          if (untilDate != null) {
            rrule += ";UNTIL=${_formatToICalString(untilDate)}";
          }
          return rrule;
        } else {
          // ✅ وقت واحد - استخدم RRuleHelper
          return RRuleHelper.buildWeekly(
            weekDays: selectedWeekDays,
            hour: selectedTimes[0].hour,
            minute: selectedTimes[0].minute,
            until: untilDate,
          );
        }

      case 'Monthly':
        // ✅ دعم Multiple Times
        if (selectedTimes.length > 1) {
          final hours = selectedTimes.map((t) => t.hour).join(',');
          final minutes = selectedTimes.map((t) => t.minute).join(',');
          String rrule =
              "FREQ=MONTHLY;BYMONTHDAY=$selectedMonthDay;BYHOUR=$hours;BYMINUTE=$minutes";
          if (untilDate != null) {
            rrule += ";UNTIL=${_formatToICalString(untilDate)}";
          }
          return rrule;
        } else {
          // ✅ وقت واحد - استخدم RRuleHelper
          return RRuleHelper.buildMonthly(
            monthDay: selectedMonthDay,
            hour: selectedTimes[0].hour,
            minute: selectedTimes[0].minute,
            until: untilDate,
          );
        }

      default:
        // Fallback to Daily
        return RRuleHelper.buildDaily(
          hour: selectedTimes[0].hour,
          minute: selectedTimes[0].minute,
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
