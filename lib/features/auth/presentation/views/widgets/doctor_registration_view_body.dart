import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_registration_appbar.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_registration_header.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/registration_form.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_button.dart';

class DoctorRegistrationViewBody extends StatefulWidget {
  const DoctorRegistrationViewBody({super.key});

  @override
  State<DoctorRegistrationViewBody> createState() =>
      _DoctorRegistrationViewBodyState();
}

class _DoctorRegistrationViewBodyState
    extends State<DoctorRegistrationViewBody> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  String? gender;

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      ShowSnackBar(context, 'Registration Successful!', Colors.green);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
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
                  child: const CustomRegistrationHeader(
                    title: "Welcome, Doctor!",
                    subtitle:
                        "Create your professional medical profile to connect with patients and colleagues.",
                    imagePath: Assets.imagesRegisterDoctor,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.245),
            Column(
              children: [
                RegistrationForm(
                  ageController: ageController,
                  birthDateController: birthDateController,
                  nameController: nameController,
                  emailController: emailController,
                  passwordController: passwordController,
                  isDoctor: true,
                  gender: gender,
                  onGenderChanged: (val) => setState(() => gender = val),
                ),
                const SizedBox(height: 25),
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
    );
  }
}
