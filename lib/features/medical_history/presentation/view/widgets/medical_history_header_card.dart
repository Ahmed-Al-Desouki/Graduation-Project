import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class MedicalHistoryHeaderCard extends StatelessWidget {
  const MedicalHistoryHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            Assets.imagesMedicalRecordsSvgrepoCom,
            height: 40,
            width: 40,
          ),
          const SizedBox(height: 16),
          Text('Health Profile', style: AppStyles.styleBold24Dark),
          const SizedBox(height: 6),
          Text(
            'Keep your medical records up to date.',
            style: AppStyles.styleRegular16GrayDark.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
