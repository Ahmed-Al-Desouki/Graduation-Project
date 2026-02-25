import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:graduation_project/core/database/local_database_service.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/core/utils/helper/session_manager.dart';
import 'package:graduation_project/features/auth/data/models/auth_token_model.dart';

import 'package:graduation_project/features/auth/data/repo/auth_repo.dart';
import 'package:graduation_project/features/auth/data/services/auth_web_service.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:meta/meta.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> signInWithGoogle(String role) async {
    emit(LoginLoading());
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        emit(LoginFailure(errMessage: 'Google Sign In cancelled by user.'));
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? googleIdToken = googleAuth.idToken;

      if (googleIdToken == null) {
        emit(LoginFailure(errMessage: 'Failed to get Google ID Token.'));
        return;
      }

      final result = await _authRepository.googleSignIn(
        idToken: googleIdToken,
        role: role,
      );

      result.fold(
        (failure) => emit(LoginFailure(errMessage: failure.errmessage)),
        (response) async {
          // if (response is AuthTokenModel) {
          try {
            await _decodeAndSaveUserData(response);
            await _registerDeviceToken();

            final uid = await SecureStorageHelper.getUserId();
            getIt<SessionManager>().updateIdAfterLogin(uid!);
            emit(LoginSuccess(uid: uid!, email: googleUser.email, role: role));
          } catch (e) {
            emit(LoginFailure(errMessage: 'Processing Error: $e'));
          }
          // }
        },
      );
    } on Exception catch (e) {
      emit(LoginFailure(errMessage: 'Google Sign In Failed: $e'));
    }
  }

  Future<void> login({
    required String email,
    required String password,
    String? otpCode,
  }) async {
    emit(LoginLoading());
    final result = await _authRepository.login(
      email: email,
      password: password,
      otpCode: otpCode,
    );

    result.fold(
      (failure) => emit(LoginFailure(errMessage: failure.errmessage)),
      (response) async {
        if (response is Map<String, dynamic>) {
          emit(
            LoginOtpRequired(
              message: response["message"],
              mfaToken: response["mfaToken"],
            ),
          );
        } else if (response is AuthTokenModel) {
          try {
            await _decodeAndSaveUserData(response);
            await _registerDeviceToken();

            final uid = await SecureStorageHelper.getUserId();
            final role = (await SecureStorageHelper.getUserRole())['role']!;
            getIt<SessionManager>().updateIdAfterLogin(uid!);
            emit(LoginSuccess(uid: uid!, email: email, role: role));
          } catch (e) {
            emit(LoginFailure(errMessage: 'Processing Error: $e'));
          }
        }
      },
    );
  }

  Future<void> logout() async {
    emit(LogoutLoading());
    try {
      final deviceId = await SecureStorageHelper.getDeviceId();
      if (deviceId != null) {
        try {
          await getIt<AuthWebServices>().unregisterDevice(deviceId);
        } catch (_) {}
      }
      await _authRepository.logout();

      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      await LocalDatabaseService.instance.clearAllData();

      await AwesomeNotifications().cancelAll();
    } catch (e) {
      print("Logout Error: $e");
    } finally {
      await SecureStorageHelper.clearAll();

      // await Hive.box('settings').clear();
      if (Hive.isBoxOpen('medical_history_cache')) {
        await Hive.box('medical_history_cache').clear();
      }

      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      try {
        await DefaultCacheManager().emptyCache();
      } catch (e) {
        print("Cache Manager Error: $e");
      }

      emit(LogoutSuccess());
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    XFile? profileImage,
  }) async {
    emit(RegisterLoading());
    final result = await _authRepository.register(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
      profileImage: profileImage,
    );

    result.fold(
      (failure) => emit(RegisterFailure(errMessage: failure.errmessage)),
      (message) => emit(RegisterSuccess(email: email)),
    );
  }

  Future<void> forgotPassword({required String email}) async {
    emit(ForgotPasswordLoading());
    final result = await _authRepository.forgotPassword(email: email);

    result.fold(
      (failure) => emit(ForgotPasswordFailure(errMessage: failure.errmessage)),
      (message) => emit(ForgotPasswordSuccess(message: message)),
    );
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(ResetPasswordLoading());
    final result = await _authRepository.resetPassword(
      email: email,
      token: token,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    result.fold(
      (failure) => emit(ResetPasswordFailure(errMessage: failure.errmessage)),
      (message) => emit(ResetPasswordSuccess(message: message)),
    );
  }

  Future<void> resendOtp(String mfaToken) async {
    emit(ResendOtpLoading());

    final result = await _authRepository.resendOtp(mfaToken: mfaToken);

    result.fold(
      (failure) => emit(ResendOtpFailure(errMessage: failure.errmessage)),
      (response) =>
          emit(ResendOtpSuccess(message: response["message"] ?? "OTP Sent")),
    );
  }

  Future<String?> _getDeviceToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await SecureStorageHelper.saveDeviceId(token);
      }
      return token;
    } catch (e) {
      print("Error getting device token: $e");
      return null;
    }
  }

  Future<void> _decodeAndSaveUserData(AuthTokenModel tokenModel) async {
    Map<String, dynamic> payload = JwtDecoder.decode(tokenModel.accessToken);

    final role =
        (payload['Role'] ?? payload['role'] ?? '').toString().toLowerCase();
    final userId = (payload['UserID'] ?? payload['uid'] ?? '').toString();
    final jti = (payload['jti'] ?? '').toString();
    final name = (payload['Name'] ?? payload['name'] ?? '').toString();
    final email = (payload['Email'] ?? payload['email'] ?? '').toString();

    await SecureStorageHelper.saveFullUserData(
      accessToken: tokenModel.accessToken,
      refreshToken: tokenModel.refreshToken,
      role: role,
      userId: userId,
      jti: jti,
      name: name,
      email: email,
    );
  }

  Future<void> _registerDeviceToken() async {
    final deviceId = await _getDeviceToken();
    if (deviceId != null) {
      try {
        await getIt<AuthWebServices>().registerDevice(deviceId);
      } catch (e) {
        print("⚠️ Failed to register device: $e");
      }
    }
  }
}
