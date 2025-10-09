import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_form_text_field.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/headers_field_in_registration.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_list_tile_widget.dart';
import 'package:graduation_project/core/utils/app_images.dart';

class DoctorLicenseStep extends StatefulWidget {
  final VoidCallback onRegister;

  const DoctorLicenseStep({super.key, required this.onRegister});

  @override
  State<DoctorLicenseStep> createState() => _DoctorLicenseStepState();
}

class _DoctorLicenseStepState extends State<DoctorLicenseStep> {
  final TextEditingController licenseController = TextEditingController();
  String? specialization;

  bool agreeTerms = false;
  bool agreeMarketing = false;
  bool agreeProcessing = false;

  bool get _isFormValid =>
      licenseController.text.isNotEmpty &&
      specialization != null &&
      agreeTerms &&
      agreeProcessing;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeadersFieldInRegistration(
            imagePath: Assets.imagesStethoscope,
            title: "Medical Credentials",
          ),
          const SizedBox(height: 12),
          CustomFormTextField(
            controller: licenseController,
            hintText: "Medical License Number",
            imagePath: Assets.imagesCertificate,
            fieldType: FieldType.medicalLicense,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          CustomListTileWidget(
            infocolor: Color(0xff22C55E),
            icon: Icons.security,
            text:
                "All medical credentials will be verified by our team within 24-48 hours.",
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Specialization",
              labelStyle: AppStyles.styleRegular16Gray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(value: "Cardiology", child: Text("Cardiology")),
              DropdownMenuItem(
                value: "Dermatology",
                child: Text("Dermatology"),
              ),
              DropdownMenuItem(value: "Pediatrics", child: Text("Pediatrics")),
              DropdownMenuItem(value: "Neurology", child: Text("Neurology")),
              DropdownMenuItem(value: "Dentistry", child: Text("Dentistry")),
            ],
            onChanged: (value) {
              setState(() {
                specialization = value;
              });
            },
          ),
          const SizedBox(height: 28),
          HeadersFieldInRegistration(
            imagePath: Assets.imagesPrivcy,
            title: "Terms & Privacy",
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: agreeTerms,
            onChanged: (val) => setState(() => agreeTerms = val!),
            title: const Text(
              "I agree to the Terms of Service and Privacy Policy",
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            value: agreeMarketing,
            onChanged: (val) => setState(() => agreeMarketing = val!),
            title: const Text(
              "I consent to receive marketing communications and updates about new features",
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            value: agreeProcessing,
            onChanged: (val) => setState(() => agreeProcessing = val!),
            title: const Text(
              "I consent to the processing of my personal data for verification purposes",
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 20),
          HeadersFieldInRegistration(
            imagePath: Assets.imagesSecure,
            title: "Security Features",
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              CustomListTile2Widget(
                infocolor: Colors.green,
                image: Assets.imagesLock,
                text: "256-bit Encryption",
              ),
              CustomListTile2Widget(
                infocolor: Colors.blue,
                image: Assets.imagesHIPAACompliant,
                text: "HIPAA Compliant",
              ),
              CustomListTile2Widget(
                infocolor: Colors.purple,
                image: Assets.imagesMobile,
                text: "2FA Available",
              ),
              CustomListTile2Widget(
                infocolor: Colors.orange,
                image: Assets.imagesStorage,
                text: "Secure Storage",
              ),
            ],
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: _isFormValid ? widget.onRegister : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color:
                    _isFormValid
                        ? const Color(0xFF6A72DA)
                        : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Register as Doctor",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.g_mobiledata,
                  size: 32,
                  color: Colors.red,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.apple, size: 28, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Already have an account? "),
              Text(
                "Sign In",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
