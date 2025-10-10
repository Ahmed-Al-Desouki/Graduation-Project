import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_list_tile_widget.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_registration_appbar.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_registration_header.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/patient_medical_info_step.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/personal_information_section_for_patient.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/registration_progress.dart';

class PatientRegistrationViewBody extends StatefulWidget {
  const PatientRegistrationViewBody({super.key});

  @override
  State<PatientRegistrationViewBody> createState() =>
      _PatientRegistrationViewBodyState();
}

class _PatientRegistrationViewBodyState
    extends State<PatientRegistrationViewBody> {
  bool showMedicalInfoStep = false;
  bool isFormValid = false;

  final TextEditingController ageController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? gender;

  void toggleStep() {
    setState(() {
      showMedicalInfoStep = !showMedicalInfoStep;
    });
  }

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
                title: 'Patient Registration',
                subtitle: "Join our Safety community",
                gradientColors: [Color(0xFF3A85EE), Color(0xFF22C362)],
                imagePath: Assets.imagesUserRegular,
              ),
              Positioned(
                top: height * 0.245,
                left: 16,
                right: 16,
                child: const RegistrationHeader(
                  title: "Welcome to HealthCare+",
                  subtitle:
                      "Join thousands of patients managing their health better",
                  imagePath: Assets.imagesRegisterPatient,
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.245),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: RegistrationProgress(
              step: showMedicalInfoStep ? 2 : 1,
              totalSteps: 2,
              gradientColors: const [Color(0xFF3A85EE), Color(0xFF22C362)],
            ),
          ),
          const SizedBox(height: 20),
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
                showMedicalInfoStep
                    ? Column(
                      key: const ValueKey('MedicalInfo'),
                      children: [
                        PatientMedicalInfoStep(
                          onRegister: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Patient Registered Successfully!',
                                ),
                              ),
                            );
                          },
                        ),
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
                                showMedicalInfoStep = false;
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
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Why Register?",
                              style: AppStyles.styleSemiBold14Dark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: const [
                            CustomListTile3Widget(
                              infocolor: Color(0xff3B82F6),
                              image: Assets.imagesCalendarDays,
                              text: "Easy Booking",
                              subText: "Schedule appointments instantly",
                            ),
                            CustomListTile3Widget(
                              infocolor: Color(0xff22c55e),
                              image: Assets.imagesProfilePlus,
                              text: "Health Records",
                              subText: "Access your medical history",
                            ),
                            CustomListTile3Widget(
                              infocolor: Color(0xffA855F7),
                              image: Assets.imagesMeds,
                              text: "Prescriptions",
                              subText: "Digital prescription management",
                            ),
                            CustomListTile3Widget(
                              infocolor: Color(0xffF97316),
                              image: Assets.imagesBell,
                              text: "Reminders",
                              subText: "Never miss appointments",
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Create Your Account',
                              style: AppStyles.styleBold20Dark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Fill in your details to get started",
                              style: AppStyles.styleRegular14Gray,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        PersonalInformationSectionForPatient(
                          ageController: ageController,
                          birthDateController: birthDateController,
                          emailController: emailController,
                          nameController: nameController,
                          passwordController: passwordController,
                          gender: gender,
                          onGenderChanged:
                              (val) => setState(() => gender = val),
                          onFormValidChanged: (isValid) {
                            setState(() {
                              isFormValid = isValid;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
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
                                          showMedicalInfoStep = true;
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
