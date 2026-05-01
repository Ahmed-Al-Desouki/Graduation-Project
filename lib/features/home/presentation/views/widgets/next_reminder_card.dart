import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_cubit.dart';
import 'package:graduation_project/features/reminder/presentation/manager/reminder_cubit/reminder_state.dart';
import 'package:intl/intl.dart';

// class NextReminderCard extends StatelessWidget {
//   const NextReminderCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ReminderCubit, ReminderState>(
//       builder: (context, state) {
//         if (state is ReminderLoading || state is GetAllRemindersLoading) {
//           return const Center(
//             child: CircularProgressIndicator(color: Color(0xff66BB6A)),
//           );
//         }

//         if (state is UpcomingRemindersSuccess) {
//           final allInstances = [
//             ...state.medications,
//             ...state.appointments,
//             ...state.customs,
//           ];

//           if (allInstances.isEmpty) return const SizedBox();

//           // 1. ترتيب المواعيد بعد تحويل الـ String لـ DateTime
//           allInstances.sort((a, b) {
//             return DateTime.parse(
//               a.dueDateTime,
//             ).compareTo(DateTime.parse(b.dueDateTime));
//           });

//           // 2. البحث عن أول موعد قادم (بعد الوقت الحالي)
//           final next = allInstances.firstWhere(
//             (e) => DateTime.parse(e.dueDateTime).isAfter(DateTime.now()),
//             orElse: () => allInstances.first,
//           );

//           final nextDateTime = DateTime.parse(next.dueDateTime);
//           final timeDiff = nextDateTime.difference(DateTime.now());

//           final hours = timeDiff.inHours;
//           final minutes = timeDiff.inMinutes % 60;

//           String timeText =
//               hours > 0
//                   ? "In $hours hours (${DateFormat.jm().format(nextDateTime)})"
//                   : "In $minutes minutes (${DateFormat.jm().format(nextDateTime)})";

//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 40),
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xff66BB6A),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Next Reminder",
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     next.title, //
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     next.message ?? "Time for your dose", //
//                     style: const TextStyle(color: Colors.white70, fontSize: 13),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.access_time,
//                         size: 14,
//                         color: Colors.white,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         timeText,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         return const SizedBox();
//       },
//     );
//   }
// }

class NextReminderCard extends StatelessWidget {
  const NextReminderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff66BB6A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: BlocBuilder<ReminderCubit, ReminderState>(
          builder: (context, state) {
            if (state is ReminderLoading || state is GetAllRemindersLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (state is UpcomingRemindersSuccess) {
              final allInstances = [
                ...state.medications,
                ...state.appointments,
                ...state.customs,
              ];

              // البحث عن المواعيد المستقبلية فقط
              final upcomingInstances =
                  allInstances.where((e) {
                    return DateTime.parse(
                      e.dueDateTime,
                    ).isAfter(DateTime.now());
                  }).toList();

              // 💡 لو مفيش أي تذكيرات قادمة
              if (upcomingInstances.isEmpty) {
                return _buildEmptyState();
              }

              // ترتيب المواعيد القادمة فقط
              upcomingInstances.sort((a, b) {
                return DateTime.parse(
                  a.dueDateTime,
                ).compareTo(DateTime.parse(b.dueDateTime));
              });

              final next = upcomingInstances.first;
              final nextDateTime = DateTime.parse(next.dueDateTime);
              final timeDiff = nextDateTime.difference(DateTime.now());
              final hours = timeDiff.inHours;
              final minutes = timeDiff.inMinutes % 60;

              String timeText =
                  hours > 0
                      ? "In $hours hours (${DateFormat.jm().format(nextDateTime)})"
                      : "In $minutes minutes (${DateFormat.jm().format(nextDateTime)})";

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Next Reminder",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    next.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    next.message ?? "Time for your dose",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            // في حالة الـ Failure أو أي حالة أخرى
            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Next Reminder",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          "No upcoming reminders for today",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Stay healthy and hydrated!",
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
