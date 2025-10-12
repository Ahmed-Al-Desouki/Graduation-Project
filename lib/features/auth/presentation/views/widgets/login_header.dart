import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class LoginHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconPath;
  final String imagePath;
  const LoginHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: SvgPicture.asset(
            iconPath,
            height: 50,
            width: 50,
            colorFilter: const ColorFilter.mode(
              Color(0xff26A69A),
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(title, style: AppStyles.styleBold30.copyWith(fontSize: 40)),
        SizedBox(height: 8),
        Text(
          subtitle,
          style: AppStyles.styleRegular16GrayDark.copyWith(fontSize: 18),
        ),
        SizedBox(height: 30),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            imagePath,
            height: 200,
            width: 200,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
