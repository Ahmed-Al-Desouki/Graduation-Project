import 'package:flutter/material.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/shared_widgets.dart';

class ReminderFrequencySection extends StatelessWidget {
  final String? selectedFrequency;
  final List<TimeOfDay> selectedTimes;
  final Set<int> selectedWeekDays;
  final int? selectedMonthDay;
  final TextEditingController intervalController;
  final Function(String) onFrequencyChanged;
  final Function(List<TimeOfDay>) onTimesChanged;
  final Function(Set<int>) onWeekDaysChanged;
  final Function(int) onMonthDayChanged;

  const ReminderFrequencySection({
    super.key,
    required this.selectedFrequency,
    required this.selectedTimes,
    required this.selectedWeekDays,
    required this.selectedMonthDay,
    required this.intervalController,
    required this.onFrequencyChanged,
    required this.onTimesChanged,
    required this.onWeekDaysChanged,
    required this.onMonthDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle("When do you take this?"),
        const SizedBox(height: 10),
        SectionCard(
          child: Column(
            children: [
              FrequencySelector(
                selectedFrequency: selectedFrequency,
                onChanged: onFrequencyChanged,
              ),
              const Divider(height: 25, thickness: 1),
              FrequencyOptions(
                selectedFrequency: selectedFrequency,
                selectedTimes: selectedTimes,
                selectedWeekDays: selectedWeekDays,
                selectedMonthDay: selectedMonthDay,
                intervalController: intervalController,
                onTimesChanged: onTimesChanged,
                onWeekDaysChanged: onWeekDaysChanged,
                onMonthDayChanged: onMonthDayChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FrequencySelector extends StatelessWidget {
  final String? selectedFrequency;
  final Function(String) onChanged;

  const FrequencySelector({
    super.key,
    required this.selectedFrequency,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      "Once Only",
      "Daily",
      "Weekly",
      "Monthly",
      "Every X Hours",
    ];

    const Color kPrimaryColor = Colors.green;
    const Color kFieldBackgroundColor = Color(0xFFF8F9FA);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          options.map((option) {
            final isSelected = selectedFrequency == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onChanged(option),
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
}

class FrequencyOptions extends StatelessWidget {
  final String? selectedFrequency;
  final List<TimeOfDay> selectedTimes;
  final Set<int> selectedWeekDays;
  final int? selectedMonthDay;
  final TextEditingController intervalController;
  final Function(List<TimeOfDay>) onTimesChanged;
  final Function(Set<int>) onWeekDaysChanged;
  final Function(int) onMonthDayChanged;

  const FrequencyOptions({
    super.key,
    required this.selectedFrequency,
    required this.selectedTimes,
    required this.selectedWeekDays,
    required this.selectedMonthDay,
    required this.intervalController,
    required this.onTimesChanged,
    required this.onWeekDaysChanged,
    required this.onMonthDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (selectedFrequency) {
      case 'Daily':
        return TimeSelector(
          selectedTimes: selectedTimes,
          canAddTime: true,
          onTimesChanged: onTimesChanged,
        );

      case 'Once Only':
        return TimeSelector(
          selectedTimes: selectedTimes,
          canAddTime: false,
          onTimesChanged: onTimesChanged,
        );

      case 'Weekly':
        return WeeklySelector(
          selectedWeekDays: selectedWeekDays,
          selectedTimes: selectedTimes,
          onWeekDaysChanged: onWeekDaysChanged,
          onTimesChanged: onTimesChanged,
        );

      case 'Monthly':
        return MonthlySelector(
          selectedMonthDay: selectedMonthDay,
          selectedTimes: selectedTimes,
          onMonthDayChanged: onMonthDayChanged,
          onTimesChanged: onTimesChanged,
        );

      case 'Every X Hours':
        return EveryXHoursSelector(
          intervalController: intervalController,
          selectedTimes: selectedTimes,
          onTimesChanged: onTimesChanged,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

class TimeSelector extends StatelessWidget {
  final List<TimeOfDay> selectedTimes;
  final bool canAddTime;
  final Function(List<TimeOfDay>) onTimesChanged;

  const TimeSelector({
    super.key,
    required this.selectedTimes,
    required this.canAddTime,
    required this.onTimesChanged,
  });

  static const Color kPrimaryColor = Colors.green;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Time:",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...List.generate(selectedTimes.length, (index) {
              return TimeChip(
                time: selectedTimes[index],
                onSelect: (newTime) {
                  List<TimeOfDay> updatedList = List.from(selectedTimes);
                  updatedList[index] = newTime;
                  onTimesChanged(updatedList);
                },
                onDelete:
                    canAddTime && selectedTimes.length > 1
                        ? () {
                          List<TimeOfDay> updatedList = List.from(
                            selectedTimes,
                          );
                          updatedList.removeAt(index);
                          onTimesChanged(updatedList);
                        }
                        : null,
              );
            }),
            if (canAddTime)
              InkWell(
                onTap: () {
                  List<TimeOfDay> updatedList = List.from(selectedTimes);
                  updatedList.add(const TimeOfDay(hour: 8, minute: 0));
                  onTimesChanged(updatedList);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
        ),
      ],
    );
  }
}

class WeeklySelector extends StatelessWidget {
  final Set<int> selectedWeekDays;
  final List<TimeOfDay> selectedTimes;
  final Function(Set<int>) onWeekDaysChanged;
  final Function(List<TimeOfDay>) onTimesChanged;

  const WeeklySelector({
    super.key,
    required this.selectedWeekDays,
    required this.selectedTimes,
    required this.onWeekDaysChanged,
    required this.onTimesChanged,
  });

  @override
  Widget build(BuildContext context) {
    const daysMap = {
      DateTime.saturday: 'Saturday',
      DateTime.sunday: 'Sunday',
      DateTime.monday: 'Monday',
      DateTime.tuesday: 'Tuesday',
      DateTime.wednesday: 'Wednesday',
      DateTime.thursday: 'Thursday',
      DateTime.friday: 'Friday',
    };
    const Color kPrimaryColor = Colors.green;

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
          final isSelected = selectedWeekDays.contains(dayNum);
          return CheckboxListTile(
            title: Text(entry.value),
            value: isSelected,
            activeColor: kPrimaryColor,
            contentPadding: EdgeInsets.zero,
            dense: true,
            onChanged: (val) {
              final newSet = Set<int>.from(selectedWeekDays);
              if (val == true) {
                newSet.add(dayNum);
              } else {
                newSet.remove(dayNum);
              }
              onWeekDaysChanged(newSet);
            },
          );
        }),
        const SizedBox(height: 10),
        TimeSelector(
          selectedTimes: selectedTimes,
          canAddTime: true,
          onTimesChanged: onTimesChanged,
        ),
      ],
    );
  }
}

class MonthlySelector extends StatelessWidget {
  final int? selectedMonthDay;
  final List<TimeOfDay> selectedTimes;
  final Function(int) onMonthDayChanged;
  final Function(List<TimeOfDay>) onTimesChanged;

  const MonthlySelector({
    super.key,
    required this.selectedMonthDay,
    required this.selectedTimes,
    required this.onMonthDayChanged,
    required this.onTimesChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryColor = Colors.green;
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
              selectedColor: kPrimaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              onSelected: (_) => onMonthDayChanged(day),
            );
          }),
        ),
        const SizedBox(height: 15),
        TimeSelector(
          selectedTimes: selectedTimes,
          canAddTime: true,
          onTimesChanged: onTimesChanged,
        ),
      ],
    );
  }
}

class EveryXHoursSelector extends StatelessWidget {
  final TextEditingController intervalController;
  final List<TimeOfDay> selectedTimes;
  final Function(List<TimeOfDay>) onTimesChanged;

  const EveryXHoursSelector({
    super.key,
    required this.intervalController,
    required this.selectedTimes,
    required this.onTimesChanged,
  });

  @override
  Widget build(BuildContext context) {
    const Color kFieldBackgroundColor = Color(0xFFF8F9FA);

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
              onTimesChanged([picked]);
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
}
