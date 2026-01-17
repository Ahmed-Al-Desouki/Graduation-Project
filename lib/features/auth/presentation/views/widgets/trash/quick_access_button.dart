// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:graduation_project/core/utils/app_styles.dart';

// class QuickAccessButton extends StatefulWidget {
//   final IconData? icon;
//   final String? svg;
//   final String label;
//   final Color color;
//   final VoidCallback onTap;

//   const QuickAccessButton({
//     super.key,
//     this.svg,
//     this.icon,
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   State<QuickAccessButton> createState() => _QuickAccessButtonState();
// }

// class _QuickAccessButtonState extends State<QuickAccessButton> {
//   bool _isHovering = false;

//   @override
//   Widget build(BuildContext context) {
//     final double lift = _isHovering ? -6.0 : 0.0;
//     final double shadowStrength = _isHovering ? 0.3 : 0.15;

//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovering = true),
//       onExit: (_) => setState(() => _isHovering = false),
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 200),
//         transform: Matrix4.translationValues(0, lift, 0),
//         curve: Curves.easeOut,
//         child: InkWell(
//           onTap: widget.onTap,
//           hoverColor: Colors.transparent,
//           splashColor: Colors.transparent,
//           highlightColor: Colors.transparent,
//           child: Container(
//             width: 90,
//             height: 90,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Color.fromRGBO(0, 0, 0, shadowStrength),
//                   spreadRadius: 1,
//                   blurRadius: 6,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 widget.svg != null
//                     ? SvgPicture.asset(
//                       widget.svg!,
//                       height: 35,
//                       width: 35,
//                       colorFilter: ColorFilter.mode(
//                         widget.color,
//                         BlendMode.srcIn,
//                       ),
//                     )
//                     : Icon(widget.icon, color: widget.color, size: 35),
//                 const SizedBox(height: 6),
//                 Text(
//                   widget.label,
//                   textAlign: TextAlign.center,
//                   style: AppStyles.styleRegular14Gray,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
