// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// // class SecureStorageHelper {
// //   static const FlutterSecureStorage _storage = FlutterSecureStorage();

// //   static const String _accessTokenKey = 'access_token';
// //   static const String _refreshTokenKey = 'refresh_token';
// //   static const String _userRoleKey = 'user_role';
// //   static const String _userIdKey = 'user_id';
// //   static const String _deviceIdKey = 'device_id';

// //   static Future<void> saveTokens({
// //     required String accessToken,
// //     required String refreshToken,
// //   }) async {
// //     await _storage.write(key: _accessTokenKey, value: accessToken);
// //     await _storage.write(key: _refreshTokenKey, value: refreshToken);
// //   }

// //   static Future<String?> getAccessToken() async {
// //     return await _storage.read(key: _accessTokenKey);
// //   }

// //   static Future<String?> getRefreshToken() async {
// //     return await _storage.read(key: _refreshTokenKey);
// //   }

// //   static Future<void> clearTokens() async {
// //     await _storage.delete(key: _accessTokenKey);
// //     await _storage.delete(key: _refreshTokenKey);

// //     await _storage.delete(key: _userRoleKey);
// //     await _storage.delete(key: _userIdKey);
// //     await _storage.delete(key: _deviceIdKey);
// //   }

// //   static Future<void> updateTokens({
// //     required String newAccessToken,
// //     required String newRefreshToken,
// //   }) async {
// //     await _storage.write(key: _accessTokenKey, value: newAccessToken);
// //     await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
// //   }

// //   static Future<bool> hasTokens() async {
// //     final access = await _storage.read(key: _accessTokenKey);
// //     final refresh = await _storage.read(key: _refreshTokenKey);
// //     return access != null && refresh != null;
// //   }

// //   static Future<void> saveUserRoleAndId({
// //     required String role,
// //     required String userId,
// //   }) async {
// //     await _storage.write(key: _userRoleKey, value: role);
// //     await _storage.write(key: _userIdKey, value: userId);
// //   }

// //   static Future<Map<String, String?>> getUserRole() async {
// //     final role = await _storage.read(key: _userRoleKey);
// //     return {'role': role};
// //   }

// //   static Future<String?> getUserId() async {
// //     return await _storage.read(key: _userIdKey);
// //   }

// //   static Future<void> saveDeviceId(String deviceId) async {
// //     await _storage.write(key: _deviceIdKey, value: deviceId);
// //   }

// //   static Future<String?> getDeviceId() async {
// //     return await _storage.read(key: _deviceIdKey);
// //   }
// // }

// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class SecureStorageHelper {
//   static const FlutterSecureStorage _storage = FlutterSecureStorage();

//   static const String _accessTokenKey = 'access_token';
//   static const String _refreshTokenKey = 'refresh_token';
//   static const String _userRoleKey = 'user_role';
//   static const String _userIdKey = 'user_id';
//   static const String _deviceIdKey = 'device_id';

//   // ✅ المفاتيح الجديدة
//   static const String _jtiKey = 'jti';
//   static const String _userNameKey = 'user_name';
//   static const String _userEmailKey = 'user_email';

//   // ... (saveTokens, getAccessToken, getRefreshToken, updateTokens, hasTokens زي ما هم) ...
//   // ولكن يفضل دمجهم في دالة الحفظ الشاملة تحت

//   static Future<void> saveTokens({
//     required String accessToken,
//     required String refreshToken,
//   }) async {
//     await _storage.write(key: _accessTokenKey, value: accessToken);
//     await _storage.write(key: _refreshTokenKey, value: refreshToken);
//   }

//   static Future<String?> getAccessToken() async {
//     return await _storage.read(key: _accessTokenKey);
//   }

//   static Future<String?> getRefreshToken() async {
//     return await _storage.read(key: _refreshTokenKey);
//   }

//   static Future<void> updateTokens({
//     required String newAccessToken,
//     required String newRefreshToken,
//   }) async {
//     await _storage.write(key: _accessTokenKey, value: newAccessToken);
//     await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
//   }

//   static Future<bool> hasTokens() async {
//     final access = await _storage.read(key: _accessTokenKey);
//     final refresh = await _storage.read(key: _refreshTokenKey);
//     return access != null && refresh != null;
//   }

