import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/auth/presentation/manger/auth_cubit/auth_cubit.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_registration_appbar.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_registration_header.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/registration_form.dart';
import 'package:image_picker/image_picker.dart';

class PatientRegistrationViewBody extends StatefulWidget {
  const PatientRegistrationViewBody({super.key});

  @override
  State<PatientRegistrationViewBody> createState() =>
      _PatientRegistrationViewBodyState();
}

class _PatientRegistrationViewBodyState
    extends State<PatientRegistrationViewBody> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  XFile? _selectedProfileImage;
  void _submitRegistration() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: "Patient",
        profileImage: _selectedProfileImage,
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
          ShowSnackBar(context, '✅ Registered Successfully!', Colors.green);
          AppRouter.router.go(AppRouter.kLogin);
        } else if (state is RegisterFailure) {
          Navigator.pop(context);
          ShowSnackBar(context, '❌ ${state.errMessage}', Colors.red);
        }
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
                        padding: EdgeInsets.only(left: 16.w, top: 15.h),
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
                        nameController: nameController,
                        emailController: emailController,
                        passwordController: passwordController,
                        onImagePicked: (file) {
                          if (file != null) {
                            setState(() {
                              _selectedProfileImage = XFile(file.path);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
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
