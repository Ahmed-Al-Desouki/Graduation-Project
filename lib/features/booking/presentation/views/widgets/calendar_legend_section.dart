import 'package:flutter/material.dart';

class CalendarLegendSection extends StatelessWidget {
  const CalendarLegendSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildLegendItem(const Color(0xFF10B981), "Available"),
          _buildLegendItem(const Color(0xFF3B82F6), "Full"),
          _buildLegendItem(const Color(0xFF94A3B8), "Blocked"),
          _buildLegendItem(const Color(0xFF9333EA), "Today"),
          _buildLegendItem(Colors.orange, "Selected"),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
