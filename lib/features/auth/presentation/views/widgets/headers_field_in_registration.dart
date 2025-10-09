import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class HeadersFieldInRegistration extends StatelessWidget {
  const HeadersFieldInRegistration({
    super.key,
    required this.imagePath,
    required this.title,
  });
  final String imagePath;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          imagePath,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            Color(0xff667EEA),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppStyles.styleSemiBold18Dark),
      ],
    );
  }
}
