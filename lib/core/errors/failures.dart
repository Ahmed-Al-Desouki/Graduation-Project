import 'package:dio/dio.dart';

abstract class Failure {
  final String errmessage;
  const Failure(this.errmessage);
}

class ServerFailure extends Failure {
  ServerFailure(super.errmessage);

  factory ServerFailure.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure('Connection Timeout with the ApiServer');
      case DioExceptionType.sendTimeout:
        return ServerFailure('Send Timeout with the ApiServer');
      case DioExceptionType.receiveTimeout:
        return ServerFailure('Receive Timeout with the ApiServer');
      case DioExceptionType.badResponse:
        return ServerFailure.fromresponse(
          e.response?.statusCode,
          e.response?.data,
        );
      case DioExceptionType.connectionError:
        return ServerFailure('No Internet Connection');
      case DioExceptionType.cancel:
        return ServerFailure('Request to the ApiServer was Cancelled');
      case DioExceptionType.unknown:
        if (e.message != null && e.message!.contains("SocketException")) {
          return ServerFailure("No Internet Connection");
        }
        if (e.type == DioExceptionType.cancel) {
          return ServerFailure('Process cancelled by user');
        }
        return ServerFailure('An unknown error occurred');
      default:
        return ServerFailure('An unexpected error occurred try again later');
    }
  }

  factory ServerFailure.fromresponse(int? statusCode, dynamic response) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      if (response is Map &&
          response.containsKey('data') &&
          response['data'] is Map &&
          response['data']['message'] != null) {
        return ServerFailure(response['data']['message']);
      }

      if (response is Map && response.containsKey('message')) {
        return ServerFailure(response['message']);
      }

      return ServerFailure('Invalid credentials or bad request.');
    } else if (statusCode == 404) {
      return ServerFailure('The requested resource was not found.');
    } else if (statusCode == 500) {
      return ServerFailure('Internal Server Error, please try again later.');
    } else {
      return ServerFailure('Unexpected Error Occurred: $statusCode');
    }
  }

  factory ServerFailure.fromPlainStringResponse(
    int? statusCode,
    dynamic response,
  ) {
    final message = response?.toString() ?? 'Unknown error';

    switch (statusCode) {
      case 400:
        return ServerFailure(message);
      case 401:
        return ServerFailure('Token expired. Please login again.');
      case 403:
        return ServerFailure('Access denied. Doctor role required.');
      case 404:
        return ServerFailure(message);
      case 500:
        return ServerFailure('Server error. Please try again later.');
      default:
        return ServerFailure(message);
    }
  }
}

class CacheFailure extends Failure {
  CacheFailure(super.errmessage);
}

class OfflineFailure extends Failure {
  OfflineFailure(super.errmessage);
}

class FirebaseFailure extends Failure {
  FirebaseFailure(super.errmessage);
}
