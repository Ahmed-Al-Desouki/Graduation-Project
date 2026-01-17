import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class SecurityItem extends StatelessWidget {
  final String text;
  final String icon;
  final Color iconColor;
  const SecurityItem({
    super.key,
    required this.text,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          height: 20.h,
          width: 20.w,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
        SizedBox(width: 6.w),
        Text(text, style: TextStyle(color: Colors.black54, fontSize: 13)),
      ],
    );
  }
}
