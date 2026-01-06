import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_state.dart';
import 'package:graduation_project/features/reminder/presentation/views/add_reminder_view.dart';

class AllRemindersDialog extends StatefulWidget {
  const AllRemindersDialog({super.key});

  @override
  State<AllRemindersDialog> createState() => _AllRemindersDialogState();
}

class _AllRemindersDialogState extends State<AllRemindersDialog> {
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF8F9FA),
      insetPadding: const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8, // 80% من طول الشاشة
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // العنوان وزر الغلق
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "All Reminders",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),

            // المحتوى (القائمة)
            Expanded(
              child: BlocConsumer<ReminderCubit, ReminderState>(
                listener: (context, state) {
                  if (state is ReminderDeleteSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Reminder Deleted Successfully"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    _loadData(); // إعادة تحميل بعد الحذف
                    Navigator.pop(context);
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
                      return const Center(child: Text("No reminders found."));
                    }

                    // 🔹 الفلترة (Grouping)
                    final medications =
                        allList.where((r) => r.type == 'Medication').toList();
                    final appointments =
                        allList.where((r) => r.type == 'Appointment').toList();
                    final customs =
                        allList.where((r) => r.type == 'Custom').toList();

                    return ListView(
                      children: [
                        if (medications.isNotEmpty)
                          _buildSection("Medications", medications),
                        if (appointments.isNotEmpty)
                          _buildSection("Appointments", appointments),
                        if (customs.isNotEmpty)
                          _buildSection("Customs", customs),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // قسم (عنوان + قائمة)
  Widget _buildSection(String title, List<ReminderModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
        ...items.map((reminder) => _buildReminderItem(reminder)),
      ],
    );
  }

  // عنصر القائمة الواحد
  Widget _buildReminderItem(ReminderModel reminder) {
    // if (reminder.reminderID == null) return const SizedBox(); // Safe guard
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          reminder.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(reminder.message ?? "No details"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // زر التعديل (Edit)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                // الذهاب لصفحة AddReminderView في وضع التعديل
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => BlocProvider.value(
                          value: context.read<ReminderCubit>(),
                          child: AddReminderView(
                            reminderToEdit: reminder,
                          ), // 👈 نمرر الريمندر هنا
                        ),
                  ),
                );
                // لو رجعنا وكان فيه تعديل (true)، نعيد تحميل القائمة
                if (result == true) {
                  _loadData();
                }
              },
            ),
            // زر الحذف (Delete)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // ✅ إصلاح: التأكد من أن الـ ID ليس null قبل الاستدعاء
                if (reminder.reminderId != null) {
                  _confirmDelete(reminder.reminderId!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Error: Cannot delete reminder with null ID",
                      ),
                    ),
                  );
                }
              },
            ),
          ],
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
            content: const Text("Are you sure? This action cannot be undone."),
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
                    // استدعاء الحذف
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
