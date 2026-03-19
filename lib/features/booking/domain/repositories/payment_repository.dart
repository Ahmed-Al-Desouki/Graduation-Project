import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/entities/booking_request_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/payment_response_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentResponseEntity>> createPayment(
    PaymentRequestEntity request,
  );
}
