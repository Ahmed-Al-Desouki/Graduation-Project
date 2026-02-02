import 'package:dio/dio.dart';
import 'package:graduation_project/core/constant.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';

class ApiService {
  final Dio _dio;

  ApiService({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? '$apiBaseUrl/api/',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.path.contains('share/medical-profile')) {
            print('ℹ️ Skipping Auth Token for Shared Profile request');
            return handler.next(options);
          }
          final token = await SecureStorageHelper.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print('➡️ [REQUEST] ${options.method} ${options.path}');
          print('➡️ [FULL URL]: ${options.uri}');
          return handler.next(options);
        },

        onResponse: (response, handler) {
          print('✅ [RESPONSE] ${response.statusCode}');
          return handler.next(response);
        },

        onError: (DioException e, handler) async {
          print('❌ [ERROR] ${e.response?.statusCode} | ${e.message}');
          print('❌ [DIO ERROR TYPE]: ${e.type}');
          print('❌ [ERROR DEBUG]: ${e.error}');
          print('❌ [ERROR MESSAGE]: ${e.message}');
          print('❌ [SERVER ERROR DATA]: ${e.response?.data}');

          if (e.response?.statusCode == 401) {
            print("⚠️ Token Expired! Attempting to refresh...");

            try {
              final refreshToken = await SecureStorageHelper.getRefreshToken();
              final accessToken = await SecureStorageHelper.getAccessToken();

              if (refreshToken == null || accessToken == null) {
                // مفيش ريفريش توكن أصلاً، خرج المستخدم
                return _handleSessionExpired(handler, e);
              }

              final refreshDio = Dio(
                BaseOptions(baseUrl: _dio.options.baseUrl),
              );

              final response = await refreshDio.post(
                'auth/refresh-token',
                data: {
                  "accessToken": accessToken,
                  "refreshToken": refreshToken,
                },
              );

              if (response.statusCode == 200 &&
                  response.data['success'] == true) {
                final newAccess = response.data['data']['accessToken'];
                final newRefresh = response.data['data']['refreshToken'];

                await SecureStorageHelper.updateTokens(
                  newAccessToken: newAccess,
                  newRefreshToken: newRefresh,
                );

                print("✅ Token Refreshed Successfully!");

                e.requestOptions.headers['Authorization'] = 'Bearer $newAccess';

                final cloneReq = await _dio.fetch(e.requestOptions);

                return handler.resolve(cloneReq);
              } else {
                return _handleSessionExpired(handler, e);
              }
            } catch (refreshError) {
              return _handleSessionExpired(handler, e);
            }
          }

          // لو أي خطأ تاني غير 401، رجعه زي ما هو
          return handler.next(e);
        },
      ),
    );
  }

  Future<dynamic> _handleSessionExpired(
    ErrorInterceptorHandler handler,
    DioException e,
  ) async {
    print("⛔ Session Expired. Logging out...");
    await SecureStorageHelper.clearAll();

    AppRouter.router.go(AppRouter.kLogin);

    return handler.next(e);
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, dynamic body) async {
    try {
      final response = await _dio.post(endpoint, data: body);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, dynamic body) async {
    try {
      final response = await _dio.put(endpoint, data: body);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint, {dynamic body}) async {
    try {
      final response = await _dio.delete(endpoint, data: body);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
