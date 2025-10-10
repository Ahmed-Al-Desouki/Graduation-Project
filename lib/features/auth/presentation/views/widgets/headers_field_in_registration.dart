import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class HeadersFieldInRegistration extends StatelessWidget {
  const HeadersFieldInRegistration({
    super.key,
    required this.imagePath,
    required this.title,
    this.angle = 0.0,
  });
  final String imagePath;
  final String title;
  final double? angle;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.rotate(
          angle: angle!,
          child: SvgPicture.asset(
            imagePath,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Color(0xff667EEA),
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppStyles.styleSemiBold18Dark),
      ],
    );
  }
}
