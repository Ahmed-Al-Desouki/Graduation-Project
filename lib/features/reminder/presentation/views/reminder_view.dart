// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graduation_project/core/utils/app_router.dart';
// import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
// import 'package:graduation_project/core/utils/helper/service_locator.dart';
// import 'package:graduation_project/features/auth/data/models/reminder_model.dart';
// import 'package:graduation_project/features/auth/presentation/manger/reminder_cubit/reminder_cubit.dart';

// // 🔴 تأكد أنك تستخدم هذا الملف الآن لاستيراد الموديل الذي يمثل بيانات العرض
// import 'package:graduation_project/features/auth/data/models/reminder_instance_model.dart';

// import 'package:graduation_project/features/auth/presentation/views/add_reminder_view.dart';
// import 'package:graduation_project/features/auth/presentation/views/widgets/reminder_appointment_card.dart';
// import 'package:graduation_project/features/auth/presentation/views/widgets/reminder_header.dart';
// import 'package:graduation_project/features/auth/presentation/views/widgets/reminder_medication_card.dart';
// import 'package:graduation_project/features/auth/presentation/views/widgets/reminder_section_header.dart';

// class ReminderView extends StatefulWidget {
//   const ReminderView({super.key});

//   @override
//   State<ReminderView> createState() => _ReminderViewState();
// }

// class _ReminderViewState extends State<ReminderView> {
//   bool isHovering = false;

//   @override
//   Widget build(BuildContext context) {
//     // 1. استخدام Material لتجنب خطأ "No Material widget found"
//     return Material(
//       child: FutureBuilder<String?>(
//         // جلب معرف المستخدم أولاً
//         future: SecureStorageHelper.getUserId(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData || snapshot.data == null) {
//             // عرض شاشة تحميل أثناء جلب الـ ID
//             return const Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             );
//           }

//           final userId = snapshot.data!;

//           return BlocProvider(
//             // 2. إنشاء الـ Cubit وبدء تحميل التذكيرات
//             create: (_) => getIt<ReminderCubit>()..loadUpcoming(userId),
//             child: Scaffold(
//               backgroundColor: Colors.white,
//               appBar: AppBar(
//                 backgroundColor: Colors.white,
//                 elevation: 0,
//                 leading: IconButton(
//                   icon: const Icon(Icons.arrow_back, color: Colors.black),
//                   onPressed: () {
//                     AppRouter.router.go(AppRouter.kHomePatient);
//                   },
//                 ),
//                 actions: const [
//                   Padding(
//                     padding: EdgeInsets.only(right: 16.0),
//                     child: Icon(Icons.notifications, color: Colors.black),
//                   ),
//                 ],
//               ),
//               body: BlocBuilder<ReminderCubit, ReminderState>(
//                 builder: (context, state) {
//                   // 3. معالجة حالات الـ Bloc
//                   if (state is ReminderLoading) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   if (state is ReminderFailure) {
//                     return Center(child: Text('Error: ${state.message}'));
//                   }

//                   if (state is ReminderLoaded) {
//                     // الـ Reminders هنا هي List<ReminderInstanceModel>
//                     final List<ReminderInstanceModel> allReminders =
//                         state.reminders;

//                     // تصفية التذكيرات حسب النوع والفرز
//                     final List<ReminderInstanceModel> appointmentReminders =
//                         allReminders
//                             .where((r) => r.type == 'Appointment')
//                             .toList()
//                           ..sort(
//                             (a, b) => a.dueDateTime.compareTo(b.dueDateTime),
//                           );

//                     final List<ReminderInstanceModel> medicationReminders =
//                         allReminders
//                             .where((r) => r.type == 'Medication')
//                             .toList()
//                           ..sort(
//                             (a, b) => a.dueDateTime.compareTo(b.dueDateTime),
//                           );

//                     return SingleChildScrollView(
//                       padding: const EdgeInsets.symmetric(horizontal: 30),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 8),
//                           ReminderHeader(),
//                           const SizedBox(height: 20),

//                           // Upcoming Appointments Section
//                           ReminderSectionHeader(
//                             title: 'Upcoming Appointments',
//                             count:
//                                 appointmentReminders
//                                     .length, // عدد المواعيد من الـ API
//                             isUpcoming: true,
//                           ),
//                           const SizedBox(height: 10),

