import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/core/utils/app_images.dart';
import 'package:graduation_project/core/utils/app_styles.dart';
import 'package:graduation_project/features/auth/presentation/views/create_account_view.dart';

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
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: SvgPicture.asset(
                    Assets.imagesHeartRate,
                    height: 50,
                    width: 50,
                    colorFilter: const ColorFilter.mode(
                      Color(0xff26A69A),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'MedCare+',
                  style: AppStyles.styleBold30.copyWith(fontSize: 40),
                ),
                SizedBox(height: 8),
                Text(
                  'Your trusted healthcare companion',
                  style: AppStyles.styleRegular16GrayDark.copyWith(
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    Assets.imagesLogin,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
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
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 25,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  height: 400,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 25,
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Address',
                            style: AppStyles.styleSemiBold14Dark,
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Color(0xFF9CA3AF),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                hintText: 'Enter your email',
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                          Text(
                            'Password',
                            style: AppStyles.styleSemiBold14Dark,
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Color(0xFF9CA3AF),
                                ),
                                suffixIcon: const Icon(
                                  Icons.visibility,
                                  color: Color(0xFF9CA3AF),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                hintText: 'Enter your password',
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: GestureDetector(
                              child: Text(
                                'Forgot Password?',
                                style: AppStyles.styleRegular16Teal.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Container(
                              width: 300,
                              height: 65,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00BCD4),
                                    Color(0xff66BB6A),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 20,
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
                  ),
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
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          Assets.imagesGoogleColorSvgrepoCom,
                          height: 20,
                          width: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Continue with Google',
                          style: AppStyles.styleMedium16Dark,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          Assets.imagesApple173SvgrepoCom,
                          height: 20,
                          width: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Continue with Apple',
                          style: AppStyles.styleMedium16Dark,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: AppStyles.styleMedium16Dark,
                    ),
                    GestureDetector(
                      onTap: () {
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
                  margin: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          Assets.imagesSecure,
                          height: 20,
                          width: 20,
                          colorFilter: const ColorFilter.mode(
                            Color(0xff66BB6A),
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text('Secure', style: TextStyle(color: Colors.black54)),
                        Spacer(flex: 1),
                        SvgPicture.asset(
                          Assets.imagesLock,
                          height: 20,
                          width: 20,
                          colorFilter: const ColorFilter.mode(
                            Color(0xff26A69A),
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Encrypted',
                          style: TextStyle(color: Colors.black54),
                        ),
                        Spacer(flex: 1),
                        SvgPicture.asset(
                          Assets.imagesHIPAACompliant,
                          height: 20,
                          width: 20,
                          colorFilter: const ColorFilter.mode(
                            Color(0xff66BB6A),
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'HIPAA Compliant',
                          style: TextStyle(color: Colors.black54),
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
