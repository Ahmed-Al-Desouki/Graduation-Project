// import 'package:flutter/material.dart';
// import 'package:graduation_project/core/utils/app_images.dart';
// import 'package:graduation_project/core/utils/app_styles.dart';
// import 'package:graduation_project/features/auth/presentation/views/widgets/custom_form_text_field.dart';
// import 'package:graduation_project/features/auth/presentation/views/widgets/headers_field_in_registration.dart';
// import 'package:graduation_project/features/auth/presentation/views/widgets/trash/custom_list_tile_widget.dart';
// import 'package:graduation_project/features/auth/presentation/views/widgets/trash/custom_notification.dart';

// class PatientMedicalInfoStep extends StatefulWidget {
//   final VoidCallback onRegister;

//   const PatientMedicalInfoStep({super.key, required this.onRegister});

//   @override
//   State<PatientMedicalInfoStep> createState() => _PatientMedicalInfoStepState();
// }

// class _PatientMedicalInfoStepState extends State<PatientMedicalInfoStep> {
//   final TextEditingController weightController = TextEditingController();
//   final TextEditingController heightController = TextEditingController();
//   final TextEditingController chronicController = TextEditingController();

//   bool agreeTerms = false;
//   String? bloodType;
//   bool get _isFormValid =>
//       weightController.text.isNotEmpty &&
//       bloodType != null &&
//       agreeTerms &&
//       heightController.text.isNotEmpty &&
//       chronicController.text.isNotEmpty;
//   bool reminders = true;
//   bool tips = true;
//   bool analytics = false;
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           HeadersFieldInRegistration(
//             imagePath: Assets.imagesStethoscope,
//             title: "Medical Information",
//           ),
//           const SizedBox(height: 12),
//           DropdownButtonFormField<String>(
//             decoration: InputDecoration(
//               labelText: "Selected Blood Type",
//               labelStyle: AppStyles.styleRegular16Gray,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             items: const [
//               DropdownMenuItem(value: "A+", child: Text("A+")),
//               DropdownMenuItem(value: "A-", child: Text("A-")),
//               DropdownMenuItem(value: "B+", child: Text("B+")),
//               DropdownMenuItem(value: "B-", child: Text("B-")),
//               DropdownMenuItem(value: "AB+", child: Text("AB+")),
//               DropdownMenuItem(value: "AB-", child: Text("AB-")),
//               DropdownMenuItem(value: "O+", child: Text("O+")),
//               DropdownMenuItem(value: "O-", child: Text("O-")),
//             ],
//             onChanged: (value) {
//               setState(() {
//                 bloodType = value;
//               });
//             },
//           ),

//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: CustomFormTextField(
//                   controller: weightController,
//                   hintText: "Weight (kg)",
//                   fieldType: FieldType.age,
//                   imagePath: Assets.imagesWeight,
//                   onChanged: (_) => setState(() {}),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: CustomFormTextField(
//                   controller: heightController,
//                   hintText: "Height (cm)",
//                   fieldType: FieldType.age,
//                   imagePath: Assets.imagesHeight,
//                   onChanged: (_) => setState(() {}),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           CustomFormTextField(
//             controller: chronicController,
//             hintText:
//                 "List any chronic condations (diabetes, hypertension, etc.) or tybe 'none'",
//             fieldType: FieldType.name,
//             imagePath: Assets.imagesChronicDiseases,
//             minLines: 3,
//             maxLines: 5,
//           ),
//           const SizedBox(height: 30),
//           HeadersFieldInRegistration(
//             angle: -4.7,
//             imagePath: Assets.imagesPreferences,
//             title: "Preferences",
//           ),
//           CustomNotificationTile(
//             icon: Icons.notifications_active_outlined,
//             color: const Color(0xFF3A85EE),
//             title: "Email Notifications",
//             subtitle: "Receive updates via email",
//             value: reminders,
//             onChanged: (v) => setState(() => reminders = v),
//           ),
//           CustomNotificationTile(
//             icon: Icons.email_outlined,
//             color: Colors.green,
//             title: "Health Tips",
//             subtitle: "Receive weekly health insights",
//             value: tips,
//             onChanged: (v) => setState(() => tips = v),
//           ),
//           CustomNotificationTile(
//             icon: Icons.shield_outlined,
//             color: Colors.orange,
//             title: "Data Analytics",
//             subtitle: "Help improve our services",
//             value: analytics,
//             onChanged: (v) => setState(() => analytics = v),
//           ),
//           const SizedBox(height: 20),
//           CheckboxListTile(
//             value: agreeTerms,
//             onChanged: (val) => setState(() => agreeTerms = val!),
//             title: const Text(
//               "I agree to the Terms of Service and Privacy Policy. I understand that my medical information will be securely stored and only shared with authorized healthcare providers.",
//             ),
//             controlAffinity: ListTileControlAffinity.leading,
//           ),
//           const SizedBox(height: 20),
//           CustomListTileWidget(
//             infocolor: const Color(0xff3b82f6),
//             icon: Icons.shield_sharp,
//             text:
//                 "We use bank-level encryption to protect your personal and medical information. Your privacy is our top priority.",
//           ),
//           const SizedBox(height: 28),
//           GestureDetector(
//             onTap: _isFormValid ? widget.onRegister : null,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               height: 50,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color:
//                     _isFormValid
//                         ? const Color(0xFF5da7e3)
//                         : Colors.grey.shade400,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               alignment: Alignment.center,
//               child: const Text(
//                 "Register as Patient",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 onPressed: () {},
//                 icon: const Icon(
//                   Icons.g_mobiledata,
//                   size: 32,
//                   color: Colors.red,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: const [
//               Text("Already have an account? "),
//               Text(
//                 "Sign In",
//                 style: TextStyle(
//                   color: Colors.blue,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
