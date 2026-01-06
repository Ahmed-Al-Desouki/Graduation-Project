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
// ---------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
// import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
// import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_state.dart';

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
//       body: BlocListener<ReminderCubit, ReminderState>(
//         listener: (context, state) {
//           if (state is ReminderCreateSuccess) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("Reminder Added Successfully")),
//             );
//             Navigator.pop(context);
//           } else if (state is ReminderCreateFailure) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.errMessage)),
//             );
//           }
//         },
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 // Name
//                 TextField(
//                   controller: nameController,
//                   decoration: const InputDecoration(labelText: 'Reminder Name'),
//                 ),

//                 const SizedBox(height: 15),

//                 // Message
//                 TextField(
//                   controller: messageController,
//                   decoration: const InputDecoration(labelText: 'Message'),
//                 ),

//                 const SizedBox(height: 20),

//                 // Type
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text("Type:"),
//                     DropdownButton<String>(
//                       value: type,
//                       onChanged: (val) => setState(() => type = val!),
//                       items: const [
//                         DropdownMenuItem(
//                           value: 'Medication',
//                           child: Text('Medication'),
//                         ),
//                         DropdownMenuItem(
//                           value: 'Appointment',
//                           child: Text('Appointment'),
//                         ),
//                         DropdownMenuItem(
//                           value: 'Custom',
//                           child: Text('Custom'),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 // Frequency
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text("Frequency:"),
//                     DropdownButton<String>(
//                       value: frequency,
//                       onChanged: (val) => setState(() => frequency = val!),
//                       items: const [
//                         DropdownMenuItem(value: 'Daily', child: Text('Daily')),
//                         DropdownMenuItem(
//                           value: 'Weekly',
//                           child: Text('Weekly'),
//                         ),
//                         DropdownMenuItem(
//                           value: 'EveryXHours',
//                           child: Text('Every X Hours'),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),

