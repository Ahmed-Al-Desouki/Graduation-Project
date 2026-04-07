import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedicalHistoryListLayout extends StatelessWidget {
  final String title;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final DateTimeRange? selectedDateRange;
  final VoidCallback? onClearDateRange;
  final VoidCallback? onPickDateRange;
  final List<Widget>? appBarActions;
  final Widget? filterHeader;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final String emptyMessage;
  final Color themeColor;
  final IconData fabIcon;
  final VoidCallback? onFabPressed;

  const MedicalHistoryListLayout({
    super.key,
    required this.title,
    required this.searchHint,
    required this.onSearchChanged,
    this.selectedDateRange,
    this.onClearDateRange,
    this.onPickDateRange,
    this.appBarActions,
    this.filterHeader,
    required this.itemCount,
    required this.itemBuilder,
    required this.emptyMessage,
    this.themeColor = const Color(0xFF2563EB),
    this.fabIcon = Icons.add,
    this.onFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black),
        actions: [
          if (selectedDateRange != null && onClearDateRange != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off, color: Colors.red),
              onPressed: onClearDateRange,
            ),
          if (onPickDateRange != null)
            IconButton(
              icon: Icon(
                Icons.calendar_month,
                color: selectedDateRange != null ? themeColor : Colors.grey,
              ),
              onPressed: onPickDateRange,
            ),
          ...?appBarActions,
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: searchHint,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (filterHeader != null) ...[
                  const SizedBox(height: 12),
                  filterHeader!,
                ],
              ],
            ),
          ),
          if (selectedDateRange != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      "${DateFormat('MMM dd, yyyy').format(selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(selectedDateRange!.end)}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: themeColor,
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                    onDeleted: onClearDateRange,
                  ),
                ],
              ),
            ),
          Expanded(
            child:
                itemCount == 0
                    ? Center(
                      child: Text(
                        emptyMessage,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: itemCount,
                      itemBuilder: itemBuilder,
                    ),
          ),
        ],
      ),
      floatingActionButton:
          onFabPressed == null
              ? null
              : FloatingActionButton(
                onPressed: onFabPressed,
                backgroundColor: themeColor,
                child: Icon(fabIcon, color: Colors.white),
              ),
    );
  }
}
