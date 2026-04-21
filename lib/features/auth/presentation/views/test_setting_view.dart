import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/functions/show_snack_bar.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/auth/presentation/manger/auth_cubit/auth_cubit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box settingsBox;
  bool isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box('settings');
    isBiometricEnabled = settingsBox.get(
      'biometric_enabled',
      defaultValue: false,
    );
  }

  Future<void> _toggleBiometric(bool value) async {
    final localAuth = LocalAuthentication();
    bool canCheckBiometrics = await localAuth.canCheckBiometrics;
    if (!canCheckBiometrics) {
      showSnackBar(
        context,
        'This device does not support fingerloging',
        Colors.red,
      );
      return;
    }

    bool didAuthenticate = await localAuth.authenticate(
      localizedReason: 'Confirm your identity to change settings',
      options: const AuthenticationOptions(stickyAuth: true),
    );

    if (didAuthenticate) {
      try {
        await settingsBox.put('biometric_enabled', value);
        setState(() => isBiometricEnabled = value);

        if (value) {
          showSnackBar(
            context,
            'Fingerlog activation was successful✅',
            Colors.green,
          );
        } else {
          showSnackBar(
            context,
            'Fingerlog deactivation was successful❌',
            Colors.orange,
          );
        }
      } catch (e) {
        showSnackBar(
          context,
          'An error occurred during activation: $e',
          Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              context.go(AppRouter.kLogin);
            }
            if (state is LoginFailure) {
              showSnackBar(context, state.errMessage, Colors.red);
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                SwitchListTile(
                  title: const Text('تسجيل الدخول بالبصمة'),
                  value: isBiometricEnabled,
                  onChanged: _toggleBiometric,
                ),
                const Spacer(),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child:
                        state is LoginLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                context.read<AuthCubit>().logout();
                              },
                              child: const Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
