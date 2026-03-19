import 'package:graduation_project/features/booking/domain/entities/payment_response_entity.dart';

class PaymentResponseModel extends PaymentResponseEntity {
  PaymentResponseModel({
    required super.paymentUrl,
    required super.paymentId,
    required super.amount,
  });

  factory PaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentResponseModel(
      paymentUrl: json['paymentUrl'] ?? '', // [cite: 79, 85]
      paymentId: json['paymentId'] ?? '', // [cite: 81, 85]
      amount: (json['amount'] as num).toDouble(), // [cite: 83, 85]
    );
  }
}
