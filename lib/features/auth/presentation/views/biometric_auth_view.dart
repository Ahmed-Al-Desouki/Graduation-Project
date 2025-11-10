import 'package:flutter/material.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
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
    final accessToken = await SecureStorageHelper.getAccessToken();
    final refreshToken = await SecureStorageHelper.getRefreshToken();

    if (accessToken == null || refreshToken == null) {
      if (context.mounted) context.go(AppRouter.kLogin);
      return;
    }

    final validityResult = await _authRepository.checkAccessValidity(
      accessToken,
    );

    final isAccessValid = validityResult.fold(
      (failure) => false,
      (isValid) => isValid,
    );

    if (isAccessValid) {
      if (context.mounted) context.go(AppRouter.kSettings);
    } else {
      final validityResult_RefreshToken = await _authRepository
          .checkRefreshValidity(refreshToken);
      final isRefreshValid = validityResult_RefreshToken.fold(
        (failure) => false,
        (isValid) => isValid,
      );
      if (isRefreshValid) {
        final refreshResult = await _authRepository.refreshToken(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        await refreshResult.fold(
          (failure) async {
            await SecureStorageHelper.clearTokens();
            if (context.mounted) context.go(AppRouter.kLogin);
          },
          (tokenModel) async {
            await SecureStorageHelper.updateTokens(
              newAccessToken: tokenModel.accessToken,
              newRefreshToken: tokenModel.refreshToken,
            );
            if (context.mounted) context.go(AppRouter.kSettings);
          },
        );
      }
    }
    if (mounted) {
      setState(() => _isAuthenticating = false);
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
