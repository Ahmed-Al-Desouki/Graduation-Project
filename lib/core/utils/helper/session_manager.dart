import 'dart:developer';
import 'dart:io';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/auth/data/models/auth_token_model.dart';
import 'package:graduation_project/features/auth/data/repo/auth_repo.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

enum SessionStatus { valid, invalid, error }

class SessionManager {
  final AuthRepository _authRepository;

  String? _cachedUserId;
  String? _cachedName;
  String? _cachedRole;

  SessionManager(this._authRepository);

  String get userId => _cachedUserId ?? '';
  String get userName => _cachedName ?? '';
  String get userRole => _cachedRole ?? '';

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

      if (accessToken == null || refreshToken == null) {
        return SessionStatus.invalid;
      }

      _cachedUserId = await SecureStorageHelper.getUserId();
      _cachedName = await SecureStorageHelper.getUserName();
      _cachedRole = await SecureStorageHelper.getUserRole1();

      bool isOnline = await _hasInternet();

      if (!isOnline) {
        log("🌐 Offline Mode: Tokens found, bypassing server check.");
        return SessionStatus.valid;
      }

      final accessResult = await _authRepository.checkAccessValidity(
        accessToken,
      );
      final isAccessValid = accessResult.fold((l) => false, (r) => r);

      if (isAccessValid) {
        _cachedUserId = await SecureStorageHelper.getUserId();
        _cachedName = await SecureStorageHelper.getUserName();
        _cachedRole = await SecureStorageHelper.getUserRole1();
        return SessionStatus.valid;
      }

      log("⚠️ Access Token expired. Attempting to refresh...");

      final refreshResult = await _authRepository.refreshToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      return await refreshResult.fold(
        (failure) async {
          log("❌ Refresh failed: ${failure.errmessage}");
          await SecureStorageHelper.clearAll();
          _cachedUserId = null;
          _cachedName = null;
          _cachedRole = null;
          return SessionStatus.invalid;
        },
        (tokenModel) async {
          if (tokenModel is AuthTokenModel) {
            log("✅ Token Refreshed!");
            await _saveNewTokensAndUserData(tokenModel);
            _cachedRole = await SecureStorageHelper.getUserRole1();
            _cachedName = await SecureStorageHelper.getUserName();
            _cachedUserId = await SecureStorageHelper.getUserId();
            return SessionStatus.valid;
          }
          return SessionStatus.error;
        },
      );
    } catch (e) {
      log("❌ Session Manager Error: $e");
      return SessionStatus.error;
    }
  }

  Future<void> _saveNewTokensAndUserData(AuthTokenModel tokenModel) async {
    await SecureStorageHelper.updateTokens(
      newAccessToken: tokenModel.accessToken,
      newRefreshToken: tokenModel.refreshToken,
    );

    Map<String, dynamic> payload = JwtDecoder.decode(tokenModel.accessToken);

    final String newUserId =
        (payload['UserID'] ?? payload['uid'] ?? '').toString();
    _cachedUserId = newUserId;

    await SecureStorageHelper.saveFullUserData(
      accessToken: tokenModel.accessToken,
      refreshToken: tokenModel.refreshToken,
      role: (payload['Role'] ?? payload['role'] ?? '').toString().toLowerCase(),
      userId: newUserId,
      jti: (payload['jti'] ?? '').toString(),
      name: (payload['Name'] ?? payload['name'] ?? '').toString(),
      email: (payload['Email'] ?? payload['email'] ?? '').toString(),
    );
  }

  void updateUserDataAfterLogin({
    required String id,
    required String name,
    required String role,
  }) {
    _cachedUserId = id;
    _cachedName = name;
    _cachedRole = role;
    log(
      "💡 SessionManager: Memory Cache updated - ID: $id, Name: $name, Role: $role",
    );
  }

  Future<bool> forceManualRefresh() async {
    try {
      final accessToken = await SecureStorageHelper.getAccessToken();
      final refreshToken = await SecureStorageHelper.getRefreshToken();

      if (accessToken == null || refreshToken == null) return false;

      log("🔄 Force Refreshing token to update permissions...");
      final result = await _authRepository.refreshToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      return await result.fold((failure) => false, (tokenModel) async {
        await _saveNewTokensAndUserData(tokenModel);
        return true;
      });
    } catch (e) {
      log("❌ Force Refresh Error: $e");
      return false;
    }
  }
}
