import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/support_tickets/presentation/manager/tickets_cubit/tickets_cubit.dart';
import 'package:graduation_project/features/support_tickets/presentation/widget/filter_components.dart';
import 'package:graduation_project/features/support_tickets/presentation/widget/filter_date_range_picker.dart';

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
          _FilterHeader(onReset: _clearAllFilters),
          const SizedBox(height: 16),

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

          _FilterLabel("Date Range"),
          FilterDateRangePicker(
            selectedRange: tempDateRange,
            onRangeSelected: (range) => setState(() => tempDateRange = range),
          ),

          const SizedBox(height: 32),

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
