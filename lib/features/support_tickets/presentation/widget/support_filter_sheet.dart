import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/support_tickets/presentation/manager/tickets_cubit/tickets_cubit.dart';
import 'package:graduation_project/features/support_tickets/presentation/widget/filter_components.dart';
import 'package:graduation_project/features/support_tickets/presentation/widget/filter_date_range_picker.dart';

// class SupportFilterSheet extends StatefulWidget {
//   const SupportFilterSheet({super.key});

//   @override
//   State<SupportFilterSheet> createState() => _SupportFilterSheetState();
// }

// class _SupportFilterSheetState extends State<SupportFilterSheet> {
//   // 1. متغيرات محلية لتخزين الاختيارات قبل الـ Apply
//   String? tempStatus;
//   String? tempPriority;
//   String? tempCategory;
//   DateTimeRange? tempDateRange;

//   @override
//   void initState() {
//     super.initState();
//     // 2. جلب القيم الحالية من الكيوبت عشان نعرضها في الـ UI
//     final currentState = context.read<SupportCubit>().state;
//     if (currentState is SupportSuccess) {
//       tempStatus = currentState.currentStatus ?? "All";
//       tempPriority = currentState.currentPriority ?? "All";
//       tempCategory = currentState.currentCategory ?? "All";
//       // مافيش تاريخ محدد في الكيوبت حالياً، فهنسيبه null
//       tempDateRange = currentState.currentDateRange;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       padding: EdgeInsets.only(
//         left: 24,
//         right: 24,
//         top: 12,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 24,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header مع زرار الـ Reset
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Advanced Filters",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               TextButton(
//                 onPressed: _clearAllFilters,
//                 child: const Text(
//                   "Reset All",
//                   style: TextStyle(color: Colors.red, fontSize: 13),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // 1. Status Filter
//           _buildDropdownLabel("Ticket Status"),
//           _buildCustomDropdown(
//             value: tempStatus, // 🚀 بنباصي القيمة المختارة حالياً
//             items: ["All", "Open", "InProgress", "Resolved", "Closed"],
//             onChanged: (val) =>
//                 setState(() => tempStatus = val), // 🚀 تحديث محلي فقط
//           ),

//           // 2. Priority Filter
//           _buildDropdownLabel("Priority Level"),
//           _buildCustomDropdown(
//             value: tempPriority,
//             items: ["All", "Low", "Normal", "High", "Urgent"],
//             onChanged: (val) => setState(() => tempPriority = val),
//           ),

//           // 3. Category Filter
//           _buildDropdownLabel("Category"),
//           _buildCustomDropdown(
//             value: tempCategory,
//             items: [
//               "All",
//               "Booking",
//               "Payment",
//               "Technical",
//               "AccountIssue",
//               "Other",
//             ],
//             onChanged: (val) => setState(() => tempCategory = val),
//           ),

//           // 4. Date Range
//           _buildDropdownLabel("Date Range"),
//           _buildDateSelector(),

//           const SizedBox(height: 32),

//           // زرار الـ Apply النهائي
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF0D9488),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onPressed: _applyFilters, // 🚀 نداء الكيوبت هنا فقط
//               child: const Text(
//                 "Apply Filters",
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- Functions ---

//   void _applyFilters() {
//     // بننادي الكيوبت ونبعت له كل القيم "المؤقتة" اللي اتخزنت في الـ State
//     context.read<SupportCubit>().fetchSupportData(
//       status: tempStatus,
//       priority: tempPriority,
//       category: tempCategory,
//       fromDate: tempDateRange?.start.toIso8601String(),
//       toDate: tempDateRange?.end.toIso8601String(),
//       page: 1,
//     );
//     Navigator.pop(context);
//   }

//   void _clearAllFilters() {
//     // 1. تصفير الـ UI المحلي
//     setState(() {
//       tempStatus = "All";
//       tempPriority = "All";
//       tempCategory = "All";
//       tempDateRange = null;
//     });
//     context.read<SupportCubit>().resetAllFilters();

//     Navigator.pop(context);
//   }

