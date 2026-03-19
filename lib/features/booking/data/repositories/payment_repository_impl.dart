import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/utils/helper/api.dart';
import 'package:graduation_project/core/utils/helper/network_info.dart';
import 'package:graduation_project/features/booking/data/data_sources/booking_remote_data_source.dart';
import 'package:graduation_project/features/booking/data/models/payment_response_model.dart';
import 'package:graduation_project/features/booking/domain/entities/booking_request_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/payment_response_entity.dart';
import 'package:graduation_project/features/booking/domain/repositories/payment_repository.dart';

// class PaymentRepositoryImpl implements PaymentRepository {
//   final ApiService _apiService;

//   PaymentRepositoryImpl(this._apiService);

//   @override
//   Future<Either<Failure, PaymentResponseEntity>> createPayment(
//     PaymentRequestEntity request,
//   ) async {
//     try {
//       final response = await _apiService.post('/payment/create', {
//         'appointmentId': request.appointmentId,
//         'paymentMethod': request.paymentMethod,
//       });
//       // ✅ تغليف النتيجة بـ Right
//       return Right(PaymentResponseModel.fromJson(response.data));
//     } catch (e) {
//       // ✅ تغليف الخطأ بـ Left
//       return Left(ServerFailure(e.toString()));
//     }
//   }
// }

// features/booking/data/repositories/payment_repository_impl.dart

class PaymentRepositoryImpl implements PaymentRepository {
  final BookingRemoteDataSource
  remoteDataSource; // أو PaymentRemoteDataSource لو حابب تفصلهم
  final NetworkInfo networkInfo;

  PaymentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaymentResponseEntity>> createPayment(
    PaymentRequestEntity request,
  ) async {
    return await _handleRemoteRequest(() async {
      // نداء الـ API الخاص بـ Paymob: /api/payment/create
      final response = await remoteDataSource.createPayment({
        "appointmentId": request.appointmentId,
        "paymentMethod": "Card", // مبعوتة كـ String زي ما الباك طلب
      });

      // تحويل الـ JSON لموديل ومنه لـ Entity
      return PaymentResponseModel.fromJson(response);
    });
  }

  // استخدام نفس الـ Helper Method بتاعتك لتوحيد الكود
  Future<Either<Failure, T>> _handleRemoteRequest<T>(
    Future<T> Function() action,
  ) async {
    try {
      final result = await action();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
