import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // لازم ScreenUtilInit يكون موجود
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/features/auth/presentation/manger/auth_cubit/auth_cubit.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/login_form_container.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/login_header.dart';
import 'package:graduation_project/features/auth/presentation/views/widgets/role_selection.dart';
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
            padding: EdgeInsets.only(top: 50.h),
            child: Column(
              children: [
                LoginHeader(
                  title: 'Wellora',
                  subtitle: 'Your trusted healthcare companion',
                  iconPath: Assets.imagesHeartRate,
                  imagePath: Assets.imagesLogin,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Welcome👋',
                  style: AppStyles.styleBold30.copyWith(fontSize: 30.sp),
                ),
                SizedBox(height: 5.h),
                LoginFormContainer(
                  gradientColors: [Color(0xFF00BCD4), Color(0xff66BB6A)],
                ),
                SizedBox(height: 15.h),
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
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return WaysToContinue(
                      text: 'Continue with Google',
                      icon: Assets.imagesGoogleColorSvgrepoCom,
                      onTap:
                          state is LoginLoading
                              ? null
                              : () async {
                                final String? role =
                                    await RoleSelectionDialog.show(context);
                                if (role != null && context.mounted) {
                                  context.read<AuthCubit>().signInWithGoogle(
                                    role,
                                  );
                                }
                              },
                    );
                  },
                ),
                SizedBox(height: 20.h),

                SizedBox(height: 20.h),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  height: 50.h,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.w),
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
