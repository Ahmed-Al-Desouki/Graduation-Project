import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'day_settings_model.dart';

class DayScheduleItem extends StatefulWidget {
  final String dayName;
  final DaySettings settings;

  const DayScheduleItem({
    super.key,
    required this.dayName,
    required this.settings,
  });

  @override
  State<DayScheduleItem> createState() => _DayScheduleItemState();
}

class _DayScheduleItemState extends State<DayScheduleItem> {
  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          isStart ? widget.settings.startTime : widget.settings.endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          widget.settings.startTime = picked;
        } else {
          widget.settings.endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final String formattedStart = _formatTimeOfDay(widget.settings.startTime);
    final String formattedEnd = _formatTimeOfDay(widget.settings.endTime);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: widget.settings.isEnabled ? 2 : 0,
      color: widget.settings.isEnabled ? Colors.white : Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02,
          vertical: 8,
        ),
        child: Row(
          children: [
            Checkbox(
              activeColor: Colors.blue,
              value: widget.settings.isEnabled,
              onChanged: (val) {
                setState(() => widget.settings.isEnabled = val ?? false);
              },
            ),

            Expanded(
              flex: 2,
              child: Text(
                widget.dayName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color:
                      widget.settings.isEnabled ? Colors.black87 : Colors.grey,
                ),
              ),
            ),

            Expanded(
              flex: 5,
              child: Opacity(
                opacity: widget.settings.isEnabled ? 1.0 : 0.3,
                child: AbsorbPointer(
                  absorbing: !widget.settings.isEnabled,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTimeSelector(
                        "From",
                        formattedStart,
                        () => _selectTime(context, true),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Colors.blueGrey,
                      ),
                      _buildTimeSelector(
                        "To",
                        formattedEnd,
                        () => _selectTime(context, false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(String label, String time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }
}
