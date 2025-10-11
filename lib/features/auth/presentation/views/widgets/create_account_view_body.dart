import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SvgPicture.asset(
                        Assets.imagesLock,
                        height: 20,
                        width: 20,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF16A34A),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text('HIPAA', style: AppStyles.styleRegular14Gray),
                  ],
                ),
                SizedBox(width: 25),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SvgPicture.asset(
                        Assets.imagesCertificate,
                        height: 20,
                        width: 20,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF2563EB),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text('SSL', style: AppStyles.styleRegular14Gray),
                  ],
                ),
                SizedBox(width: 25),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SvgPicture.asset(
                        Assets.imagesSecure,
                        height: 20,
                        width: 20,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF9333EA),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text('Encrypted', style: AppStyles.styleRegular14Gray),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30),
            QuickAccess(),
            SizedBox(height: 35),
            Text('Or continue with', style: AppStyles.styleRegular14Gray),
            SizedBox(height: 25),
            WaysToContinue(),
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
