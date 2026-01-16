import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_state.dart';
import 'package:graduation_project/features/reminder/presentation/views/add_reminder_view.dart';

class AllRemindersView extends StatefulWidget {
  const AllRemindersView({super.key});

  @override
  State<AllRemindersView> createState() => _AllRemindersViewState();
}

class _AllRemindersViewState extends State<AllRemindersView> {
  String _formatRRuleTimes(String? rruleString, DateTime startDate) {
    String formatTime(int h, int m) {
      final String period = h >= 12 ? "PM" : "AM";
      int displayHour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      String displayMinute = m.toString().padLeft(2, '0');
      return "$displayHour:$displayMinute $period";
    }

    if (rruleString == null || rruleString.isEmpty) {
      return formatTime(startDate.hour, startDate.minute);
    }

    try {
      final hourMatch = RegExp(r'BYHOUR=([\d,]+)').firstMatch(rruleString);
      final minuteMatch = RegExp(r'BYMINUTE=([\d,]+)').firstMatch(rruleString);

      if (hourMatch != null) {
        List<int> hours =
            hourMatch.group(1)!.split(',').map(int.parse).toList();
        List<int> minutes = [];
        if (minuteMatch != null) {
          minutes = minuteMatch.group(1)!.split(',').map(int.parse).toList();
        }

        List<String> timeStrings = [];
        for (int i = 0; i < hours.length; i++) {
          int h = hours[i];
          int m =
              (i < minutes.length)
                  ? minutes[i]
                  : (minutes.isNotEmpty ? minutes[0] : 0);
          timeStrings.add(formatTime(h, m));
        }
        return timeStrings.join("  |  ");
      }

      return formatTime(startDate.hour, startDate.minute);
    } catch (e) {
      return formatTime(startDate.hour, startDate.minute);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final id = await SecureStorageHelper.getUserId();
    if (id != null && mounted) {
      context.read<ReminderCubit>().getAllReminders(patientId: id);
    }
  }

  String _formatDate(DateTime dt) {
    try {
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return "${dt.day}-${dt.month}-${dt.year}";
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
        title: const Text(
          "All Reminders",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ReminderCubit, ReminderState>(
        listener: (context, state) {
          if (state is ReminderDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Reminder Deleted Successfully"),
                backgroundColor: Colors.red,
              ),
            );
            _loadData();
          }
        },
        builder: (context, state) {
          if (state is GetAllRemindersLoading ||
              state is ReminderDeleteLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GetAllRemindersFailure) {
            return Center(child: Text(state.errMessage));
          } else if (state is GetAllRemindersSuccess) {
            final allList = state.reminders;
            if (allList.isEmpty) {
              return Center(
                child: Text(
                  "No reminders found.",
                  style: TextStyle(fontSize: 20, color: Colors.grey.shade800),
                ),
              );
            }

            final medications =
                allList.where((r) => r.type == 'Medication').toList();
            final appointments =
                allList.where((r) => r.type == 'Appointment').toList();
            final customs = allList.where((r) => r.type == 'Custom').toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (appointments.isNotEmpty)
                  _buildSection("Appointments:", appointments),
                if (medications.isNotEmpty)
                  _buildSection("Medications:", medications),
                if (customs.isNotEmpty) _buildSection("Customs:", customs),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSection(String title, List<ReminderModel> items) {
    Color titleColor;
    switch (title) {
      case "Appointments:":
        titleColor = Colors.blue.shade700;
        break;
      case "Medications:":
        titleColor = Colors.green;
        break;
      case "Customs:":
        titleColor = Colors.orange;
        break;
      default:
        titleColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
        ),
        ...items.map((reminder) => _buildReminderItem(reminder)),
      ],
    );
  }

  Widget _buildReminderItem(ReminderModel reminder) {
    final bool isLifetime =
        reminder.endDate != null && reminder.endDate!.year >= 2099;

    bool isSameDay = false;
    if (reminder.endDate != null && !isLifetime) {
      isSameDay =
          reminder.startDate.year == reminder.endDate!.year &&
          reminder.startDate.month == reminder.endDate!.month &&
          reminder.startDate.day == reminder.endDate!.day;
    }

    String formattedTimes = _formatRRuleTimes(
      reminder.rrule,
      reminder.startDate,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          title: Text(
            reminder.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reminder.message != null && reminder.message!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 6.0),
                  child: Text(
                    reminder.message!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),

              Row(
                children: [
                  Icon(Icons.date_range, size: 14, color: Colors.blue.shade400),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(reminder.startDate),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isLifetime) ...[
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "Lifetime",
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ] else if (reminder.endDate != null && !isSameDay) ...[
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.arrow_forward,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _formatDate(reminder.endDate!),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 6),

              if (formattedTimes.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.orange.shade400,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Times: $formattedTimes",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BlocProvider.value(
                            value: context.read<ReminderCubit>(),
                            child: AddReminderView(reminderToEdit: reminder),
                          ),
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  if (reminder.reminderId != null) {
                    _confirmDelete(reminder.reminderId!);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Delete Reminder?"),
            content: const Text("Are you sure?\nThis action cannot be undone."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final userId = await SecureStorageHelper.getUserId();
                  if (userId != null && mounted) {
                    context.read<ReminderCubit>().deleteReminder(
                      patientId: userId,
                      reminderId: id,
                    );
                  }
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
