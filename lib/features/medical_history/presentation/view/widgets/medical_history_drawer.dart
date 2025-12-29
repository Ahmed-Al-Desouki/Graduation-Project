// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:graduation_project/core/utils/app_images.dart';

// class MedicalHistoryDrawer extends StatelessWidget {
//   final Function(GlobalKey) onScrollToSection;
//   // نستقبل المفاتيح عشان نعرف نروح فين
//   final GlobalKey profileKey;
//   final GlobalKey familyKey;
//   final GlobalKey socialKey;
//   final GlobalKey conditionsKey;
//   final GlobalKey appointmentsKey;
//   final GlobalKey surgeriesKey;
//   final GlobalKey medicationsKey;
//   final GlobalKey labsKey;

//   const MedicalHistoryDrawer({
//     super.key,
//     required this.onScrollToSection,
//     required this.profileKey,
//     required this.familyKey,
//     required this.socialKey,
//     required this.conditionsKey,
//     required this.appointmentsKey,
//     required this.surgeriesKey,
//     required this.medicationsKey,
//     required this.labsKey,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Colors.white,
//       child: Column(
//         children: [
//           _buildDrawerHeader(),
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               children: [
//                 _buildDrawerItem("Health Profile", Icons.person, profileKey),
//                 _buildDrawerItem(
//                   "Family History",
//                   Icons.family_restroom,
//                   familyKey,
//                 ),
//                 _buildDrawerItem("Social History", Icons.people_alt, socialKey),
//                 _buildDrawerItem(
//                   "Conditions & Allergies",
//                   Icons.warning_amber,
//                   conditionsKey,
//                 ),
//                 _buildDrawerItem(
//                   "Past Appointments",
//                   Icons.calendar_month,
//                   appointmentsKey,
//                 ),
//                 _buildDrawerItem(
//                   "Surgeries",
//                   Icons.local_hospital,
//                   surgeriesKey,
//                 ),
//                 _buildDrawerItem(
//                   "Medications",
//                   Icons.medication,
//                   medicationsKey,
//                 ),
//                 _buildDrawerItem(
//                   "Lab Results & Radiology",
//                   Icons.biotech,
//                   labsKey,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDrawerHeader() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
//       color: const Color(0xFFE3F2FD),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.white,
//             child: SvgPicture.asset(
//               Assets.imagesMedicalRecordsSvgrepoCom,
//               width: 24,
//             ),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             "Quick Navigation",
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF111827),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDrawerItem(String title, IconData icon, GlobalKey key) {
//     return ListTile(
//       leading: Icon(icon, color: const Color(0xFF4A90E2)),
//       title: Text(
//         title,
//         style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
//       ),
//       onTap: () => onScrollToSection(key),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:graduation_project/core/utils/app_images.dart';

class MedicalHistoryDrawer extends StatelessWidget {
  // Callback function عشان لما ندوس نبلغ الصفحة الرئيسية تعمل سكرول
  final Function(GlobalKey) onScrollToSection;

  final GlobalKey profileKey;
  final GlobalKey familyKey;
  final GlobalKey socialKey;
  final GlobalKey conditionsKey;
  final GlobalKey appointmentsKey;
  final GlobalKey surgeriesKey;
  final GlobalKey medicationsKey;
  final GlobalKey labsKey;

  const MedicalHistoryDrawer({
    super.key,
    required this.onScrollToSection,
    required this.profileKey,
    required this.familyKey,
    required this.socialKey,
    required this.conditionsKey,
    required this.appointmentsKey,
    required this.surgeriesKey,
    required this.medicationsKey,
    required this.labsKey,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            color: const Color(0xFFE3F2FD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: SvgPicture.asset(
                    Assets.imagesMedicalRecordsSvgrepoCom,
                    width: 24,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Quick Navigation",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),

          // List Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem("Health Profile", Icons.person, profileKey),
                _buildDrawerItem(
                  "Family History",
                  Icons.family_restroom,
                  familyKey,
                ),
                _buildDrawerItem("Social History", Icons.people_alt, socialKey),
                _buildDrawerItem(
                  "Conditions & Allergies",
                  Icons.warning_amber,
                  conditionsKey,
                ),
                _buildDrawerItem(
                  "Past Appointments",
                  Icons.calendar_month,
                  appointmentsKey,
                ),
                _buildDrawerItem(
                  "Surgeries",
                  Icons.local_hospital,
                  surgeriesKey,
                ),
                _buildDrawerItem(
                  "Medications",
                  Icons.medication,
                  medicationsKey,
                ),
                _buildDrawerItem(
                  "Lab Results & Radiology",
                  Icons.biotech,
                  labsKey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, GlobalKey key) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4A90E2)),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      onTap: () => onScrollToSection(key),
    );
  }
}
