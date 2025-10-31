import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/features/auth/presentation/manger/auth_cubit/auth_cubit.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/custom_form_text_field.dart';

class ResetPasswordView extends StatefulWidget {
  final String email;
  final String token;

  const ResetPasswordView({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text.trim() !=
          _confirmPasswordController.text.trim()) {
        ShowSnackBar(context, "Passwords don't match", Colors.red);
        return;
      }

      context.read<AuthCubit>().resetPassword(
        email: widget.email,
        token: widget.token,
        newPassword: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is ResetPasswordLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        } else if (state is ResetPasswordSuccess) {
          Navigator.pop(context);
          AppRouter.router.go(AppRouter.kResetSuccess);
        } else if (state is ResetPasswordFailure) {
          Navigator.pop(context);
          ShowSnackBar(context, "❌ ${state.errMessage}", Colors.red);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xffE8F7F2),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    Text(
                      'Reset Password',
                      style: AppStyles.styleSemiBold18Dark.copyWith(
                        fontSize: 28,
                        color: const Color(0xFF764BA2),
                      ),
                    ),
                    // 123456789aAc
                    const SizedBox(height: 20),
                    CustomFormTextField(
                      hintText: "New Password",
                      fieldType: FieldType.password,
                      obscureText: true,
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 20),
                    CustomFormTextField(
                      hintText: "Confirm Password",
                      fieldType: FieldType.password,
                      obscureText: true,
                      controller: _confirmPasswordController,
                      prefixIcon: Icons.lock,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomButton(
                        text: "Confirm Reset",
                        onPressed:
                            state is ResetPasswordLoading ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
