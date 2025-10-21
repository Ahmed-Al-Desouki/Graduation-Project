import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class RegistrationProgress extends StatelessWidget {
  final int step;
  final int totalSteps;
  final List<Color> gradientColors;

  const RegistrationProgress({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final progress = step / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Registration Progress",
              style: AppStyles.styleSemiBold14Dark,
            ),
            const Spacer(),
            Text(
              "Step $step of $totalSteps",
              style: AppStyles.styleSemiBold14Dark.copyWith(
                color: Color(0xFF667EEA),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              height: 6,
              width: MediaQuery.of(context).size.width * progress,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