//                           // عرض كروت المواعيد
//                           if (appointmentReminders.isEmpty)
//                             const Text('No upcoming appointments.'),
//                           ...appointmentReminders
//                               .map(
//                                 (appt) => Padding(
//                                   padding: const EdgeInsets.only(bottom: 15),
//                                   child: ReminderAppointmentCard(
//                                     name: appt.name,
//                                     specialization:
//                                         "N/A", // قد تحتاج لجلبها من API آخر لاحقًا
//                                     date:
//                                         "${appt.dueDateTime.year}-${appt.dueDateTime.month}-${appt.dueDateTime.day}",
//                                     time:
//                                         "${appt.dueDateTime.hour}:${appt.dueDateTime.minute.toString().padLeft(2, '0')}",
//                                     statusText: appt.status,
//                                     statusColor: Colors.blue,
//                                   ),
//                                 ),
//                               )
//                               .toList(),

//                           const SizedBox(height: 25),

//                           // Medication Reminders Section
//                           ReminderSectionHeader(
//                             title: 'Medication Reminders',
//                             count:
//                                 medicationReminders
//                                     .length, // عدد الأدوية من الـ API
//                             isUpcoming: false,
//                           ),
//                           const SizedBox(height: 10),

//                           // عرض كروت الأدوية
//                           if (medicationReminders.isEmpty)
//                             const Text('No upcoming medication reminders.'),
//                           ...medicationReminders
//                               .map(
//                                 (reminder) => Padding(
//                                   padding: const EdgeInsets.only(bottom: 15),
//                                   child: ReminderMedicationCard(
//                                     title: reminder.name,
//                                     subtitle:
//                                         reminder.message ??
//                                         'Take as prescribed',
//                                     time:
//                                         "${reminder.dueDateTime.hour}:${reminder.dueDateTime.minute.toString().padLeft(2, '0')}",
//                                     next:
//                                         "${reminder.dueDateTime.hour}:${reminder.dueDateTime.minute.toString().padLeft(2, '0')}",
//                                     frequency:
//                                         "N/A", // قد تحتاج لجلبها من API آخر لاحقًا
//                                     buttonColor: Colors.green,
//                                     buttonText: "Mark Taken",
//                                   ),
//                                 ),
//                               )
//                               .toList(),

//                           const SizedBox(height: 90),
//                         ],
//                       ),
//                     );
//                   }

