import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_registration_appbar.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_registration_header.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/personal_information_section.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/registration_progress.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/doctor_license_step.dart';

class DoctorRegistrationViewBody extends StatefulWidget {
  const DoctorRegistrationViewBody({super.key});

  @override
  State<DoctorRegistrationViewBody> createState() =>
      _DoctorRegistrationViewBodyState();
}

class _DoctorRegistrationViewBodyState
    extends State<DoctorRegistrationViewBody> {
  bool showLicenseStep = false;
  bool isFormValid = false;

  final TextEditingController ageController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  String? gender;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const CustomAppBarRegistration(
                title: 'Doctor Registration',
                subtitle: "Join our medical community",
                gradientColors: [Color(0xFF6A72DA), Color(0xFF754EA6)],
                imagePath: Assets.imagesUserDoctor,
              ),
              Positioned(
                top: height * 0.245,
                left: 16,
                right: 16,
                child: const RegistrationHeader(
                  title: "Welcome, Doctor!",
                  subtitle:
                      "Create your professional medical profile to connect with patients and colleagues.",
                  imagePath: Assets.imagesRegisterDoctor,
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.245),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: RegistrationProgress(
              step: showLicenseStep ? 2 : 1,
              totalSteps: 3,
              gradientColors: const [Color(0xFF6A72DA), Color(0xFF754EA6)],
            ),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child:
                showLicenseStep
                    ? Column(
                      key: const ValueKey('license'),
                      children: [
                        DoctorLicenseStep(onRegister: () {}),
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: () {
                              setState(() {
                                showLicenseStep = false;
                              });
                            },
                            child: const Text(
                              "Back",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : Column(
                      key: const ValueKey('personal'),
                      children: [
                        PersonalInformationSection(
                          ageController: ageController,
                          birthDateController: birthDateController,
                          nameController: nameController,
                          emailController: emailController,
                          passwordController: passwordController,
                          nationalIdController: nationalIdController,
                          gender: gender,
                          onGenderChanged:
                              (val) => setState(() => gender = val),
                          onFormValidChanged: (isValid) {
                            setState(() {
                              isFormValid = isValid;
                            });
                          },
                        ),
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color:
                                  isFormValid
                                      ? const Color(0xFF6A72DA)
                                      : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextButton(
                              onPressed:
                                  isFormValid
                                      ? () {
                                        setState(() {
                                          showLicenseStep = true;
                                        });
                                      }
                                      : null,
                              child: const Text(
                                "Next Step",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
