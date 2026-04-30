import 'package:graduation_project/features/booking/domain/entities/payment_response_entity.dart';

class PaymentResponseModel extends PaymentResponseEntity {
  PaymentResponseModel({
    required super.paymentUrl,
    required super.paymentId,
    required super.amount,
  });

  factory PaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentResponseModel(
      paymentUrl: json['paymentUrl'] ?? '',
      paymentId: json['paymentId'] ?? '',
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
