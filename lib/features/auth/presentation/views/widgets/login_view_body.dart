import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // لازم ScreenUtilInit يكون موجود
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
            padding: EdgeInsets.only(top: 50.h), // responsive top padding
            child: Column(
              children: [
                LoginHeader(
                  title: 'MedCare+',
                  subtitle: 'Your trusted healthcare companion',
                  iconPath: Assets.imagesHeartRate,
                  imagePath: Assets.imagesLogin,
                ),
                SizedBox(height: 20.h), // responsive spacing
                Text(
                  'Welcome👋',
                  style: AppStyles.styleBold30.copyWith(
                    fontSize: 30.sp,
                  ), // responsive font
                ),
                SizedBox(height: 8.h), // responsive spacing
                Text(
                  'Sign in to access your healthcare dashboard',
                  style: AppStyles.styleRegular16GrayDark.copyWith(
                    fontSize: 16.sp, // responsive font
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h), // responsive spacing
                LoginFormContainer(
                  gradientColors: [Color(0xFF00BCD4), Color(0xff66BB6A)],
                ),
                SizedBox(height: 20.h), // spacing before divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        indent: 20.w,
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.w,
                        vertical: 2.h,
                      ),
                      color: Colors.white,
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        endIndent: 20.w,
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                WaysToContinue(
                  text: 'Continue with Google',
                  icon: Assets.imagesGoogleColorSvgrepoCom,
                  onTap: () {},
                ),
                SizedBox(height: 15.h),
                WaysToContinue(
                  text: 'Continue with Apple',
                  icon: Assets.imagesApple173SvgrepoCom,
                  onTap: () {},
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppStyles.styleMedium16Dark.copyWith(
                        fontSize: 16.sp,
                      ), // responsive font
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
                          fontSize: 16.sp, // responsive font
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 5.w,
                  ), // responsive horizontal margin
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      15.r,
                    ), // responsive border radius
                  ),
                  height: 50.h, // responsive height
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25.w,
                    ), // responsive horizontal padding
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
                SizedBox(height: 15.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
