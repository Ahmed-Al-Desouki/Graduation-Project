import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/widgets/show_snack_bar.dart';
import 'package:graduation_project/features/auth/presentation/manger/auth_cubit/auth_cubit.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String password;
  final String mfaToken;

  const OtpScreen({
    super.key,
    required this.email,
    required this.password,
    required this.mfaToken,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  String _currentOtp = "";

  void _onOtpCompleted(String otp) {
    setState(() {
      _currentOtp = otp;
    });
    context.read<AuthCubit>().login(
      email: widget.email,
      password: widget.password,
      otpCode: otp,
    );
  }

  Future<void> _showBiometricDialog() async {
    if (!context.mounted) return;

    final bool? enableBiometrics = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Enable Biometric Login?'),
            content: const Text(
              'Would you like to use your fingerprint for faster logins?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No, Thanks'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Enable'),
              ),
            ],
          ),
    );

    final settingsBox = await Hive.openBox('settings');
    await settingsBox.put('biometric_enabled', enableBiometrics ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Email')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            final role = state.role;
            if (role == 'doctor') {
              _showBiometricDialog();

              AppRouter.router.go(AppRouter.kHomeDoctor);
            } else {
              _showBiometricDialog();

              AppRouter.router.go(AppRouter.kHomePatient);
            }
          }
          if (state is LoginOtpRequired) {
            print("MFA TOKEN IN OTP SCREEN: ${widget.mfaToken}");
          }
          if (state is ResendOtpSuccess) {
            showSnackBar(context, state.message, Colors.green);
          }
          if (state is LoginFailure) {
            showSnackBar(context, state.errMessage, Colors.red);
          }
        },
        builder: (context, state) {
          final isLoading = state is LoginLoading;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter the 6-digit code sent to \n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(10),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.grey[200],
                    selectedFillColor: Colors.white,
                    activeColor: Colors.teal,
                    inactiveColor: Colors.grey,
                    selectedColor: Colors.teal,
                  ),
                  onCompleted: _onOtpCompleted,
                  onChanged: (value) {},
                  beforeTextPaste: (text) {
                    return true;
                  },
                ),
                const SizedBox(height: 30),
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      Text(
                        _currentOtp.length == 6 ? 'Verifying...' : 'Enter OTP',
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          // print("mfaToken : {$widget.mfaToken}");

                          // if (widget.mfaToken != null) {
                          // print("mfaToken : {$widget.mfaToken}");
                          context.read<AuthCubit>().resendOtp(widget.mfaToken);
                          // }
                        },
                        child: Text(
                          "Resend OTP",
                          style: TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