//                   return const SizedBox();
//                 },
//               ),
//               // Floating Action Button
//               floatingActionButton: MouseRegion(
//                 onEnter: (_) => setState(() => isHovering = true),
//                 onExit: (_) => setState(() => isHovering = false),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 400),
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                     gradient: LinearGradient(
//                       colors: const [
//                         Color.fromARGB(255, 4, 249, 12),
//                         Color(0xFF1B4E8C),
//                       ],
//                       begin:
//                           isHovering
//                               ? Alignment.bottomRight
//                               : Alignment.topLeft,
//                       end:
//                           isHovering
//                               ? Alignment.topLeft
//                               : Alignment.bottomRight,
//                     ),
//                   ),
//                   child: FloatingActionButton(
//                     elevation: 0,
//                     backgroundColor: Colors.transparent,
//                     onPressed: () async {
//                       final newReminder = await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const AddReminderView(),
//                         ),
//                       );

//                       // 4. استدعاء Cubit لإضافة التذكير بعد العودة من AddReminderView
//                       if (newReminder is ReminderModel) {
//                         // استخدام BlocProvider.of<ReminderCubit>(context) بعد التأكد من وجوده
//                         final cubit = BlocProvider.of<ReminderCubit>(context);
//                         cubit.addReminder(userId, newReminder);

//                         // Cubit سيقوم تلقائياً بعمل loadUpcoming بعد الإضافة الناجحة،
//                         // مما سيؤدي إلى تحديث شاشة العرض (BlocBuilder)
//                       }
//                     },
//                     child: const Icon(Icons.add, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graduation_project/core/utils/app_router.dart';
// import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
// import 'package:graduation_project/core/utils/helper/service_locator.dart';
// import 'package:graduation_project/features/reminder/data/models/reminder_model.dart';
// import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
// import 'package:graduation_project/features/reminder/presentation/views/add_reminder_view.dart';
// import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_appointment_card.dart';
// import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_header.dart';
// import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_medication_card.dart';
// import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_section_header.dart';

// class ReminderView extends StatelessWidget {
//   const ReminderView({super.key});

// @override
// Widget build(BuildContext context) {
//   return Material(
//     child: FutureBuilder(
//       future: SecureStorageHelper.getUserId(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Center(child: CircularProgressIndicator());
//         }

//         final userId = snapshot.data!;
//         print("USER ID = $userId");

//         return BlocProvider(
//           create: (_) => getIt<ReminderCubit>()..loadUpcoming(userId),
//           child: BlocBuilder<ReminderCubit, ReminderState>(
//             builder: (context, state) {
//               if (state is ReminderLoading) {
//                 return Center(child: CircularProgressIndicator());
//               }

//               if (state is ReminderFailure) {
//                 return Center(child: Text(state.message));
//               }

//               if (state is ReminderLoaded) {
//                 return ListView.builder(
//                   itemCount: state.reminders.length,
//                   itemBuilder: (context, index) {
//                     final r = state.reminders[index];
//                     return Card(
//                       child: ListTile(
//                         title: Text(r.name),
//                         subtitle: Text("${r.type}: ${r.dueDateTime.toLocal()}"),
//                       ),
//                     );
//                   },
//                 );
//               }

//               return SizedBox();
//             },
//           ),
//         );
//       },
//     ),
//   );
// }

// @override
// Widget build(BuildContext context) {
//   final userId = SecureStorageHelper.getUserId();

//   return BlocProvider(
//     create: (_) => getIt<ReminderCubit>()..loadUpcoming(userId),
//     child: BlocBuilder<ReminderCubit, ReminderState>(
//       builder: (context, state) {
//         if (state is ReminderLoading) {
//           return Center(child: CircularProgressIndicator());
//         }

//         if (state is ReminderFailure) {
//           return Center(child: Text(state.message));
//         }

//         if (state is ReminderLoaded) {
//           return ListView.builder(
//             itemCount: state.reminders.length,
//             itemBuilder: (context, index) {
//               final r = state.reminders[index];
//               return Card(
//                 child: ListTile(
//                   title: Text(r["name"]),
//                   subtitle: Text(r["frequency"]),
//                 ),
//               );
//             },
//           );
//         }

//         return Container();
//       },
//     ),
//   );
// }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart'; // عشان getIt
import 'package:graduation_project/features/reminder/data/models/reminder_instance_model.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_state.dart';
import 'package:graduation_project/features/reminder/presentation/views/add_reminder_view.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_appointment_card.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_custom_card.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_header.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_medication_card.dart';
import 'package:graduation_project/features/reminder/presentation/views/widgets/reminder_section_header.dart';

class ReminderView extends StatefulWidget {
  const ReminderView({super.key});

  @override
  State<ReminderView> createState() => _ReminderViewState();
}

class _ReminderViewState extends State<ReminderView> {
  bool isHovering = false;

  @override
  void initState() {
    super.initState();
    // استدعاء البيانات عند فتح الصفحة
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    final patientId = await SecureStorageHelper.getUserId();
    print("DEBUG: Fetched Patient ID is: $patientId");
    if (patientId != null && patientId.isNotEmpty && mounted) {
      context.read<ReminderCubit>().getTodayReminders(patientId: patientId);
    } else {
      print("DEBUG: patientId is invalid or missing, cannot fetch reminders.");
      // يمكنك هنا عرض رسالة خطأ للمستخدم ليقوم بتسجيل الدخول
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            AppRouter.router.go(AppRouter.kHomePatient);
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications, color: Colors.black),
          ),
        ],
      ),
      body: BlocConsumer<ReminderCubit, ReminderState>(
        listener: (context, state) {
          // إذا تم إضافة تذكير بنجاح (والعودة لهذه الصفحة)، نعيد تحميل القائمة
          if (state is ReminderCreateSuccess) {
            _fetchReminders();
          }
        },
        builder: (context, state) {
          if (state is ReminderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UpcomingRemindersFailure) {
            return Center(child: Text('Error: ${state.errMessage}'));
          }

          List<ReminderInstanceModel> meds = [];
          List<ReminderInstanceModel> appts = [];
          List<ReminderInstanceModel> customs = [];

          if (state is UpcomingRemindersSuccess) {
            meds = state.medications;
            appts = state.appointments;
            customs = state.customs;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const ReminderHeader(),

                // ---------- Appointments UI ----------
                ReminderSectionHeader(
                  title: 'Upcoming Appointments',
                  count: appts.length,
                  isUpcoming: true,
                ),
                const SizedBox(height: 10),

                if (appts.isEmpty) const Text("No upcoming appointments", style: TextStyle(color: Colors.grey)),

                for (var appt in appts)
                  ReminderAppointmentCard(
                    name: appt.title,
                    specialization:
                        "Doctor",
                    // معالجة التاريخ والوقت من dueDateTime
                    date: appt.dueDateTime.split('T')[0],
                    time: _formatTime(appt.dueDateTime),
                    statusText: appt.status,
                    statusColor: Colors.blue,
                  ),

                const SizedBox(height: 25),

                // ---------- Medications UI ----------
                ReminderSectionHeader(
                  title: 'Medication Reminders',
                  count: meds.length,
                  isUpcoming: false,
                ),
                const SizedBox(height: 10),

                if (meds.isEmpty) const Text("No medication reminders", style: TextStyle(color: Colors.grey)),

                for (var reminder in meds)
                  ReminderMedicationCard(
                    title: reminder.title,
                    subtitle: reminder.message ?? "Take as prescribed",
                    time: _formatTime(reminder.dueDateTime),
                    next: _formatTime(reminder.dueDateTime),
                    frequency: reminder.type,
                    buttonColor: Colors.green,
                    buttonText: "Mark Taken",
                  ),

                  const SizedBox(height: 25),

                // ---------- Custom UI ----------
                ReminderSectionHeader(
                  title: 'Custom Reminders',
                  count: customs.length,
                  isUpcoming: false,
                  customColor: Colors.orange.shade700
                ),
                const SizedBox(height: 10),

                if (customs.isEmpty) const Text("No custom reminders", style: TextStyle(color: Colors.grey)),

                for (var custom in customs)
                  ReminderCustomCard(
                    title: custom.title,
                    subtitle: custom.message ?? "Don't forget!",
                    time: _formatTime(custom.dueDateTime),
                    next: _formatTime(custom.dueDateTime),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 4, 249, 12), Color(0xFF1B4E8C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BlocProvider.value(
                      value: context.read<ReminderCubit>(),
                      child: const AddReminderView(),
                    ),
              ),
            );
            // عند العودة، نعيد تحميل البيانات للتأكد من التحديث
            _fetchReminders();
          },
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  // دالة مساعدة لتنسيق الوقت
  String _formatTime(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "--:--";
    }
  }
}
// ---------------------------------------------------------------------------------------------------------------
// class ReminderView extends StatefulWidget {
//   const ReminderView({super.key});

