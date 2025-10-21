import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_registration_appbar.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_registration_header.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/registration_form.dart';

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

  final _formKey = GlobalKey<FormState>();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? gender;

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      ShowSnackBar(context, 'Registration Successful!', Colors.green);
    }
  }

  void toggleStep() {
    setState(() {
      showMedicalInfoStep = !showMedicalInfoStep;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                    child: const CustomRegistrationHeader(
                      title: "Welcome to HealthCare+",
                      subtitle:
                          "Join thousands of patients managing their health better",
                      imagePath: Assets.imagesRegisterPatient,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.245),
              Column(
                children: [
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
                  RegistrationForm(
                    ageController: ageController,
                    birthDateController: birthDateController,
                    nameController: nameController,
                    emailController: emailController,
                    passwordController: passwordController,
                    gender: gender,
                    onGenderChanged: (val) => setState(() => gender = val),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomButton(
                      text: "Register",
                      onPressed: _submitRegistration,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
