import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';
import 'package:graduation_project/features/auth/data/models/auth_token_model.dart';
import 'package:graduation_project/features/auth/data/repo/auth_repo.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

enum SessionStatus { valid, invalid, error }

class SessionManager {
  final AuthRepository _authRepository;

  SessionManager(this._authRepository);

  Future<SessionStatus> validateSession() async {
    try {
      final accessToken = await SecureStorageHelper.getAccessToken();
      final refreshToken = await SecureStorageHelper.getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        return SessionStatus.invalid;
      }

      final accessResult = await _authRepository.checkAccessValidity(
        accessToken,
      );
      final isAccessValid = accessResult.fold((l) => false, (r) => r);

      if (isAccessValid) {
        return SessionStatus.valid;
      }

      print(
        "⚠️ Access Token expired or invalid. Attempting to refresh directly...",
      );

      final refreshResult = await _authRepository.refreshToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      return await refreshResult.fold(
        (failure) async {
          print("❌ Refresh failed: ${failure.errmessage}");
          await SecureStorageHelper.clearTokens();
          return SessionStatus.invalid;
        },
        (tokenModel) async {
          if (tokenModel is AuthTokenModel) {
            print("✅ Token Refreshed via SessionManager!");
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

  Future<void> _saveNewTokensAndUserData(AuthTokenModel tokenModel) async {
    await SecureStorageHelper.updateTokens(
      newAccessToken: tokenModel.accessToken,
      newRefreshToken: tokenModel.refreshToken,
    );

    Map<String, dynamic> payload = JwtDecoder.decode(tokenModel.accessToken);
    final role =
        (payload['role'] ?? payload['Role'] ?? '').toString().toLowerCase();
    final uid =
        (payload['uid'] ?? payload['userId'] ?? payload['id'] ?? '').toString();

    await SecureStorageHelper.saveUserRoleAndId(role: role, userId: uid);
  }
}
