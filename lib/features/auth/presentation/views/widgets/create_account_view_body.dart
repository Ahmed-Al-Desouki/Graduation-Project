import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/available_features.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/create_account_header.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/doctor_option_card.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/login_view_body.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/patient_option_card.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/quick_access.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/trusted_by_thousands.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/ways_to_continue.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/your_data_safe.dart';

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
            Text(
              'Create your account',
              style: AppStyles.styleSemiBold18Dark.copyWith(fontSize: 25),
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
            SizedBox(height: 30),
            PatientOptionCard(),
            DoctorOptionCard(),
            SizedBox(height: 25),
            AvailableFeatures(),
            SizedBox(height: 30),
            TrustedByThousands(),
            SizedBox(height: 25),
            Text('Your data is safe', style: AppStyles.styleSemiBold18Dark),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                YourDataSafe(
                  text: 'HIPAA',
                  iconColor: Color(0xFF16A34A),
                  containerColor: Color(0xFFDCFCE7),
                  icon: Assets.imagesLock,
                ),
                SizedBox(width: 25),
                YourDataSafe(
                  text: 'SSL',
                  iconColor: Color(0xFF2563EB),
                  containerColor: Color(0xFFDBEAFE),
                  icon: Assets.imagesCertificate,
                ),
                SizedBox(width: 25),
                YourDataSafe(
                  text: 'Encrypted',
                  iconColor: Color(0xFF9333EA),
                  containerColor: Color(0xFFF3E8FF),
                  icon: Assets.imagesSecure,
                ),
              ],
            ),
            SizedBox(height: 30),
            QuickAccess(),
            SizedBox(height: 35),
            Text('Or continue with', style: AppStyles.styleRegular14Gray),
            SizedBox(height: 25),
            WaysToContinue(
              text: 'Continue with Google',
              icon: Assets.imagesGoogleColorSvgrepoCom,
              onTap: () {},
            ),
            SizedBox(height: 15),
            WaysToContinue(
              text: 'Continue with Apple',
              icon: Assets.imagesApple173SvgrepoCom,
              onTap: () {},
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text('Terms', style: AppStyles.styleRegular12Gray),
                ),
                SizedBox(width: 25),
                TextButton(
                  onPressed: () {},
                  child: Text('Privacy', style: AppStyles.styleRegular12Gray),
                ),
                SizedBox(width: 25),
                TextButton(
                  onPressed: () {},
                  child: Text('Support', style: AppStyles.styleRegular12Gray),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
                  style: AppStyles.styleRegular12Gray,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return LoginViewBody();
                        },
                      ),
                    );
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
