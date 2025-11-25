// import 'package:flutter/material.dart';
// import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';

// class AddReminderView extends StatefulWidget {
//   const AddReminderView({super.key});

//   @override
//   State<AddReminderView> createState() => _AddReminderPageState();
// }

// class _AddReminderPageState extends State<AddReminderView> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController messageController = TextEditingController();
//   DateTime startDate = DateTime.now();
//   DateTime endDate = DateTime.now().add(const Duration(days: 7));
//   String frequency = 'Daily';
//   String type = 'Medication';
//   String baseTime = "08:00:00";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Add Reminder")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: 'Name'),
//             ),
//             TextField(
//               controller: messageController,
//               decoration: const InputDecoration(labelText: 'Message'),
//             ),
//             const SizedBox(height: 20),

//             DropdownButton<String>(
//               value: type,
//               onChanged: (val) {
//                 setState(() {
//                   type = val!;
//                 });
//               },
//               items: const [
//                 DropdownMenuItem(
//                   value: 'Medication',
//                   child: Text('Medication'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'Appointment',
//                   child: Text('Appointment'),
//                 ),
//                 DropdownMenuItem(value: 'Custom', child: Text('Custom')),
//               ],
//             ),

//             ElevatedButton(
//               onPressed: () {
//                 final reminder = ReminderModel(
//                   type: type,
//                   name: nameController.text,
//                   startDate: startDate,
//                   endDate: endDate,
//                   frequency: frequency,
//                   intervalHours: frequency == 'EveryXHours' ? 6 : null,
//                   baseTime: baseTime,
//                   message: messageController.text,
//                 );

//                 Navigator.pop(context, reminder);
//               },

//               child: const Text("Save"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// -----------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';

// class AddReminderView extends StatefulWidget {
//   const AddReminderView({super.key});

//   @override
//   State<AddReminderView> createState() => _AddReminderViewState();
// }

// class _AddReminderViewState extends State<AddReminderView> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController messageController = TextEditingController();
//   final TextEditingController intervalController = TextEditingController();

//   DateTime startDate = DateTime.now();
//   DateTime endDate = DateTime.now().add(const Duration(days: 7));
//   TimeOfDay baseTime = const TimeOfDay(hour: 8, minute: 0);

//   String type = 'Medication';
//   String frequency = 'Daily';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Add Reminder")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // Name
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: 'Name'),
//             ),

//             // Message
//             TextField(
//               controller: messageController,
//               decoration: const InputDecoration(labelText: 'Message'),
//             ),

//             const SizedBox(height: 20),

//             // Type Dropdown
//             DropdownButton<String>(
//               value: type,
//               onChanged: (val) {
//                 setState(() => type = val!);
//               },
//               items: const [
//                 DropdownMenuItem(value: 'Medication', child: Text('Medication')),
//                 DropdownMenuItem(value: 'Appointment', child: Text('Appointment')),
//                 DropdownMenuItem(value: 'Custom', child: Text('Custom')),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // Frequency Dropdown
//             DropdownButton<String>(
//               value: frequency,
//               onChanged: (val) {
//                 setState(() => frequency = val!);
//               },
//               items: const [
//                 DropdownMenuItem(value: 'Daily', child: Text('Daily')),
//                 DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
//                 DropdownMenuItem(value: 'EveryXHours', child: Text('Every X Hours')),
//               ],
//             ),

//             // Interval Hours field ONLY if needed
//             if (frequency == "EveryXHours")
//               TextField(
//                 controller: intervalController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(labelText: 'Interval Hours'),
//               ),

//             const SizedBox(height: 20),

//             // Pick Start Date
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Start Date:"),
//                 TextButton(
//                   child: Text(
//                     "${startDate.year}-${startDate.month}-${startDate.day}",
//                   ),
//                   onPressed: () async {
//                     final selected = await showDatePicker(
//                       context: context,
//                       initialDate: startDate,
//                       firstDate: DateTime(2020),
//                       lastDate: DateTime(2030),
//                     );
//                     if (selected != null) setState(() => startDate = selected);
//                   },
//                 ),
//               ],
//             ),

//             // Pick End Date
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("End Date:"),
//                 TextButton(
//                   child: Text(
//                     "${endDate.year}-${endDate.month}-${endDate.day}",
//                   ),
//                   onPressed: () async {
//                     final selected = await showDatePicker(
//                       context: context,
//                       initialDate: endDate,
//                       firstDate: DateTime(2020),
//                       lastDate: DateTime(2030),
//                     );
//                     if (selected != null) setState(() => endDate = selected);
//                   },
//                 ),
//               ],
//             ),

//             // Pick Time
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Base Time:"),
//                 TextButton(
//                   child: Text("${baseTime.hour}:${baseTime.minute.toString().padLeft(2, '0')}"),
//                   onPressed: () async {
//                     final selected = await showTimePicker(
//                       context: context,
//                       initialTime: baseTime,
//                     );
//                     if (selected != null) setState(() => baseTime = selected);
//                   },
//                 ),
//               ],
//             ),

//             const SizedBox(height: 30),

//             ElevatedButton(
//               onPressed: () {
//                 final finalBaseTime =
//                     "${baseTime.hour.toString().padLeft(2, '0')}:${baseTime.minute.toString().padLeft(2, '0')}:00";

