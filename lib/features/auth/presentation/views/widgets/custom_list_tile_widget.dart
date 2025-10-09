import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class CustomListTileWidget extends StatelessWidget {
  const CustomListTileWidget({
    super.key,
    required this.infocolor,
    required this.icon,
    required this.text,
  });
  final Color infocolor;
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: infocolor),
      title: Text(
        text,
        style: AppStyles.styleRegular14Gray.copyWith(color: infocolor),
      ),
    );
  }
}

class CustomListTile2Widget extends StatelessWidget {
  const CustomListTile2Widget({
    super.key,
    required this.infocolor,
    required this.image,
    required this.text,
  });
  final Color infocolor;
  final String image;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      decoration: BoxDecoration(
        color: infocolor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: SvgPicture.asset(
          width: 24,
          height: 24,
          image,
          colorFilter: ColorFilter.mode(infocolor, BlendMode.srcIn),
        ),
        subtitle: Text(
          text,
          style: AppStyles.styleRegular14Gray.copyWith(color: infocolor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
