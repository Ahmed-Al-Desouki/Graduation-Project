import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/auth/presentation/manger/auth_cubit/auth_cubit.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/input_field.dart';

class LoginFormContainer extends StatefulWidget {
  final List<Color> gradientColors;
  const LoginFormContainer({super.key, required this.gradientColors});

  @override
  State<LoginFormContainer> createState() => _LoginFormContainerState();
}

class _LoginFormContainerState extends State<LoginFormContainer> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // if (state is LoginLoading) {
        //   showDialog(
        //     context: context,
        //     barrierDismissible: false,
        //     builder: (_) => const Center(child: CircularProgressIndicator()),
        //   );
        // }
        if (state is LoginOtpRequired) {
          // ممكن نعرض رسالة الـ Cubit
          ShowSnackBar(context, '✅ ${state.message}', Colors.green);
          print("mfaToken in listener: ${state.mfaToken}");

          // 2. روح شاشة الـ OTP ومعاك الداتا اللي محتاجها
          AppRouter.router.push(
            AppRouter.kOtpScreen, // اتأكد إن ده اسم الراوت الصحيح
            extra: {
              'email': _emailController.text.trim(),
              'password': _passwordController.text.trim(),
              'mfaToken': state.mfaToken,
            },
          );
        } else if (state is LoginSuccess) {
          // Navigator.pop(context);
          ShowSnackBar(context, '✅ Login successful!', Colors.green);
          // <<<<<<< HEAD
          //           AppRouter.router.go(AppRouter.kSettings);
          // =======
          final role = state.role;
          if (role == 'doctor') {
            AppRouter.router.go(AppRouter.kHomeDoctor);
          } else {
            AppRouter.router.go(AppRouter.kHomePatient);
          }
          // >>>>>>> origin/login-register
        } else if (state is LoginFailure) {
          // Navigator.pop(context);
          ShowSnackBar(context, '❌ ${state.errMessage}', Colors.red);
        }
      },
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                InputField(
                  label: 'Email Address',
                  hint: 'Enter your email',
                  hintSize: 16,
                  icon: Icons.email,
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required!';
                    }
                    if (!_isValidEmail(value)) {
                      return 'Enter a valid email (e.g. example@gmail.com)';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                InputField(
                  label: 'Password',
                  hint: 'Enter your password',
                  hintSize: 16,
                  icon: Icons.lock,
                  isPassword: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required!';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15.h),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      AppRouter.router.go(AppRouter.kForgotPassword);
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppStyles.styleRegular16Teal.copyWith(
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25.h),
                SizedBox(
                  width: double.infinity,
                  height: 70.h,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.gradientColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: ElevatedButton(
                      onPressed: state is LoginLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                      ),
                      child:
                          state is LoginLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