//                 final reminder = ReminderModel(
//                   type: type,
//                   name: nameController.text,
//                   startDate: startDate,
//                   endDate: endDate,
//                   frequency: frequency,
//                   intervalHours: frequency == 'EveryXHours'
//                       ? int.parse(intervalController.text)
//                       : null,
//                   baseTime: finalBaseTime,
//                   message: messageController.text,
//                 );

//                 Navigator.pop(context, reminder);
//               },
//               child: const Text("Save"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// ----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/reminder/presentation/manger/reminder_cubit/reminder_cubit.dart';
import 'package:graduation_project/features/reminder/presentation/manger/reminder_cubit/reminder_state.dart';

class AddReminderView extends StatefulWidget {
  const AddReminderView({super.key});

  @override
  State<AddReminderView> createState() => _AddReminderViewState();
}

class _AddReminderViewState extends State<AddReminderView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController intervalController = TextEditingController();

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay baseTime = const TimeOfDay(hour: 8, minute: 0);

  String type = 'Medication';
  String frequency = 'Daily';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Reminder")),
      body: BlocConsumer<ReminderCubit, ReminderState>(
        listener: (context, state) {
          if (state is ReminderCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Reminder Added Successfully")),
            );
            Navigator.pop(context);
          } else if (state is ReminderCreateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Reminder Name'),
                ),

                const SizedBox(height: 15),

                // Message
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(labelText: 'Message'),
                ),

                const SizedBox(height: 20),

                // Type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Type:"),
                    DropdownButton<String>(
                      value: type,
                      onChanged: (val) => setState(() => type = val!),
                      items: const [
                        DropdownMenuItem(
                            value: 'Medication', child: Text('Medication')),
                        DropdownMenuItem(
                            value: 'Appointment', child: Text('Appointment')),
                        DropdownMenuItem(
                            value: 'Custom', child: Text('Custom')),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Frequency
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Frequency:"),
                    DropdownButton<String>(
                      value: frequency,
                      onChanged: (val) => setState(() => frequency = val!),
                      items: const [
                        DropdownMenuItem(
                            value: 'Daily', child: Text('Daily')),
                        DropdownMenuItem(
                            value: 'Weekly', child: Text('Weekly')),
                        DropdownMenuItem(
                            value: 'EveryXHours',
                            child: Text('Every X Hours')),
                      ],
                    ),
                  ],
                ),

                if (frequency == "EveryXHours") ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: intervalController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Interval Hours'),
                  ),
                ],

                const SizedBox(height: 20),

                // Start Date Picker
                _buildDateRow(
                  title: "Start Date:",
                  date: startDate,
                  onSelect: () async {
                    final sel = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (sel != null) setState(() => startDate = sel);
                  },
                ),

                const SizedBox(height: 10),

                // End Date Picker
                _buildDateRow(
                  title: "End Date:",
                  date: endDate,
                  onSelect: () async {
                    final sel = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (sel != null) setState(() => endDate = sel);
                  },
                ),

                const SizedBox(height: 10),

                // Time Picker
                _buildTimeRow(
                  title: "Base Time:",
                  time: baseTime,
                  onSelect: () async {
                    final sel =
                        await showTimePicker(context: context, initialTime: baseTime);
                    if (sel != null) setState(() => baseTime = sel);
                  },
                ),

                const SizedBox(height: 30),

                // Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state is ReminderLoading
                        ? null
                        : () {
                            _saveReminder(context);
                          },
                    child: state is ReminderLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Add Reminder"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // DATE WIDGET
  Widget _buildDateRow({
    required String title,
    required DateTime date,
    required VoidCallback onSelect,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        TextButton(
          onPressed: onSelect,
          child: Text("${date.year}-${date.month}-${date.day}"),
        ),
      ],
    );
  }

  // TIME WIDGET
  Widget _buildTimeRow({
    required String title,
    required TimeOfDay time,
    required VoidCallback onSelect,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        TextButton(
          onPressed: onSelect,
          child: Text("${time.hour}:${time.minute.toString().padLeft(2, '0')}"),
        ),
      ],
    );
  }

  // SAVE METHOD
  void _saveReminder(BuildContext context) {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Name is required")));
      return;
    }

    final interval =
        frequency == "EveryXHours" ? intervalController.text : "0";

    final cubit = context.read<ReminderCubit>();

    cubit.createReminder(
      patientId: "3", // TODO: هتبدله بـ patient الحقيقي بعدين
      type: type,
      name: nameController.text,
      message: messageController.text,
      startDate: startDate.toIso8601String(),
      endDate: endDate.toIso8601String(),
      frequency: frequency,
      intervalHours: interval,
      baseTime: "${baseTime.hour}:${baseTime.minute}",
    );
  }
}
// int? intervalInt;
//   if (frequency == "EveryXHours") {
//     intervalInt = int.tryParse(intervalController.text);
//     if (intervalInt == null || intervalInt <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Please enter a valid Interval Hours")));
//       return;
//     }
//   }

//     final cubit = context.read<ReminderCubit>();

//     cubit.createReminder(
//       patientId: "3", // TODO: هتبدله بـ patient الحقيقي بعدين
//       type: type,
//       name: nameController.text,
//       message: messageController.text,
//       startDate: startDate.toIso8601String(),
//       endDate: endDate.toIso8601String(),
//       frequency: frequency,
//       intervalHours: intervalInt?.toString() ?? "0",
//       baseTime: "${baseTime.hour}:${baseTime.minute}",
//     );
//   }
// }
