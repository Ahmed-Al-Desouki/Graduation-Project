import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class PatientHomeHeader extends StatelessWidget {
  const PatientHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00BCD4), Color(0xff66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 50),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: SvgPicture.asset(
                  Assets.imagesHeartRate,
                  height: 30,
                  width: 30,
                  colorFilter: const ColorFilter.mode(
                    Color(0xff26A69A),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      'Welcome UserName',
                      style: AppStyles.styleSemiBold18Dark.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'How are you feeling today?',
                      textAlign: TextAlign.center,
                      style: AppStyles.styleRegular14Gray.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 120),
                child: IconButton(
                  icon: const Icon(Icons.notifications),
                  color: Colors.white,
                  iconSize: 28,
                  onPressed: () {
                    // Navigator.pushNamed(context, AppRouter.kNotifications);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
