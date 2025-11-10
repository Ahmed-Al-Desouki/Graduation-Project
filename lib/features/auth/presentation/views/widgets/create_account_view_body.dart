import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/create_account_header.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/doctor_option_card.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/patient_option_card.dart';

class CreateAccountViewBody extends StatelessWidget {
  const CreateAccountViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CreateAccountHeader(
                  title: 'MedConnect',
                  subtitle: 'Your Healthcare Companion',
                  gradientColors: [Color(0xFF6A80DA), Color(0xFF754EA6)],
                  imagePath: Assets.imagesUserDoctor,
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    Assets.imagesPatient,
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  children: [
                    Text(
                      'Create your account',
                      style: AppStyles.styleSemiBold18Dark.copyWith(
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        text: 'Join thousands of users who trust\n',
                        style: AppStyles.styleRegular14Gray,
                        children: [
                          TextSpan(
                            text: 'MedConnect',
                            style: AppStyles.styleRegular14Gray,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Choose your account type to get started',
                      style: AppStyles.styleRegular14Gray,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [PatientOptionCard(), DoctorOptionCard()],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
                  style: AppStyles.styleRegular12Gray,
                ),
                TextButton(
                  onPressed: () {
                    final router = GoRouter.of(context);
                    if (router.canPop()) {
                      router.pop();
                    } else {
                      router.go(AppRouter.kLogin);
                    }
                  },
                  child: Text('Sign in', style: AppStyles.styleMedium12Blue),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '© 2024 MediConnect. All rights reserved.',
              style: AppStyles.styleRegular12Gray,
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