//   Widget _buildCustomDropdown({
//     required String? value, // القيمة اللي جاية من الـ initState
//     required List<String> items,
//     required Function(String?) onChanged,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           isExpanded: true,
//           value: items.contains(value)
//               ? value
//               : items.first, // 🚀 تأكيد إن القيمة موجودة في اللستة
//           items: items
//               .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//               .toList(),
//           onChanged: onChanged,
//           style: const TextStyle(color: Colors.black, fontSize: 14),
//           dropdownColor: Colors.white,
//         ),
//       ),
//     );
//   }

//   Widget _buildDateSelector() {
//     String dateText = tempDateRange == null
//         ? "Choose Period"
//         : "${tempDateRange!.start.toString().substring(0, 10)} - ${tempDateRange!.end.toString().substring(0, 10)}";

//     return InkWell(
//       onTap: () async {
//         final range = await showDateRangePicker(
//           context: context,
//           firstDate: DateTime(2024),
//           lastDate: DateTime.now(),
//         );
//         if (range != null) setState(() => tempDateRange = range);
//       },
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade50,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(dateText, style: const TextStyle(fontSize: 13)),
//             const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdownLabel(String label) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8, top: 16),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: Colors.grey.shade700,
//         ),
//       ),
//     );
//   }
// }

// presentation/widget/support_filter_sheet.dart

class SupportFilterSheet extends StatefulWidget {
  const SupportFilterSheet({super.key});

  @override
  State<SupportFilterSheet> createState() => _SupportFilterSheetState();
}

class _SupportFilterSheetState extends State<SupportFilterSheet> {
  String? tempStatus;
  String? tempPriority;
  String? tempCategory;
  DateTimeRange? tempDateRange;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<TicketsCubit>().state;
    if (currentState is TicketsSuccess) {
      tempStatus = currentState.currentStatus ?? "All";
      tempPriority = currentState.currentPriority ?? "All";
      tempCategory = currentState.currentCategory ?? "All";
      tempDateRange = currentState.currentDateRange;
    }
  }

  void _applyFilters() {
    context.read<TicketsCubit>().fetchTickets(
      isRefresh: true,
      status: tempStatus,
      priority: tempPriority,
      category: tempCategory,
      dateRange: tempDateRange,
    );
    Navigator.pop(context);
  }

  void _clearAllFilters() {
    setState(() {
      tempStatus = "All";
      tempPriority = "All";
      tempCategory = "All";
      tempDateRange = null;
    });
    context.read<TicketsCubit>().resetAllFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Component
          _FilterHeader(onReset: _clearAllFilters),
          const SizedBox(height: 16),

          // 2. Dropdown Fields
          _FilterLabel("Ticket Status"),
          FilterDropdownField(
            value: tempStatus,
            items: const ["All", "Open", "InProgress", "Resolved", "Closed"],
            onChanged: (val) => setState(() => tempStatus = val),
          ),

          _FilterLabel("Priority Level"),
          FilterDropdownField(
            value: tempPriority,
            items: const ["All", "Low", "Normal", "High", "Urgent"],
            onChanged: (val) => setState(() => tempPriority = val),
          ),

          _FilterLabel("Category"),
          FilterDropdownField(
            value: tempCategory,
            items: const [
              "All",
              "Booking",
              "Payment",
              "Technical",
              "AccountIssue",
              "Other",
            ],
            onChanged: (val) => setState(() => tempCategory = val),
          ),

          // 3. Date Range Selector
          _FilterLabel("Date Range"),
          FilterDateRangePicker(
            selectedRange: tempDateRange,
            onRangeSelected: (range) => setState(() => tempDateRange = range),
          ),

          const SizedBox(height: 32),

          // 4. Action Button
          _ApplyButton(onPressed: _applyFilters),
        ],
      ),
    );
  }
}

class _FilterHeader extends StatelessWidget {
  final VoidCallback onReset;
  const _FilterHeader({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Advanced Filters",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onReset,
          child: const Text(
            "Reset All",
            style: TextStyle(color: Colors.red, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _FilterLabel extends StatelessWidget {
  final String label;
  const _FilterLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ApplyButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D9488),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: const Text(
          "Apply Filters",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
