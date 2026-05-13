import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/core/utils/helper/network_info.dart';
import 'package:graduation_project/features/booking/data/data_sources/booking_remote_data_source.dart';
import 'package:graduation_project/features/booking/data/models/payment_response_model.dart';
import 'package:graduation_project/features/booking/domain/entities/booking_request_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/payment_response_entity.dart';
import 'package:graduation_project/features/booking/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final BookingRemoteDataSource remoteDataSource;
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
      return PaymentResponseModel.fromJson({
        "success": true,
        "data": {
          "paymentId": "pay_123456789",
          "paymentUrl": "https://paymob.com/pay/pay_123456789",
          "message": "Payment created successfully",
        },
      });
    });
  }

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