//   @override
//   State<ReminderView> createState() => _ReminderViewState();
// }

// class _ReminderViewState extends State<ReminderView> {
//   String? _currentIdempotencyKey;
//   List<ReminderModel> medicationReminders = [];
//   List<ReminderModel> appointmentReminders = [];

//   bool isHovering = false;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             AppRouter.router.go(AppRouter.kHomePatient);
//           },
//         ),
//         actions: const [
//           Padding(
//             padding: EdgeInsets.only(right: 16.0),
//             child: Icon(Icons.notifications, color: Colors.black),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 30),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 8),
//             ReminderHeader(),

//             // Upcoming Appointments Title
//             ReminderSectionHeader(
//               title: 'Upcoming Appointments',
//               count: 2,
//               isUpcoming: true,
//             ),
//             const SizedBox(height: 10),

//             for (var appt in appointmentReminders)
//               ReminderAppointmentCard(
//                 name: appt.name,
//                 specialization: "Your data here",
//                 date: appt.startDate.toString(),
//                 time: appt.baseTime,
//                 statusText: "Scheduled",
//                 statusColor: Colors.blue,
//               ),

//             const SizedBox(height: 25),

//             // Medication Reminders
//             ReminderSectionHeader(
//               title: 'Medication Reminders',
//               count: 4,
//               isUpcoming: false,
//             ),
//             const SizedBox(height: 10),

