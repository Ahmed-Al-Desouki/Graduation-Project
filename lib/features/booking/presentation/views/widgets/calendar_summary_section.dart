import 'package:flutter/material.dart';
import '../../../domain/entities/day_slots_entity.dart';

class CalendarSummarySection extends StatelessWidget {
  final List<DaySlotsEntity> allDays;

  const CalendarSummarySection({super.key, required this.allDays});

  @override
  Widget build(BuildContext context) {
    // 📊 حساب الإحصائيات من قائمة الأيام
    int totalAvailable = 0;
    int totalBooked = 0;
    int totalBlocked = 0;

    for (var day in allDays) {
      for (var slot in day.slots) {
        final status = slot.status.toLowerCase();
        if (status == 'available') totalAvailable++;
        if (status == 'booked' || status == 'confirmed') totalBooked++;
        if (status == 'blocked') totalBlocked++;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildSummaryCard(
            label: "Available",
            count: totalAvailable,
            color: const Color(0xFF10B981), // الأخضر
            icon: Icons.event_available,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            label: "Booked",
            count: totalBooked,
            color: const Color(0xFF3B82F6), // الأزرق
            icon: Icons.bookmark_added,
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            label: "Blocked",
            count: totalBlocked,
            color: const Color(0xFF94A3B8), // الرمادي
            icon: Icons.block_flipped,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              "$count",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
