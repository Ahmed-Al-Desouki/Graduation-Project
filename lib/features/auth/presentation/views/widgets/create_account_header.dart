import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class CreateAccountHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final String imagePath;
  const CreateAccountHeader({
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
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 17),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(47, 255, 255, 255),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    final router = GoRouter.of(context);
                    if (router.canPop()) {
                      router.pop();
                    } else {
                      router.go(AppRouter.kLogin);
                    }
                  },
                ),
              ),
            ),
          ),
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: SvgPicture.asset(
                  Assets.imagesUserDoctor,
                  height: 40,
                  width: 40,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF6A80DA),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppStyles.styleSemiBold18White.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: AppStyles.styleRegular14White),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
