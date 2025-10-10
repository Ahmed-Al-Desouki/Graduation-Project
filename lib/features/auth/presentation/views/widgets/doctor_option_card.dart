import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class DoctorOptionCard extends StatelessWidget {
  const DoctorOptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "I'm a Doctor",
                          style: AppStyles.styleSemiBold18Dark.copyWith(
                            fontSize: 25,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Manage patients,\nconsultations & practice',
                          style: AppStyles.styleRegular14Gray,
                        ),
                      ],
                    ),
                    SizedBox(width: 145),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        Assets.imagesDoctor,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Color(0xFFF3E8FF),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            Assets.imagesStethoscope,
                            height: 20,
                            width: 20,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF9333EA),
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Practice Management',
                            style: AppStyles.styleMedium12Purple.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 190),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.black45,
                    ),
                  ],
                ),
                SizedBox(height: 17),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFFF3E8FF),
                          ),
                          child: SvgPicture.asset(
                            Assets.imagesPatients,
                            height: 20,
                            width: 20,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF9333EA),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Patients', style: AppStyles.styleRegular14Gray),
                      ],
                    ),
                    SizedBox(width: 80),
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFFFFEDD5),
                          ),
                          child: SvgPicture.asset(
                            Assets.imagesCalendarDays,
                            height: 20,
                            width: 20,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFEE712E),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Schedule', style: AppStyles.styleRegular14Gray),
                      ],
                    ),
                    SizedBox(width: 80),
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFFDCFCE7),
                          ),
                          child: SvgPicture.asset(
                            Assets.imagesChartLine,
                            height: 20,
                            width: 20,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF16A34A),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Analytics', style: AppStyles.styleRegular14Gray),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
