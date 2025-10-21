import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class CustomRegistrationHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;

  const CustomRegistrationHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Image.asset(imagePath, height: 100),
              const SizedBox(height: 10),
              Text(title, style: AppStyles.styleBold20Dark),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppStyles.styleRegular14Gray,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
