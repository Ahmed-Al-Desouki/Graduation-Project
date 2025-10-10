import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class PatientOptionCard extends StatelessWidget {
  const PatientOptionCard({super.key});

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
                          "I'm a Patient",
                          style: AppStyles.styleSemiBold18Dark.copyWith(
                            fontSize: 25,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Book appointments, manage\nhealth records',
                          style: AppStyles.styleRegular14Gray,
                        ),
                      ],
                    ),
                    SizedBox(width: 120),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        Assets.imagesPatient,
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
                        color: Color(0xFFDBEAFE),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Color(0xFF2563EB),
                            size: 15,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Health Management',
                            style: AppStyles.styleMedium12Blue.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 210),
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
                            color: Color(0xFFDBEAFE),
                          ),
                          child: SvgPicture.asset(
                            Assets.imagesSchduleBooking,
                            height: 20,
                            width: 20,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF2563EB),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Book', style: AppStyles.styleRegular14Gray),
                      ],
                    ),
                    SizedBox(width: 80),
                    Column(children: [
                        Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFFDCFCE7),
                          ),
                          child: SvgPicture.asset(
                            Assets.imagesFilePlusFillSvgrepoCom,
                            height: 20,
                            width: 20,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF16A34A),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Records', style: AppStyles.styleRegular14Gray),
                      ],
                    ),
                    SizedBox(width: 80),
                    Column(children: [
                        Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFFF3E8FF),
                          ),
                          child: SvgPicture.asset(
                            Assets.imagesMeds,
                            height: 20,
                            width: 20,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF9333EA),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Meds', style: AppStyles.styleRegular14Gray),
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
