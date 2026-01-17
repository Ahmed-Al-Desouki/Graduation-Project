import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final Widget child;
  const SectionCard({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      color: Color(0xffE8F7F2),
      child: Padding(padding: const EdgeInsets.all(15.0), child: child),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }
}

class TimeChip extends StatelessWidget {
  final TimeOfDay time;
  final Function(TimeOfDay) onSelect;
  final VoidCallback? onDelete;

  const TimeChip({
    super.key,
    required this.time,
    required this.onSelect,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
          color: Color(0xFFF8F9FA),
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
                child: const Icon(Icons.close, size: 18, color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DateCard extends StatelessWidget {
  final String label;
  final DateTime date;
  final Function(DateTime) onSelect;
  final bool isEnabled;

  const DateCard({
    super.key,
    required this.label,
    required this.date,
    required this.onSelect,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
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
          color: isEnabled ? Color(0xFFF8F9FA) : Colors.grey.shade100,
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
}
