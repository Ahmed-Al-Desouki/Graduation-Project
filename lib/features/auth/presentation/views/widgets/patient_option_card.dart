import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';

class PatientOptionCard extends StatefulWidget {
  const PatientOptionCard({super.key});

  @override
  State<PatientOptionCard> createState() => _PatientOptionCardState();
}

class _PatientOptionCardState extends State<PatientOptionCard> {
  bool _isHovering = false;
  static const double _liftAmount = -5.0;
  static const Color _activeBorderColor = Colors.blueAccent;
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
        onTap: () {},
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
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    Assets.imagesPatient1,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  "I'm a Patient",
                  style: AppStyles.styleSemiBold18Dark.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Book appointments,\nmanagehealth records',
                  textAlign: TextAlign.center,
                  style: AppStyles.styleRegular14Gray,
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Color(0xFFDBEAFE),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, color: Color(0xFF2563EB), size: 15),
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
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Column(
                //       children: [
                //         Container(
                //           padding: EdgeInsets.all(10.0),
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(10),
                //             color: Color(0xFFDBEAFE),
                //           ),
                //           child: SvgPicture.asset(
                //             Assets.imagesSchduleBooking,
                //             height: 20,
                //             width: 20,
                //             colorFilter: const ColorFilter.mode(
                //               Color(0xFF2563EB),
                //               BlendMode.srcIn,
                //             ),
                //           ),
                //         ),
                //         SizedBox(height: 10),
                //         Text('Book', style: AppStyles.styleRegular14Gray),
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
                //             Assets.imagesFilePlusFillSvgrepoCom,
                //             height: 20,
                //             width: 20,
                //             colorFilter: const ColorFilter.mode(
                //               Color(0xFF16A34A),
                //               BlendMode.srcIn,
                //             ),
                //           ),
                //         ),
                //         SizedBox(height: 10),
                //         Text('Records', style: AppStyles.styleRegular14Gray),
                //       ],
                //     ),
                //     SizedBox(width: 80),
                //     Column(
                //       children: [
                //         Container(
                //           padding: EdgeInsets.all(10.0),
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(10),
                //             color: Color(0xFFF3E8FF),
                //           ),
                //           child: SvgPicture.asset(
                //             Assets.imagesMeds,
                //             height: 20,
                //             width: 20,
                //             colorFilter: const ColorFilter.mode(
                //               Color(0xFF9333EA),
                //               BlendMode.srcIn,
                //             ),
                //           ),
                //         ),
                //         SizedBox(height: 10),
                //         Text('Meds', style: AppStyles.styleRegular14Gray),
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
