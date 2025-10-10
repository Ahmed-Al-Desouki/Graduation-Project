import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class CustomNotificationTile extends StatelessWidget {
  final IconData? icon;
  final Color color;
  final String? imagePath;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const CustomNotificationTile({
    super.key,
    this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.15),
            child:
                imagePath != null
                    ? SvgPicture.asset(
                      imagePath!,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    )
                    : Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyles.styleMedium14Dark),
                const SizedBox(height: 4),
                Text(subtitle, style: AppStyles.styleRegular12GrayAlt),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3A85EE),
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
