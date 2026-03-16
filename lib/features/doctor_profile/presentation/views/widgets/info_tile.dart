import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class InfoTile extends StatelessWidget {
  final IconData? icon;
  final Color iconColor;
  final String? imageAsset;
  final String title;
  final String subtitle;
  const InfoTile({
    super.key,
    this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child:
              imageAsset != null
                  ? SvgPicture.asset(
                    imageAsset!,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  )
                  : Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}
