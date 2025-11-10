import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/features/auth/presentation/views/create_account_view.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/login_form_container.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/login_header.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/security_item.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/ways_to_continue.dart';

class LoginViewBody extends StatelessWidget {
  const LoginViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE8F7F2),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              children: [
                LoginHeader(
                  title: 'MediCare+',
                  subtitle: 'Your trusted healthcare companion',
                  iconPath: Assets.imagesHeartRate,
                  imagePath: Assets.imagesLogin,
                ),
                SizedBox(height: 20),
                Text('Welcome👋', style: AppStyles.styleBold30),
                SizedBox(height: 8),
                Text(
                  'Sign in to access your healthcare dashboard',
                  style: AppStyles.styleRegular16GrayDark.copyWith(
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 30),
                LoginFormContainer(
                  gradientColors: [Color(0xFF00BCD4), Color(0xff66BB6A)],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        indent: 20,
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    Text(
                      '__Or continue with__',
                      style: TextStyle(
                        color: Colors.grey,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        endIndent: 20,
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
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
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: AppStyles.styleMedium16Dark,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return CreateAccountView();
                            },
                          ),
                        );
                      },
                      child: Text(
                        "Create Account",
                        style: AppStyles.styleRegular16Teal.copyWith(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        SecurityItem(
                          text: 'Secure',
                          icon: Assets.imagesSecure,
                          iconColor: Color(0xff66BB6A),
                        ),
                        Spacer(flex: 1),
                        SecurityItem(
                          text: 'Encrypted',
                          icon: Assets.imagesLock,
                          iconColor: Color(0xff26A69A),
                        ),
                        Spacer(flex: 1),
                        SecurityItem(
                          text: 'HIPAA Compliant',
                          icon: Assets.imagesHIPAACompliant,
                          iconColor: Color(0xff66BB6A),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
