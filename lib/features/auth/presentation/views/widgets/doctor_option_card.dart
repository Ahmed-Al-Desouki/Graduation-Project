import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class DoctorOptionCard extends StatefulWidget {
  const DoctorOptionCard({super.key});

  @override
  State<DoctorOptionCard> createState() => _DoctorOptionCardState();
}

class _DoctorOptionCardState extends State<DoctorOptionCard> {
  bool _isHovering = false;
  static const double _liftAmount = -5.0;
  static const Color _activeBorderColor = Colors.purpleAccent;
  @override
  Widget build(BuildContext context) {
    final double translateY = _isHovering ? _liftAmount : 0.0;
    final Color borderColor =
        _isHovering ? _activeBorderColor : Colors.transparent;
    final double shadowOpacity = _isHovering ? 0.25 : 0.1;
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovering = false;
        });
      },
      child: InkWell(
        onTap: () {
          AppRouter.router.go(AppRouter.kRegisterAsDoctor);
        },
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.translationValues(0.0, translateY, 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: borderColor, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, shadowOpacity),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    Assets.imagesDoctor,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  "I'm a Doctor",
                  style: AppStyles.styleSemiBold18Dark.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Manage patients,\nconsultations & practice',
                  textAlign: TextAlign.center,
                  style: AppStyles.styleRegular14Gray,
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Color(0xFFF3E8FF),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Column(
                //       children: [
                //         Container(
                //           padding: EdgeInsets.all(10.0),
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(10),
                //             color: Color(0xFFF3E8FF),
                //           ),
                //           child: SvgPicture.asset(
                //             Assets.imagesPatients,
                //             height: 20,
                //             width: 20,
                //             colorFilter: const ColorFilter.mode(
                //               Color(0xFF9333EA),
                //               BlendMode.srcIn,
                //             ),
                //           ),
                //         ),
                //         SizedBox(height: 10),
                //         Text('Patients', style: AppStyles.styleRegular14Gray),
                //       ],
                //     ),
                //     SizedBox(width: 80),
                //     Column(
                //       children: [
                //         Container(
                //           padding: EdgeInsets.all(10.0),
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(10),
                //             color: Color(0xFFFFEDD5),
                //           ),
                //           child: SvgPicture.asset(
                //             Assets.imagesCalendarDays,
                //             height: 20,
                //             width: 20,
                //             colorFilter: const ColorFilter.mode(
                //               Color(0xFFEE712E),
                //               BlendMode.srcIn,
                //             ),
                //           ),
                //         ),
                //         SizedBox(height: 10),
                //         Text('Schedule', style: AppStyles.styleRegular14Gray),
                //       ],
                //     ),
                //     SizedBox(width: 80),
                //     Column(
                //       children: [
                //         Container(
                //           padding: EdgeInsets.all(10.0),
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(10),
                //             color: Color(0xFFDCFCE7),
                //           ),
                //           child: SvgPicture.asset(
                //             Assets.imagesChartLine,
                //             height: 20,
                //             width: 20,
                //             colorFilter: const ColorFilter.mode(
                //               Color(0xFF16A34A),
                //               BlendMode.srcIn,
                //             ),
                //           ),
                //         ),
                //         SizedBox(height: 10),
                //         Text('Analytics', style: AppStyles.styleRegular14Gray),
                //       ],
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
