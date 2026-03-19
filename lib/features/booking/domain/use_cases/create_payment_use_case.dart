import 'package:dartz/dartz.dart';
import 'package:graduation_project/core/errors/failures.dart';
import 'package:graduation_project/features/booking/domain/entities/booking_request_entity.dart';
import 'package:graduation_project/features/booking/domain/entities/payment_response_entity.dart';
import 'package:graduation_project/features/booking/domain/repositories/payment_repository.dart';

class CreatePaymentUseCase {
  final PaymentRepository repository;

  CreatePaymentUseCase(this.repository);

  // الميثود اللي الكيوبت هيناديها
  Future<Either<Failure, PaymentResponseEntity>> call({
    required String appointmentId,
    String method = "Card",
  }) async {
    return await repository.createPayment(
      PaymentRequestEntity(appointmentId: appointmentId, paymentMethod: method),
    );
  }
}
