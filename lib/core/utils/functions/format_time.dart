String formatTimeTo12Hour(String time24) {
  // time24 format: "09:00:00"
  final parts = time24.split(':');
  int hour = int.parse(parts[0]);
  int minute = int.parse(parts[1]);

  String period = hour >= 12 ? 'PM' : 'AM';
  if (hour > 12) hour -= 12;
  if (hour == 0) hour = 12;

  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
}
