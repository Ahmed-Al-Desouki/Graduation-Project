import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/auth/data/models/auth_token_model.dart';

import 'package:graduation_project/features/auth/data/repo/auth_repo.dart';
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
        (failure) =>
            emit(LoginFailure(errMessage: "${failure.errmessage}+ test")),
        (response) async {
          // ... نفس منطق معالجة LoginSuccess الحالي
          if (response is AuthTokenModel) {
            // ... (فك تشفير الـ JWT وحفظ التوكنات كما في السابق)
            Map<String, dynamic> payload = JwtDecoder.decode(
              response.accessToken,
            );
            final uid =
                (payload['uid'] ?? payload['userId'] ?? payload['id'] ?? '')
                    .toString();

            await SecureStorageHelper.saveTokens(
              accessToken: response.accessToken,
              refreshToken: response.refreshToken,
            );
            await SecureStorageHelper.saveUserRoleAndId(
              role: role,
              userId: uid,
            );

            // نستخدم email المستخدم من Google Account
            emit(LoginSuccess(uid: uid, email: googleUser.email!, role: role));
          } else {
            emit(
              LoginFailure(errMessage: 'Unknown response type from repository'),
            );
          }
        },
      );
    } on Exception catch (e) {
      // التعامل مع جميع الأخطاء المحتملة (بما في ذلك Google Sign In)
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
          print("MFA TOKEN IN CUBIT: ${response["mfaToken"]}");
        } else if (response is AuthTokenModel) {
          try {
            Map<String, dynamic> payload = JwtDecoder.decode(
              response.accessToken,
            );
            final role =
                (payload['role'] ?? payload['Role'] ?? '')
                    .toString()
                    .toLowerCase();
            final uid =
                (payload['UserID'] ?? payload['uid'] ?? payload['userId'] ?? payload['id'] ?? '')
                    .toString();

            await SecureStorageHelper.saveTokens(
              accessToken: response.accessToken,
              refreshToken: response.refreshToken,
            );

            await SecureStorageHelper.saveUserRoleAndId(
              role: role,
              userId: uid,
            );

            emit(LoginSuccess(uid: uid, email: email, role: role));
          } catch (e) {
            emit(LoginFailure(errMessage: 'Failed to save tokens: $e'));
          }
        } else {
          emit(
            LoginFailure(errMessage: 'Unknown response type from repository'),
          );
        }
      },
    );
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    emit(RegisterLoading());
    final result = await _authRepository.register(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
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
}
