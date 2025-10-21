import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class CustomAppBarRegistration extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final String imagePath;
  const CustomAppBarRegistration({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(title, style: AppStyles.styleSemiBold18White),
            leading: Padding(
              padding: const EdgeInsets.only(left: 17.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(47, 255, 255, 255),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    AppRouter.router.go(AppRouter.kCreatAcount);
                  },
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(47, 255, 255, 255),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SvgPicture.asset(
                imagePath,
                height: 60,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: AppStyles.styleRegular14White),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
