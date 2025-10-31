import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl:
              baseUrl ??
              'https://nonvolitional-unstuccoed-wilfred.ngrok-free.dev/api/',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
          // headers: {'Content-Type': 'multipart/form-data'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('➡️ [REQUEST] ${options.method} ${options.path}');
          print('Body: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ [RESPONSE] ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioError e, handler) {
          print('❌ [ERROR] ${e.response?.statusCode} | ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  Future<dynamic> get(String endpoint, {String? token}) async {
    try {
      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, dynamic body, {String? token}) async {
    try {
      print('Sending data type: ${body.runtimeType}');
      if (body is FormData) {
        body.fields.forEach((e) => print('➡️ ${e.key}: ${e.value}'));
      }

      final response = await _dio.post(
        endpoint,
        data: body,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Content-Type':
                body is FormData ? 'multipart/form-data' : 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, dynamic body, {String? token}) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: body,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
