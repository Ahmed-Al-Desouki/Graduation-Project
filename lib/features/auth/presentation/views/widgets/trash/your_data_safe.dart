import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class YourDataSafe extends StatelessWidget {
  final String text;
  final String icon;
  final Color iconColor;
  final Color containerColor;
  const YourDataSafe({super.key, required this.text, required this.iconColor, required this.containerColor, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SvgPicture.asset(
            icon,
            height: 20,
            width: 20,
            colorFilter: ColorFilter.mode(
              iconColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(text, style: AppStyles.styleRegular14Gray),
      ],
    );
  }
}
