import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class PatientQuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color gradientColor;
  final String imageAsset;
  final VoidCallback? onTap;

  const PatientQuickActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gradientColor,
    required this.imageAsset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientColor, Colors.white],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: gradientColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppStyles.styleSemiBold18Dark.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppStyles.styleRegular14White.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SvgPicture.asset(
                  imageAsset,
                  height: 60,
                  width: 60,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
