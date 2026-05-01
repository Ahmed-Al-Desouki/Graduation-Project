import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/features/doctor_profile/domain/entities/achievement_profile_entity.dart';

class ExistingAchievementCard extends StatelessWidget {
  final AchievementProfileEntity achievement;
  const ExistingAchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
            ],
          ),
          if (achievement.description?.trim().isNotEmpty == true) ...[
            SizedBox(height: 8.h),
            Text(
              achievement.description!,
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280)),
            ),
          ],
          if (achievement.imageUrl?.trim().isNotEmpty == true) ...[
            SizedBox(height: 8.h),
            Text(
              'Image already attached',
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF1B4E8C)),
            ),
          ],
          if (achievement.createdAt != null) ...[
            SizedBox(height: 8.h),
            Text(
              'Added on ${achievement.createdAt!.day}/${achievement.createdAt!.month}/${achievement.createdAt!.year}',
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF)),
            ),
          ],
        ],
      ),
    );
  }
}
