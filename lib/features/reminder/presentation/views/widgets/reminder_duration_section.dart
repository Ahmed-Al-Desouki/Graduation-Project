import 'package:flutter/material.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/shared_widgets.dart';

class ReminderDurationSection extends StatelessWidget {
  final String? selectedFrequency;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isLifetime;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;
  final Function(bool) onLifetimeChanged;

  const ReminderDurationSection({
    super.key,
    required this.selectedFrequency,
    required this.startDate,
    required this.endDate,
    required this.isLifetime,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onLifetimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle("Duration"),
        const SizedBox(height: 10),
        SectionCard(child: _buildDurationContent(context)),
      ],
    );
  }

  Widget _buildDurationContent(BuildContext context) {
    if (selectedFrequency == 'Once Only') {
      return DateCard(
        label: "Date",
        date: startDate,
        onSelect: onStartDateChanged,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DateCard(
                label: "Start Date",
                date: startDate,
                onSelect: onStartDateChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DateCard(
                label: "End Date",
                date: endDate ?? DateTime.now(),
                onSelect: onEndDateChanged,
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
          onChanged: (val) => onLifetimeChanged(val ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      ],
    );
  }
}
