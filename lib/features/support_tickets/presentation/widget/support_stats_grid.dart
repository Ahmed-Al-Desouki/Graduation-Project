// // widgets/support_stats_grid.dart
// import 'package:admin_dashboard_graduation_project/features/support_tickets/domain/entities/support_stats_entity.dart';
// import 'package:admin_dashboard_graduation_project/features/support_tickets/presentation/widget/stat_card.dart';
// import 'package:flutter/material.dart';

// class SupportStatsGrid extends StatelessWidget {
//   final SupportStatsEntity stats;
//   const SupportStatsGrid({super.key, required this.stats});

//   @override
//   Widget build(BuildContext context) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//       childAspectRatio: 2.5,
//       children: [
//         StatCard(
//           title: "Open",
//           value: "${stats.openTickets}",
//           icon: Icons.lock_open,
//           color: Colors.orange,
//         ),
//         StatCard(
//           title: "In Progress",
//           value: "${stats.inProgressTickets}",
//           icon: Icons.message,
//           color: Colors.blue,
//         ),
//         StatCard(
//           title: "Resolved",
//           value: "${stats.resolvedTickets}",
//           icon: Icons.check_circle,
//           color: Colors.green,
//         ),
//         StatCard(
//           title: "Urgent",
//           value: "${stats.urgentTickets}",
//           icon: Icons.error,
//           color: Colors.red,
//         ),
//       ],
//     );
//   }
// }