//                 if (frequency == "EveryXHours") ...[
//                   const SizedBox(height: 10),
//                   TextField(
//                     controller: intervalController,
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(
//                       labelText: 'Interval Hours',
//                     ),
//                   ),
//                 ],

//                 const SizedBox(height: 20),

//                 // Start Date Picker
//                 _buildDateRow(
//                   title: "Start Date:",
//                   date: startDate,
//                   onSelect: () async {
//                     final sel = await showDatePicker(
//                       context: context,
//                       initialDate: startDate,
//                       firstDate: DateTime(2020),
//                       lastDate: DateTime(2035),
//                     );
//                     if (sel != null) setState(() => startDate = sel);
//                   },
//                 ),

//                 const SizedBox(height: 10),

//                 // End Date Picker
//                 _buildDateRow(
//                   title: "End Date:",
//                   date: endDate,
//                   onSelect: () async {
//                     final sel = await showDatePicker(
//                       context: context,
//                       initialDate: endDate,
//                       firstDate: DateTime(2020),
//                       lastDate: DateTime(2035),
//                     );
//                     if (sel != null) setState(() => endDate = sel);
//                   },
//                 ),

//                 const SizedBox(height: 10),

//                 // Time Picker
//                 _buildTimeRow(
//                   title: "Base Time:",
//                   time: baseTime,
//                   onSelect: () async {
//                     final sel = await showTimePicker(
//                       context: context,
//                       initialTime: baseTime,
//                     );
//                     if (sel != null) setState(() => baseTime = sel);
//                   },
//                 ),

//                 const SizedBox(height: 30),

//                 // Button
//                 SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: BlocBuilder<ReminderCubit, ReminderState>(
//                   builder: (context, state) {
//                     return ElevatedButton(
//                       onPressed: state is ReminderLoading
//                           ? null
//                           : () => _saveReminder(context),
//                       child: state is ReminderLoading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : const Text("Add Reminder"),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // DATE WIDGET
//   Widget _buildDateRow({
//     required String title,
//     required DateTime date,
//     required VoidCallback onSelect,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(title),
//         TextButton(
//           onPressed: onSelect,
//           child: Text("${date.year}-${date.month}-${date.day}"),
//         ),
//       ],
//     );
//   }

//   // TIME WIDGET
//   Widget _buildTimeRow({
//     required String title,
//     required TimeOfDay time,
//     required VoidCallback onSelect,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(title),
//         TextButton(
//           onPressed: onSelect,
//           child: Text("${time.hour}:${time.minute.toString().padLeft(2, '0')}"),
//         ),
//       ],
//     );
//   }

//   // SAVE METHOD
//   // void _saveReminder(BuildContext context) async {
//   //   if (nameController.text.isEmpty) {
//   //     ScaffoldMessenger.of(
//   //       context,
//   //     ).showSnackBar(const SnackBar(content: Text("Name is required")));
//   //     return;
//   //   }

//   //   final String? patientId = await SecureStorageHelper.getUserId();

//   //   if (patientId == null) {
//   //     // معالجة حالة عدم العثور على الـ ID (يجب تسجيل دخول المستخدم)
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(
//   //         content: Text("User ID not found. Please log in again."),
//   //       ),
//   //     );
//   //     return;
//   //   }

//   //   final interval = frequency == "EveryXHours" ? intervalController.text : "0";

//   //   final cubit = context.read<ReminderCubit>();

//   //   cubit.createReminder(
//   //     patientId: patientId,
//   //     type: type,
//   //     name: nameController.text,
//   //     message: messageController.text,
//   //     startDate: startDate.toIso8601String(),
//   //     endDate: endDate.toIso8601String(),
//   //     frequency: frequency,
//   //     intervalHours: interval,
//   //     baseTime: "${baseTime.hour}:${baseTime.minute}",
//   //   );
//   // }
//   void _saveReminder(BuildContext context) async {
//     if (nameController.text.isEmpty) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Name is required")));
//       return;
//     }

//     final String? patientId = await SecureStorageHelper.getUserId();
//     print("====================================");
//     print("Attempting to create Reminder:");
//     print("Patient ID (from storage): $patientId");
//     print("====================================");

//     if (patientId == null || patientId.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("User ID not found. Login again.")),
//         );
//       }
//       return;
//     }

//     //final interval = frequency == "EveryXHours" ? intervalController.text : "0";
//     final int interval = int.tryParse(intervalController.text) ?? 0;

//     // // تنسيق الوقت ليكون HH:mm:ss كما يطلب الـ Backend عادةً
//     final formattedBaseTime =
//         "${baseTime.hour.toString().padLeft(2, '0')}:${baseTime.minute.toString().padLeft(2, '0')}:00";
//        // 2. تجهيز التواريخ (ISO 8601)
//     // دمج الوقت مع التاريخ للبداية
//     final dtStart = DateTime(
//       startDate.year, startDate.month, startDate.day,
//       baseTime.hour, baseTime.minute,
//     );
//     // للنهاية (نهاية اليوم مثلاً)
//     final dtEnd = DateTime(
//       endDate.year, endDate.month, endDate.day, 23, 59, 59
//     );

//     if (mounted) {
//       context.read<ReminderCubit>().createReminder(
//             patientId: patientId,
//             type: type,
//             name: nameController.text,
//             message: messageController.text,
//             startDate: dtStart.toIso8601String(), // تاريخ ووقت البداية
//         endDate: dtEnd.toIso8601String(), // تاريخ النهاية
//         frequency: frequency,
//         intervalHours: interval,
//         baseTime: formattedBaseTime,
//           );
//     }
//   }

// }
// ---------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------
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
// lib/features/reminder/presentation/views/add_reminder_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/helper/rrule_helper.dart'; // ✅ تأكد من وجود الـ Helper هنا
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_state.dart';
// import 'package:rrule/rrule.dart'; // قد لا نحتاجه إذا كان rrule_helper يقوم بالواجب، لكن سأبقيه احتياطاً

class AddReminderView extends StatefulWidget {
  // ✅ إضافة متغير لاستقبال الريمندر في حالة التعديل
  final ReminderModel? reminderToEdit;

  const AddReminderView({super.key, this.reminderToEdit});

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
      // 1. ملء الحقول النصية
      titleController.text = r.title;
      messageController.text = r.message ?? "";

      setState(() {
        selectedType = r.type;
        startDate = r.startDate;
        endDate = r.endDate;

        // تحديد Lifetime
        if (endDate == null || endDate!.year >= 2099) {
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
            selectedTimes = [TimeOfDay(hour: r.startDate.hour, minute: r.startDate.minute)];
          }
        } 
        else if (r.rrule != null && r.rrule!.isNotEmpty) {
          // --- حالة RRULE (Daily, Weekly, Monthly) ---
          try {
            _extractDataFromRRule(r.rrule!);
          } catch (e) {
            print("❌ RRule Parsing Error: $e");
            // Fallback لو فشل التحليل
            selectedFrequency = 'Daily';
            selectedTimes = [TimeOfDay(hour: r.startDate.hour, minute: r.startDate.minute)];
          }
        } 
        else {
          // --- حالة Once Only ---
          selectedFrequency = 'Once Only';
          selectedTimes = [TimeOfDay(hour: r.startDate.hour, minute: r.startDate.minute)];
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

    // 1. استخراج التردد (Frequency)
    if (cleanRule.contains('FREQ=DAILY')) {
      selectedFrequency = 'Daily';
    } else if (cleanRule.contains('FREQ=WEEKLY')) {
      selectedFrequency = 'Weekly';
    } else if (cleanRule.contains('FREQ=MONTHLY')) {
      selectedFrequency = 'Monthly';
    } else if (cleanRule.contains('COUNT=1')) {
      selectedFrequency = 'Once Only';
    }

    // 2. استخراج الأوقات (يدعم التعدد)
    // ⚠️ التغيير هنا: استخدام [^;]+ بدلاً من \d+ ليأخذ الأرقام والفواصل
    final hourMatch = RegExp(r'BYHOUR=([^;]+)').firstMatch(cleanRule);
    final minuteMatch = RegExp(r'BYMINUTE=([^;]+)').firstMatch(cleanRule);

    if (hourMatch != null && minuteMatch != null) {
      // تحويل النص "8,20" إلى قائمة [8, 20]
      final List<int> hours = hourMatch.group(1)!.split(',').map(int.parse).toList();
      final List<int> minutes = minuteMatch.group(1)!.split(',').map(int.parse).toList();

      selectedTimes = [];

      // منطق دمج الساعات والدقائق
      if (hours.length == minutes.length) {
        // كل ساعة لها دقيقة مقابلة (الحالة المثالية)
        for (int i = 0; i < hours.length; i++) {
          selectedTimes.add(TimeOfDay(hour: hours[i], minute: minutes[i]));
        }
      } else if (minutes.length == 1) {
        // دقائق واحدة تتكرر لكل الساعات (شائع جداً)
        // مثال: الساعة 8 والساعة 20، والدقيقة 0
        for (int h in hours) {
          selectedTimes.add(TimeOfDay(hour: h, minute: minutes[0]));
        }
      } else {
        // حالة نادرة: نعتمد على أول قيمة لتجنب الأخطاء
        selectedTimes.add(TimeOfDay(hour: hours[0], minute: minutes[0]));
      }
    } else {
      // Fallback لو لم يجد ساعات في الـ RRULE
      selectedTimes = [TimeOfDay(hour: startDate.hour, minute: startDate.minute)];
    }

    // 3. استخراج أيام الأسبوع (للـ Weekly)
    if (selectedFrequency == 'Weekly') {
      final byDayMatch = RegExp(r'BYDAY=([^;]+)').firstMatch(cleanRule);
      if (byDayMatch != null) {
        final daysStr = byDayMatch.group(1)!;
        final daysCodes = daysStr.split(',');
        final daysMap = {'MO': 1, 'TU': 2, 'WE': 3, 'TH': 4, 'FR': 5, 'SA': 6, 'SU': 7};
        
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
          isEditing ? "Edit Reminder" : "Add Reminder", // ✅ تغيير العنوان
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
              _buildSectionTitle("What type of reminder?"),
              const SizedBox(height: 10),
              // ✅ منع تغيير النوع أثناء التعديل
              IgnorePointer(
                ignoring: isEditing,
                child: Opacity(
                  opacity: isEditing ? 0.4 : 1.0,
                  child: _buildSectionCard(child: _buildTypeSelector()),
                ),
              ),

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
    final DateTime startD = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final DateTime? endD =
        isLifetime
            ? null
            : (selectedFrequency == 'Once Only'
                ? startD.add(const Duration(hours: 1))
                : endDate ?? DateTime(2099, 12, 31));

    String? rruleString;
    SimpleModel? simple;
    int intervalHours = 0;
    String firstDoseTimeStr = "";

    // بناء اللوجيك (RRule vs Simple)
    if (selectedFrequency == 'Every X Hours') {
      final int interval = int.tryParse(intervalController.text) ?? 8;
      if (interval < 1 || interval > 48) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ الفاصل يجب أن يكون بين 1 و48 ساعة"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      intervalHours = interval;
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
          endDate: endD ?? DateTime(2099), // DateTime مباشر (للأمان لو null)

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
          endDate: endD ?? DateTime(2099),
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
    print("  End: ${endD ?? 'null'}");
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

  // 🔥 احذف دالة dtEnd تماماً - لم تعد مستخدمة ولا ضرورية
  // ❌ DateTime get dtEnd { ... }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    intervalController.dispose();
    super.dispose();
  }
}
