import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/auth/data/repo/auth_repo_impl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/features/auth/data/repo/auth_repo.dart';

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricAuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  late final AuthRepository _authRepository;

  bool _isAuthenticating = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _authRepository = getIt<AuthRepositoryimpl>();
    _authenticateUser();
  }

  Future<void> _authenticateUser() async {
    try {
      setState(() => _isAuthenticating = true);
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Use your fingerprint to continue',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        await _handleAfterBiometricSuccess();
      } else {
        setState(() => _isAuthenticating = false);
        if (context.mounted) context.go(AppRouter.kLogin);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Biometric auth failed: $e';
        _isAuthenticating = false;
      });
      if (context.mounted) context.go(AppRouter.kLogin);
    }
  }

  Future<void> _handleAfterBiometricSuccess() async {
    final sessionManager = getIt<SessionManager>();

    final status = await sessionManager.validateSession();

    if (!mounted) return;

    if (status == SessionStatus.valid) {
      final roleData = await SecureStorageHelper.getUserRole();
      final role = roleData['role']?.toLowerCase();

      if (role == 'doctor') {
        AppRouter.router.go(AppRouter.kHomeDoctor);
      } else {
        AppRouter.router.go(AppRouter.kHomePatient);
      }
    } else {
      if (context.mounted) context.go(AppRouter.kLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child:
            _isAuthenticating
                ? const CircularProgressIndicator()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.fingerprint,
                      size: 100,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage.isEmpty
                          ? 'Please authenticate to continue'
                          : _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _authenticateUser,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
      ),
    );
  }
}
