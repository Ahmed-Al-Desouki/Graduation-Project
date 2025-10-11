import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class FeaturesContainer extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color backgroundColor;
  const FeaturesContainer({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: backgroundColor,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: SvgPicture.asset(
                  icon,
                  height: 25,
                  width: 25,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(height: 7),
              Text(title, style: AppStyles.styleSemiBold18Dark),
              SizedBox(height: 4),
              Text(subtitle, style: AppStyles.styleRegular14Gray),
              SizedBox(height: 7),
            ],
          ),
        ),
      ),
    );
  }
}
