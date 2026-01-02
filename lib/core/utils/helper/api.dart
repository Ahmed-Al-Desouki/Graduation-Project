// import 'package:dio/dio.dart';

// class ApiService {
//   final Dio _dio;
//   // https://medicare-plus.runasp.net/api/
//   ApiService({String? baseUrl})
//     : _dio = Dio(
//         BaseOptions(
//           baseUrl:
//               baseUrl ??
//               'https://medicare-plus.runasp.net/api/',
//           connectTimeout: const Duration(seconds: 15),
//           receiveTimeout: const Duration(seconds: 15),
//           headers: {'Content-Type': 'application/json'},
//           // headers: {'Content-Type': 'multipart/form-data'},
//         ),
//       ) {
//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) {
//           print('➡️ [REQUEST] ${options.method} ${options.path}');
//           print('Body: ${options.data}');

//           return handler.next(options);
//         },
//         onResponse: (response, handler) {
//           print('✅ [RESPONSE] ${response.statusCode}');
//           return handler.next(response);
//         },
//         onError: (DioError e, handler) {
//           print('❌ [ERROR] ${e.response?.statusCode} | ${e.message}');
//           return handler.next(e);
//         },
//       ),
//     );
//   }

//   // Future<dynamic> get(String endpoint, {String? token}) async {
//   //   try {
//   //     final response = await _dio.get(
//   //       endpoint,
//   //       options: Options(
//   //         headers: token != null ? {'Authorization': 'Bearer $token'} : null,
//   //       ),
//   //     );
//   //     return response.data;
//   //   } catch (e) {
//   //     rethrow;
//   //   }
//   // }
//   Future<dynamic> get(
//     String endpoint, {
//     String? bearerToken,
//     String? refreshCookie,
//   }) async {
//     try {
//       final Map<String, dynamic> headers = {};
//       // print('Bearer Token: $bearerToken');
//       // print('Refresh Cookie: $refreshCookie');
//       if (bearerToken != null) {
//         print('Bearer Token: $bearerToken');

//         headers['Authorization'] = 'Bearer $bearerToken';
//       }

//       if (refreshCookie != null) {
//         print('Refresh Cookie: $refreshCookie');

//         headers['Cookie'] = 'refresh_token=$refreshCookie';
//       }

//       final response = await _dio.get(
//         endpoint,
//         options: Options(headers: headers),
//       );

//       return response.data;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<dynamic> post(String endpoint, dynamic body, {String? token}) async {
//     try {
//       print('Sending data type: ${body.runtimeType}');
//       if (body is FormData) {
//         body.fields.forEach((e) => print('➡️ ${e.key}: ${e.value}'));
//       }

//       final response = await _dio.post(
//         endpoint,
//         data: body,
//         options: Options(
//           headers: {
//             if (token != null) 'Authorization': 'Bearer $token',
//             'Content-Type':
//                 body is FormData ? 'multipart/form-data' : 'application/json',
//           },
//         ),
//       );
//       return response.data;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<dynamic> put(String endpoint, dynamic body, {String? token}) async {
//     try {
//       final response = await _dio.put(
//         endpoint,
//         data: body,
//         options: Options(
//           headers: token != null ? {'Authorization': 'Bearer $token'} : null,
//         ),
//       );
//       return response.data;
//     } catch (e) {
//       rethrow;
//     }
//   }
// }

import 'package:dio/dio.dart';
import 'package:graduation_project/core/utils/app_router.dart';
import 'package:graduation_project/core/utils/helper/secure_storage_helper.dart';

class ApiService {
  final Dio _dio;

  ApiService({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? 'https://medicare-plus.runasp.net/api/',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        // 1. وانت باعت الريكويست: ضيف التوكن أوتوماتيك
        onRequest: (options, handler) async {
          final token = await SecureStorageHelper.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print('➡️ [REQUEST] ${options.method} ${options.path}');
          return handler.next(options);
        },

        // 2. والرد راجع: مفيش مشاكل
        onResponse: (response, handler) {
          print('✅ [RESPONSE] ${response.statusCode}');
          return handler.next(response);
        },

        // 3. لو حصل خطأ: هنا اللعب كله
        onError: (DioException e, handler) async {
          print('❌ [ERROR] ${e.response?.statusCode} | ${e.message}');

          // لو الخطأ 401 (Unauthorized) يعني التوكن انتهى
          if (e.response?.statusCode == 401) {
            print("⚠️ Token Expired! Attempting to refresh...");

            try {
              // أ. هات الريفريش توكن
              final refreshToken = await SecureStorageHelper.getRefreshToken();
              final accessToken = await SecureStorageHelper.getAccessToken();

              if (refreshToken == null || accessToken == null) {
                // مفيش ريفريش توكن أصلاً، خرج المستخدم
                return _handleSessionExpired(handler, e);
              }

              // ب. اطلب تجديد التوكن
              // ملحوظة: بنعمل انستانس Dio جديد عشان ميدخلش في Loop مع الانترسبتور الحالي
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
                // ج. نجح التجديد! احفظ الجديد
                final newAccess = response.data['data']['accessToken'];
                final newRefresh = response.data['data']['refreshToken'];

                await SecureStorageHelper.updateTokens(
                  newAccessToken: newAccess,
                  newRefreshToken: newRefresh,
                );

                print("✅ Token Refreshed Successfully!");

                // د. عيد الريكويست الأصلي اللي فشل بس بالتوكن الجديد
                // بنعدل الهيدر في الريكويست القديم
                e.requestOptions.headers['Authorization'] = 'Bearer $newAccess';

                // بنبعت الريكويست تاني
                final cloneReq = await _dio.fetch(e.requestOptions);

                // رجع النتيجة السليمة وكأن شيئاً لم يكن
                return handler.resolve(cloneReq);
              } else {
                // فشل التجديد (حتى الريفريش منتهي)
                return _handleSessionExpired(handler, e);
              }
            } catch (refreshError) {
              // حصل خطأ أثناء التجديد
              return _handleSessionExpired(handler, e);
            }
          }

          // لو أي خطأ تاني غير 401، رجعه زي ما هو
          return handler.next(e);
        },
      ),
    );
  }

  // دالة الخروج لو الجلسة انتهت تماماً
  Future<dynamic> _handleSessionExpired(
    ErrorInterceptorHandler handler,
    DioException e,
  ) async {
    print("⛔ Session Expired. Logging out...");
    await SecureStorageHelper.clearTokens();

    // توجيه المستخدم لصفحة الدخول
    AppRouter.router.go(AppRouter.kLogin);

    return handler.next(e);
  }

  // --- دوال الـ GET, POST, PUT (بقت أبسط بكتير) ---

  // لاحظ: شيلنا باراميتر token لأن الانترسبتور بيحطه لوحده
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
      final response = await _dio.post(
        endpoint,
        data: body,
        // لو محتاج Content-Type مختلف للصور، الديـو بيعرفه لوحده لو Body FormData
      );
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
