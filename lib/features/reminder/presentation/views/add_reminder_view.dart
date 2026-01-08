import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_state.dart';
import 'package:rrule/rrule.dart';

class AddReminderView extends StatefulWidget {
  const AddReminderView({super.key});

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

  // ✅ قائمة الأوقات (لدعم Add Time)
  List<TimeOfDay> selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];

  final Set<int> selectedWeekDays = {};
  int selectedMonthDay = 1;

  @override
  void initState() {
    super.initState();
    endDate = DateTime.now().add(const Duration(days: 7));
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
        title: const Text(
          "Add Reminder",
          style: TextStyle(color: Colors.black),
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
          } else if (state is ReminderCreateFailure) {
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
              _buildSectionTitle("What type of reminder?"),
              const SizedBox(height: 10),
              _buildSectionCard(child: _buildTypeSelector()),

              const SizedBox(height: 25),
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

  Widget _buildTypeSelector() {
    return Column(
      children: [
        _buildTypeRow("Medication", Icons.medication, Colors.blue),
        const Divider(height: 10, thickness: 0.5),
        _buildTypeRow("Appointment", Icons.calendar_month, kPrimaryColor),
        const Divider(height: 10, thickness: 0.5),
        _buildTypeRow("Custom", Icons.notifications, Colors.orange),
      ],
    );
  }

  Widget _buildTypeRow(String type, IconData icon, Color color) {
    final isSelected = selectedType == type;
    return InkWell(
      onTap: () => setState(() => selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 15),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? color : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }

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
                    : const Text(
                      "Save Reminder",
                      style: TextStyle(
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

  // ==================== SAVE LOGIC ====================

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

    // ✅ التحقق من Weekly: يجب اختيار يوم واحد على الأقل
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

    final DateTime startD = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final DateTime endD =
        isLifetime
            ? DateTime(2099, 12, 31)
            : (selectedFrequency == 'Once Only'
                ? startD.add(const Duration(hours: 1))
                : endDate ?? DateTime(2099, 12, 31));

    String? rruleString;
    SimpleModel? simple;

    if (selectedFrequency == 'Every X Hours') {
      final int interval = int.tryParse(intervalController.text) ?? 8;
      if (interval < 1 || interval > 48) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("الفاصل يجب أن يكون بين 1 و48 ساعة")),
        );
        return;
      }
      simple = SimpleModel(
        intervalHours: interval,
        firstDoseTime:
            "${selectedTimes[0].hour.toString().padLeft(2, '0')}:${selectedTimes[0].minute.toString().padLeft(2, '0')}:00",
      );
    } else if (selectedFrequency != 'Once Only') {
      rruleString = _buildRRuleString();
    }

    String? finalRRuleToSend;

    if (selectedFrequency == 'Once Only') {
      finalRRuleToSend = "DTSTART:${_formatToICalString(dtStart)}";
    } else if (rruleString != null) {
      finalRRuleToSend =
          "DTSTART:${_formatToICalString(dtStart)}\nRRULE:$rruleString";
    }

    if (mounted) {
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

    print("✅ Sending RRule: $finalRRuleToSend");
    print("✅ Sending reminder:");
    print("  Type: $selectedType");
    print("  Title: ${titleController.text}");
    print("  RRULE: $rruleString");
    print("  Simple: ${simple?.toJson()}");
    print("  Start: $dtStart");
    print("  End: $dtEnd");
  }

  String _buildRRuleString() {
    String freq = "";
    String byday = "";
    String bymonthday = "";

    // ✅ استخدام selectedTimes بدلاً من firstDoseTime
    final int hour = selectedTimes[0].hour;
    final int minute = selectedTimes[0].minute;

    // ✅ دعم Multiple Times للـ Daily, Weekly, Monthly
    String byhour = "";
    String byminute = "";

    if (selectedTimes.length > 1) {
      // ✅ إذا كان هناك أكثر من وقت، نستخدم BYHOUR و BYMINUTE كقائمة
      byhour = ";BYHOUR=${selectedTimes.map((t) => t.hour).join(',')}";
      byminute = ";BYMINUTE=${selectedTimes.map((t) => t.minute).join(',')}";
    } else {
      // ✅ وقت واحد فقط
      byhour = ";BYHOUR=$hour";
      byminute = ";BYMINUTE=$minute";
    }

    switch (selectedFrequency) {
      case 'Daily':
        freq = "FREQ=DAILY";
        break;

      case 'Weekly':
        freq = "FREQ=WEEKLY";
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
        byday = ";BYDAY=$selectedDaysStr";
        break;

      case 'Monthly':
        freq = "FREQ=MONTHLY";
        bymonthday = ";BYMONTHDAY=$selectedMonthDay";
        break;

      default:
        freq = "FREQ=DAILY";
    }

    String until = "";
    if (!isLifetime) {
      final DateTime endD = endDate ?? DateTime(2099, 12, 31);
      final DateTime dtEndFixed = DateTime(
        endD.year,
        endD.month,
        endD.day,
        23,
        59,
        59,
      );

      until = ";UNTIL=${_formatToICalString(dtEndFixed)}";
    }

    return "$freq$byday$bymonthday$byhour$byminute$until";
  }

  DateTime get dtEnd {
    return isLifetime
        ? DateTime(2099, 12, 31, 23, 59, 59)
        : DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59);
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    intervalController.dispose();
    super.dispose();
  }
}
