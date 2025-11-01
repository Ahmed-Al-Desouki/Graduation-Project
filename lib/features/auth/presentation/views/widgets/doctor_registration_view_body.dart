import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/auth/presentation/manger/auth_cubit/auth_cubit.dart';
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
  // final TextEditingController ageController = TextEditingController();
  // final TextEditingController birthDateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // final TextEditingController nationalIdController = TextEditingController();
  // String? gender;

  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: "Doctor",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is RegisterLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        } else if (state is RegisterSuccess) {
          Navigator.pop(context); // close loader
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('✅ Login successful!'),
          //     backgroundColor: Colors.green,
          //   ),
          // );
          ShowSnackBar(context, '✅ Login successful!', Colors.green);
          AppRouter.router.go(AppRouter.kLogin);
        } else if (state is RegisterFailure) {
          Navigator.pop(context); // close loader
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('❌ ${state.errMessage}'),
          //     backgroundColor: Colors.red,
          //   ),
          // );
          ShowSnackBar(context, '❌ ${state.errMessage}', Colors.red);
        }
        // TODO: implement listener
      },
      builder: (context, state) {
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
                        // ageController: ageController,
                        // birthDateController: birthDateController,
                        nameController: nameController,
                        emailController: emailController,
                        passwordController: passwordController,
                        isDoctor: true,
                        // gender: gender,
                        // onGenderChanged: (val) => setState(() => gender = val),
                      ),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CustomButton(
                          text: "Register",
                          onPressed:
                              state is RegisterLoading
                                  ? null
                                  : _submitRegistration,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
