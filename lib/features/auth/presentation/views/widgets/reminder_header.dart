import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class ReminderHeader extends StatelessWidget {
  const ReminderHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.lightBlue.withOpacity(0.1),
            child: _ClockCalendarIcon(size: 28),
          ),
          const SizedBox(height: 7),
          Text(
            'My Reminders',
            style: AppStyles.styleSemiBold18Dark.copyWith(fontSize: 20),
          ),
          Text(
            'Stay on top of your health routine',
            style: AppStyles.styleRegular14Muted,
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey, thickness: 0.5),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ClockCalendarIcon extends StatelessWidget {
  final double size;
  const _ClockCalendarIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Icon(Icons.access_time_filled, size: size, color: Colors.lightBlue),
          Align(
            alignment: const Alignment(2.5, -1.5),
            child: SvgPicture.asset(
              Assets.imagesCalendarDays,
              height: 17,
              width: 17,
              colorFilter: const ColorFilter.mode(
                Color.fromARGB(255, 56, 203, 63),
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
