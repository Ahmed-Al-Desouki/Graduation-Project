import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/trash/quick_access_button.dart';

class QuickAccess extends StatelessWidget {
  const QuickAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25),
          child: Text(
            'Quick Access',
            style: AppStyles.styleSemiBold18Dark.copyWith(fontSize: 20),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            QuickAccessButton(
              icon: Icons.search,
              label: 'Find\nDoctor',
              color: Colors.black87,
              onTap: () {},
            ),
            QuickAccessButton(
              svg: Assets.imagesEmergency,
              label: 'Emergency',
              color: Colors.red,
              onTap: () {},
            ),
            QuickAccessButton(
              svg: Assets.imagesHelp,
              label: 'Help',
              color: Colors.blue,
              onTap: () {},
            ),
            QuickAccessButton(
              icon: Icons.call,
              label: 'Support',
              color: Colors.green,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}
