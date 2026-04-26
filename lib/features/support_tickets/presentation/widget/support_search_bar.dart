import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/support_tickets/presentation/manager/tickets_cubit/tickets_cubit.dart';
import 'package:graduation_project/features/support_tickets/presentation/widget/support_filter_sheet.dart';

// class SupportSearchBar extends StatelessWidget {
//   const SupportSearchBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       onChanged: (val) => context.read<SupportCubit>().searchTickets(val),
//       decoration: InputDecoration(
//         hintText: "Search by subject, user, or ticket ID...",
//         prefixIcon: const Icon(Icons.search, size: 20),
//         fillColor: Colors.white,
//         filled: true,
//         contentPadding: const EdgeInsets.symmetric(vertical: 0),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey.shade200),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey.shade200),
//         ),
//       ),
//     );
//   }
// }

// widgets/support_search_bar.dart
class SupportSearchBar extends StatelessWidget {
  const SupportSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Expanded(
        //   child: TextField(
        //     onChanged: (val) => context.read<TicketsCubit>().searchTickets(val),
        //     decoration: InputDecoration(
        //       hintText: "Search tickets...",
        //       prefixIcon: const Icon(Icons.search, size: 20),
        //       fillColor: Colors.white,
        //       filled: true,
        //       contentPadding: const EdgeInsets.symmetric(vertical: 0),
        //       border: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(10),
        //         borderSide: BorderSide(color: Colors.grey.shade200),
        //       ),
        //       enabledBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(10),
        //         borderSide: BorderSide(color: Colors.grey.shade200),
        //       ),
        //     ),
        //   ),
        // ),
        const SizedBox(width: 12),
        // زرار الفلترة الذكي
        _buildFilterButton(context),
      ],
    );
  }

  // Widget _buildFilterMenu(BuildContext context) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(10),
  //       border: Border.all(color: Colors.grey.shade200),
  //     ),
  //     child: PopupMenuButton<String>(
  //       icon: const Icon(Icons.filter_list, color: Colors.grey),
  //       onSelected: (value) {
  //         context.read<SupportCubit>().fetchSupportData(status: value, page: 1);
  //       },
  //       itemBuilder: (context) => [
  //         const PopupMenuItem(value: "All", child: Text("All Statuses")),
  //         const PopupMenuItem(value: "Open", child: Text("Open Only")),
  //         const PopupMenuItem(
  //           value: "InProgress",
  //           child: Text("In Progress Only"),
  //         ),
  //         const PopupMenuItem(value: "Resolved", child: Text("Resolved Only")),
  //         const PopupMenuItem(value: "Closed", child: Text("Closed Only")),
  //       ],
  //     ),
  //   );
  // }
  // widgets/support_search_bar.dart
  Widget _buildFilterButton(BuildContext context) {
    // 1. بناخد نسخة من الكيوبت الحالي قبل ما نفتح الشيت
    final supportCubit = context.read<TicketsCubit>();

    return IconButton(
      icon: const Icon(Icons.tune, color: Colors.grey),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent, // عشان نعرف نعمل زوايا مدورة
          builder:
              (context) => BlocProvider.value(
                value: supportCubit, // 2. بنباصي الكيوبت للشيت عشان يشوفه
                child: const SupportFilterSheet(),
              ),
        );
      },
    );
  }
}
