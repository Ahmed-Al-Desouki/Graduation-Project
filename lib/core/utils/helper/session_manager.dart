// import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
// import 'package:graduation_project/features/auth/data/models/auth_token_model.dart';
// import 'package:graduation_project/features/auth/data/repo/auth_repo.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';

// enum SessionStatus { valid, invalid, error }

// class SessionManager {
//   final AuthRepository _authRepository;

//   SessionManager(this._authRepository);

//   Future<SessionStatus> validateSession() async {
//     try {
//       final accessToken = await SecureStorageHelper.getAccessToken();
//       final refreshToken = await SecureStorageHelper.getRefreshToken();

//       if (accessToken == null || refreshToken == null) {
//         return SessionStatus.invalid;
//       }

//       final accessResult = await _authRepository.checkAccessValidity(
//         accessToken,
//       );
//       final isAccessValid = accessResult.fold((l) => false, (r) => r);

//       if (isAccessValid) {
//         return SessionStatus.valid;
//       }

//       print(
//         "⚠️ Access Token expired or invalid. Attempting to refresh directly...",
//       );

//       final refreshResult = await _authRepository.refreshToken(
//         accessToken: accessToken,
//         refreshToken: refreshToken,
//       );

//       return await refreshResult.fold(
//         (failure) async {
//           print("❌ Refresh failed: ${failure.errmessage}");
//           await SecureStorageHelper.clearTokens();
//           return SessionStatus.invalid;
//         },
//         (tokenModel) async {
//           if (tokenModel is AuthTokenModel) {
//             print("✅ Token Refreshed via SessionManager!");
//             await _saveNewTokensAndUserData(tokenModel);
//             return SessionStatus.valid;
//           }
//           return SessionStatus.error;
//         },
//       );
//     } catch (e) {
//       print("❌ Session Manager Error: $e");
//       return SessionStatus.error;
//     }
//   }

//   Future<void> _saveNewTokensAndUserData(AuthTokenModel tokenModel) async {
//     // 1. حفظ التوكنات الجديدة
//     await SecureStorageHelper.updateTokens(
//       newAccessToken: tokenModel.accessToken,
//       newRefreshToken: tokenModel.refreshToken,
//     );

//     // 2. فك التشفير واستخراج كل البيانات
//     Map<String, dynamic> payload = JwtDecoder.decode(tokenModel.accessToken);

//     final role = (payload['Role'] ?? payload['role'] ?? '').toString();
//     final userId = (payload['UserID'] ?? payload['uid'] ?? '').toString();
//     final jti = (payload['jti'] ?? '').toString();
//     final name = (payload['Name'] ?? payload['name'] ?? '').toString();
//     final email = (payload['Email'] ?? payload['email'] ?? '').toString();

//     await SecureStorageHelper.saveFullUserData(
//       accessToken: tokenModel.accessToken,
//       refreshToken: tokenModel.refreshToken,
//       role: (payload['Role'] ?? payload['role'] ?? '').toString().toLowerCase(),
//       userId: (payload['UserID'] ?? payload['uid'] ?? '').toString(),
//       jti: (payload['jti'] ?? '').toString(),
//       name: (payload['Name'] ?? payload['name'] ?? '').toString(),
//       email: (payload['Email'] ?? payload['email'] ?? '').toString(),
//     );
//   }
// }

import 'dart:io'; // مهم من أجل SocketException
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/auth/data/models/auth_token_model.dart';
import 'package:graduation_project/features/auth/data/repo/auth_repo.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

enum SessionStatus { valid, invalid, error }

class SessionManager {
  final AuthRepository _authRepository;

  SessionManager(this._authRepository);

  /// دالة مساعدة للتحقق من وجود اتصال بالإنترنت
  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<SessionStatus> validateSession() async {
    try {
      final accessToken = await SecureStorageHelper.getAccessToken();
      final refreshToken = await SecureStorageHelper.getRefreshToken();

      // 1. إذا لم تكن هناك توكنات أصلاً، الجلسة غير صالحة فوراً
      if (accessToken == null || refreshToken == null) {
        return SessionStatus.invalid;
      }

      // 2. التحقق من الاتصال بالإنترنت
      bool isOnline = await _hasInternet();

      if (!isOnline) {
        // --- وضع الأوفلاين (Optimistic Mode) ---
        // بما أن التوكنات موجودة والنت مقطوع، نعتبر الجلسة صالحة
        // لتمكين المريض من رؤية منبهاته المخزنة محلياً [cite: 106]
        print("🌐 Offline Mode: Tokens found, bypassing server check.");
        return SessionStatus.valid;
      }

      // --- وضع الأونلاين (المنطق الأصلي الخاص بك) ---
      final accessResult = await _authRepository.checkAccessValidity(
        accessToken,
      );
      final isAccessValid = accessResult.fold((l) => false, (r) => r);

      if (isAccessValid) {
        return SessionStatus.valid;
      }

      print("⚠️ Access Token expired. Attempting to refresh...");

      final refreshResult = await _authRepository.refreshToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      return await refreshResult.fold(
        (failure) async {
          print("❌ Refresh failed: ${failure.errmessage}");
          await SecureStorageHelper.clearAll();
          return SessionStatus.invalid;
        },
        (tokenModel) async {
          if (tokenModel is AuthTokenModel) {
            print("✅ Token Refreshed!");
            await _saveNewTokensAndUserData(tokenModel);
            return SessionStatus.valid;
          }
          return SessionStatus.error;
        },
      );
    } catch (e) {
      print("❌ Session Manager Error: $e");
      return SessionStatus.error;
    }
  }

  // ... دالة _saveNewTokensAndUserData كما هي دون تغيير ...
  Future<void> _saveNewTokensAndUserData(AuthTokenModel tokenModel) async {
    await SecureStorageHelper.updateTokens(
      newAccessToken: tokenModel.accessToken,
      newRefreshToken: tokenModel.refreshToken,
    );

    Map<String, dynamic> payload = JwtDecoder.decode(tokenModel.accessToken);
    await SecureStorageHelper.saveFullUserData(
      accessToken: tokenModel.accessToken,
      refreshToken: tokenModel.refreshToken,
      role: (payload['Role'] ?? payload['role'] ?? '').toString().toLowerCase(),
      userId: (payload['UserID'] ?? payload['uid'] ?? '').toString(),
      jti: (payload['jti'] ?? '').toString(),
      name: (payload['Name'] ?? payload['name'] ?? '').toString(),
      email: (payload['Email'] ?? payload['email'] ?? '').toString(),
    );
  }
}
