import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/core/utils/helper/service_locator.dart';
import 'package:graduation_project/features/auth/data/models/auth_token_model.dart';

import 'package:graduation_project/features/auth/data/repo/auth_repo.dart';
import 'package:graduation_project/features/auth/data/services/auth_web_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:meta/meta.dart';
import 'package:google_sign_in/google_sign_in.dart'; // إضافة الاستيراد
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final _secureStorage = const FlutterSecureStorage();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> signInWithGoogle(String role) async {
    emit(LoginLoading());
    try {
      await _googleSignIn.signOut();
      // 1. الحصول على بيانات مستخدم جوجل
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        emit(LoginFailure(errMessage: 'Google Sign In cancelled by user.'));
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 2. الحصول على Google ID Token مباشرة (الذي طلبه الباك إيند)
      final String? googleIdToken = googleAuth.idToken;

      if (googleIdToken == null) {
        emit(LoginFailure(errMessage: 'Failed to get Google ID Token.'));
        return;
      }

      // 🚨 تم حذف خطوة:
      // await _firebaseAuth.signInWithCredential(credential);
      // final String firebaseIdToken = await userCredential.user!.getIdToken();

      // 3. تمرير Google ID Token والدور للباك إيند
      final result = await _authRepository.googleSignIn(
        idToken: googleIdToken, // 💡 إرسال Google ID Token مباشرة
        role: role,
      );

      result.fold(
        (failure) => emit(LoginFailure(errMessage: failure.errmessage)),
        (response) async {
          if (response is AuthTokenModel) {
            try {
              // ✅ نفس الخطوات
              await _decodeAndSaveUserData(response);
              await _registerDeviceToken();

              final uid = await SecureStorageHelper.getUserId();
              emit(
                LoginSuccess(uid: uid!, email: googleUser.email, role: role),
              );
            } catch (e) {
              emit(LoginFailure(errMessage: 'Processing Error: $e'));
            }
          }
        },
      );
    } on Exception catch (e) {
      // التعامل مع جميع الأخطاء المحتملة (بما في ذلك Google Sign In)
      emit(LoginFailure(errMessage: 'Google Sign In Failed: $e'));
    }
  }

  // Future<void> login({
  //   required String email,
  //   required String password,
  //   String? otpCode,
  // }) async {
  //   emit(LoginLoading());

  //   final result = await _authRepository.login(
  //     email: email,
  //     password: password,
  //     otpCode: otpCode,
  //   );

  //   result.fold((failure) => emit(LoginFailure(errMessage: failure.errmessage)), (
  //     response,
  //   ) async {
  //     if (response is Map<String, dynamic>) {
  //       emit(
  //         LoginOtpRequired(
  //           message: response["message"],
  //           mfaToken: response["mfaToken"],
  //         ),
  //       );
  //       print("MFA TOKEN IN CUBIT: ${response["mfaToken"]}");
  //     } else if (response is AuthTokenModel) {
  //       try {
  //         await SecureStorageHelper.saveTokens(
  //           accessToken: response.accessToken,
  //           refreshToken: response.refreshToken,
  //         );
  //         Map<String, dynamic> payload = JwtDecoder.decode(
  //           response.accessToken,
  //         );
  //         final role = (payload['Role'] ?? '').toString().toLowerCase();
  //         final userId = (payload['UserID'] ?? '').toString();
  //         final jti = (payload['jti'] ?? '').toString();
  //         final name = (payload['Name'] ?? '').toString();
  //         final emailFromToken = (payload['Email'] ?? '').toString();

  //         await SecureStorageHelper.saveFullUserData(
  //           role: role,
  //           userId: userId,
  //           jti: jti,
  //           name: name,
  //           email: emailFromToken,
  //         );

  //         final deviceId = await _getDeviceToken();
  //         if (deviceId != null) {
  //           try {
  //             // هنا لازم نعمل AccessToken جديد في الـ Services عشان نقدر نبعت الريكويست ده
  //             // أو نعتمد على الانترسبتور (وده الأصح)
  //             await getIt<AuthWebServices>().registerDevice(deviceId);
  //             print("✅ Device Registered Successfully");
  //           } catch (e) {
  //             print("⚠️ Failed to register device: $e");
  //             // مش هنوقف اللوجن عشان دي خطوة إضافية
  //           }
  //         }

  //         emit(LoginSuccess(uid: userId, email: email, role: role));
  //       } catch (e) {
  //         emit(LoginFailure(errMessage: 'Failed to save tokens: $e'));
  //       }
  //     } else {
  //       emit(LoginFailure(errMessage: 'Unknown response type from repository'));
  //     }
  //   });
  // }

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
            // ✅ 1. تخزين البيانات
            await _decodeAndSaveUserData(response);

            // ✅ 2. تسجيل الجهاز
            await _registerDeviceToken();

            // ✅ 3. جلب البيانات للـ UI
            final uid = await SecureStorageHelper.getUserId();
            final role = (await SecureStorageHelper.getUserRole())['role']!;

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
      // 1. إلغاء تسجيل الجهاز (قبل مسح التوكن)
      final deviceId = await SecureStorageHelper.getDeviceId();
      if (deviceId != null) {
        try {
          await getIt<AuthWebServices>().unregisterDevice(deviceId);
        } catch (_) {}
      }

      // 2. مناداة الـ API Logout (الريبو هيجيب الـ jti من الستورج)
      await _authRepository.logout();

      // 3. جوجل
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      print("Logout Error: $e");
    } finally {
      // 4. مسح كل حاجة
      await SecureStorageHelper.clearTokens();

      // تصفير إعدادات البصمة
      // await Hive.box('settings').put('biometric_enabled', false);

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
      // بنجيب التوكن من فايربيس
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await SecureStorageHelper.saveDeviceId(token); // بنحفظه احتياطي
      }
      return token;
    } catch (e) {
      print("Error getting device token: $e");
      return null;
    }
  }

  Future<void> _decodeAndSaveUserData(AuthTokenModel tokenModel) async {
    // 1. فك التشفير
    Map<String, dynamic> payload = JwtDecoder.decode(tokenModel.accessToken);

    // 2. استخراج البيانات (بناءً على الـ Payload اللي انت بعته)
    // { "UserID": "4", "Name": "...", "Email": "...", "Role": "...", "jti": "..." }
    final role =
        (payload['Role'] ?? payload['role'] ?? '').toString().toLowerCase();
    final userId = (payload['UserID'] ?? payload['uid'] ?? '').toString();
    final jti = (payload['jti'] ?? '').toString();
    final name = (payload['Name'] ?? payload['name'] ?? '').toString();
    final email = (payload['Email'] ?? payload['email'] ?? '').toString();

    // 3. التخزين الشامل
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

  // دالة مساعدة لتسجيل الجهاز
  Future<void> _registerDeviceToken() async {
    final deviceId = await _getDeviceToken();
    if (deviceId != null) {
      try {
        await getIt<AuthWebServices>().registerDevice(deviceId);
        print("✅ Device Registered Successfully");
      } catch (e) {
        print("⚠️ Failed to register device: $e");
      }
    }
  }
}