//   // ✅ دالة جديدة تخزن كل بيانات المستخدم مرة واحدة
//   static Future<void> saveFullUserData({
//     required String role,
//     required String userId,
//     required String jti,
//     required String name,
//     required String email,
//   }) async {
//     await _storage.write(key: _userRoleKey, value: role);
//     await _storage.write(key: _userIdKey, value: userId);
//     await _storage.write(key: _jtiKey, value: jti);
//     await _storage.write(key: _userNameKey, value: name);
//     await _storage.write(key: _userEmailKey, value: email);
//   }

//   // ✅ دوال الـ Getters الجديدة
//   static Future<String?> getJti() async {
//     return await _storage.read(key: _jtiKey);
//   }

//   static Future<String?> getUserName() async {
//     return await _storage.read(key: _userNameKey);
//   }

//   static Future<String?> getUserEmail() async {
//     // لو احتاجته غير اللي في الكيوبت
//     return await _storage.read(key: _userEmailKey);
//   }

//   // الدوال القديمة
//   static Future<Map<String, String?>> getUserRole() async {
//     final role = await _storage.read(key: _userRoleKey);
//     return {'role': role};
//   }

//   static Future<String?> getUserId() async {
//     return await _storage.read(key: _userIdKey);
//   }

//   static Future<void> saveDeviceId(String deviceId) async {
//     await _storage.write(key: _deviceIdKey, value: deviceId);
//   }

//   static Future<String?> getDeviceId() async {
//     return await _storage.read(key: _deviceIdKey);
//   }

//   // ✅ تحديث المسح ليشمل المفاتيح الجديدة
//   static Future<void> clearTokens() async {
//     await _storage.delete(key: _accessTokenKey);
//     await _storage.delete(key: _refreshTokenKey);
//     await _storage.delete(key: _userRoleKey);
//     await _storage.delete(key: _userIdKey);
//     await _storage.delete(key: _deviceIdKey);
//     // الجديد
//     await _storage.delete(key: _jtiKey);
//     await _storage.delete(key: _userNameKey);
//     await _storage.delete(key: _userEmailKey);
//   }
// }

// core/utils/helper/secure_storage_helper.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _deviceIdKey = 'device_id';

  // ✅ المفاتيح الجديدة
  static const String _jtiKey = 'jti';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  // ... (دوال getAccessToken, getRefreshToken, saveDeviceId, getDeviceId زي ما هي) ...

  static Future<String?> getAccessToken() async =>
      await _storage.read(key: _accessTokenKey);
  static Future<String?> getRefreshToken() async =>
      await _storage.read(key: _refreshTokenKey);
  static Future<void> saveDeviceId(String deviceId) async =>
      await _storage.write(key: _deviceIdKey, value: deviceId);
  static Future<String?> getDeviceId() async =>
      await _storage.read(key: _deviceIdKey);

  // ✅ دالة واحدة تحفظ كل بيانات المستخدم والتوكنات
  static Future<void> saveFullUserData({
    required String accessToken,
    required String refreshToken,
    required String role,
    required String userId,
    required String jti,
    required String name,
    required String email,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userRoleKey, value: role);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _jtiKey, value: jti);
    await _storage.write(key: _userNameKey, value: name);
    await _storage.write(key: _userEmailKey, value: email);
  }

  // ✅ دوال استرجاع البيانات الجديدة
  static Future<String?> getJti() async => await _storage.read(key: _jtiKey);
  static Future<String?> getUserName() async =>
      await _storage.read(key: _userNameKey);
  static Future<String?> getUserEmail() async =>
      await _storage.read(key: _userEmailKey);

  static Future<Map<String, String?>> getUserRole() async {
    final role = await _storage.read(key: _userRoleKey);
    return {'role': role};
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // ✅ تحديث المسح ليشمل كل شيء
  static Future<void> clearTokens() async {
    await _storage.deleteAll(); // مسح كل حاجة مرة واحدة أريح وأضمن
  }

  // دالة لتحديث التوكنات فقط (للإنترسبتور)
  static Future<void> updateTokens({
    required String newAccessToken,
    required String newRefreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: newAccessToken);
    await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
  }
}
