// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:graduation_project/features/support_tickets/presentation/manager/tickets_cubit/tickets_cubit.dart';

// class SupportTabsBar extends StatelessWidget {
//   final String? currentStatus;
//   const SupportTabsBar({super.key, this.currentStatus});

//   @override
//   Widget build(BuildContext context) {
//     bool isActiveTab = currentStatus == null || currentStatus != "Resolved";
//     return Row(
//       children: [
//         _TabButton(
//           label: "Active",
//           isActive: isActiveTab,
//           onTap:
//               () => context.read<TicketsCubit>().fetchSupportData(
//                 status: "Open",
//                 page: 1,
//               ),
//         ),
//         const SizedBox(width: 12),
//         _TabButton(
//           label: "Resolved",
//           isActive: !isActiveTab,
//           onTap:
//               () => context.read<TicketsCubit>().fetchSupportData(
//                 status: "Resolved",
//                 page: 1,
//               ),
//         ),
//       ],
//     );
//   }
// }

// class _TabButton extends StatelessWidget {
//   final String label;
//   final bool isActive;
//   final VoidCallback onTap;

//   const _TabButton({
//     required this.label,
//     required this.isActive,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: isActive ? Colors.white : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow:
//               isActive
//                   ? [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ]
//                   : null,
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
//             color: isActive ? Colors.black : Colors.grey.shade600,
//             fontSize: 14,
//           ),
//         ),
//       ),
//     );
//   }
// }