//             for (var reminder in medicationReminders)
//               ReminderMedicationCard(
//                 title: reminder.name,
//                 subtitle: "Your dosage info here", // ده هيتظبط من backend
//                 time: reminder.baseTime,
//                 next: reminder.baseTime,
//                 frequency: reminder.frequency,
//                 buttonColor: Colors.green,
//                 buttonText: "Mark Taken",
//               ),
//             const SizedBox(height: 90),
//           ],
//         ),
//       ),
//       floatingActionButton: MouseRegion(
//         onEnter: (_) => setState(() => isHovering = true),
//         onExit: (_) => setState(() => isHovering = false),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 400),
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             gradient: LinearGradient(
//               colors: const [
//                 Color.fromARGB(255, 4, 249, 12),
//                 Color(0xFF1B4E8C),
//               ],
//               begin: isHovering ? Alignment.bottomRight : Alignment.topLeft,
//               end: isHovering ? Alignment.topLeft : Alignment.bottomRight,
//             ),
//           ),
//           child: FloatingActionButton(
//             elevation: 0,
//             backgroundColor: Colors.transparent,
//             onPressed: () async {
//               final newReminder = await Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => BlocProvider.value(
//       value: context.read<ReminderCubit>(),
//       child: const AddReminderView(),
//     ),
//   ),
// );


//               if (newReminder != null) {
//                 setState(() {
//                   if (newReminder.type == 'Medication') {
//                     medicationReminders.add(newReminder);
//                   } else if (newReminder.type == 'Appointment') {
//                     appointmentReminders.add(newReminder);
//                   }
//                 });
//               }
//             },

//             child: const Icon(Icons.add, color: Colors.white),
//           ),
//         ),
//       ),
//     );
//   }
// }


// --------------------------------------------------------------------------------------------------------------
// class ReminderView extends StatefulWidget {
//   const ReminderView({super.key});

//   @override
//   State<ReminderView> createState() => _ReminderViewState();
// }

// class _ReminderViewState extends State<ReminderView> {
//   String? _currentIdempotencyKey;
//   // List<ReminderModel> medicationReminders = [];
//   // List<ReminderModel> appointmentReminders = [];

//   bool isHovering = false;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             AppRouter.router.go(AppRouter.kHomePatient);
//           },
//         ),
//         actions: const [
//           Padding(
//             padding: EdgeInsets.only(right: 16.0),
//             child: Icon(Icons.notifications, color: Colors.black),
//           ),
//         ],
//       ),
//       body: BlocBuilder<ReminderCubit, ReminderState>(
//   builder: (context, state) {
    
//     if (state is ReminderLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (state is UpcomingRemindersFailure) {
//       return Center(child: Text(state.message));
//     }

//     if (state is UpcomingRemindersSuccess) {
//       final meds = state.medications;
//       final appts = state.appointments;

//       return SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 30),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             ReminderHeader(),

//             // ---------- Appointments UI ----------
//             ReminderSectionHeader(
//               title: "Upcoming Appointments",
//               count: appts.length,
//               isUpcoming: true,
//             ),

//             const SizedBox(height: 10),

//             for (var appt in appts)
//               ReminderAppointmentCard(
//                 name: appt.name,
//                 specialization: "Doctor",
//                 date: appt.startDate.toString(),
//                 time: appt.baseTime,
//                 statusText: "Scheduled",
//                 statusColor: Colors.blue,
//               ),

//             const SizedBox(height: 25),

//             // ---------- Medications UI ----------
//             ReminderSectionHeader(
//               title: "Medication Reminders",
//               count: meds.length,
//               isUpcoming: false,
//             ),
//             const SizedBox(height: 10),

//             for (var reminder in meds)
//               ReminderMedicationCard(
//                 title: reminder.name,
//                 subtitle: reminder.message,
//                 time: reminder.baseTime,
//                 next: reminder.baseTime,
//                 frequency: reminder.frequency,
//                 buttonColor: Colors.green,
//                 buttonText: "Mark Taken",
//               ),

//           ],
//         ),
//       );
//     }

//     return Container(); // fallback
//   },
// ),

//       floatingActionButton: MouseRegion(
//         onEnter: (_) => setState(() => isHovering = true),
//         onExit: (_) => setState(() => isHovering = false),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 400),
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             gradient: LinearGradient(
//               colors: const [
//                 Color.fromARGB(255, 4, 249, 12),
//                 Color(0xFF1B4E8C),
//               ],
//               begin: isHovering ? Alignment.bottomRight : Alignment.topLeft,
//               end: isHovering ? Alignment.topLeft : Alignment.bottomRight,
//             ),
//           ),
//           child: FloatingActionButton(
//             elevation: 0,
//             backgroundColor: Colors.transparent,
//             onPressed: () async {
//               final newReminder = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const AddReminderView(),
//                 ),
//               );

//               if (newReminder != null) {
//                 setState(() {
//                   if (newReminder.type == 'Medication') {
//                     state.medications.add(newReminder);
//                   } else if (newReminder.type == 'Appointment') {
//                     state.appointments.add(newReminder);
//                   }
//                 });
//               }
//             },

//             child: const Icon(Icons.add, color: Colors.white),
//           ),
//         ),
//       ),
//     );
//   }
// }
