import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_home/presentation/views/widgets/optional_details_section.dart';

class AchievementItem extends StatelessWidget {
  final AchievementModel achievement;
  final VoidCallback onDelete;

  const AchievementItem({
    super.key,
    required this.achievement,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: const Color(0xFFF59E0B),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red, size: 18),
                ),
              ),
            ],
          ),
          if (achievement.description.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              achievement.description,
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280)),
            ),
          ],
          if (achievement.image != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                achievement.image!,
                height: 100.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            'Added on ${achievement.createdAt.day}/${achievement.createdAt.month}/${achievement.createdAt.year}',
            style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}
