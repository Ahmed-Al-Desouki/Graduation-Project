class PaymentResponseEntity {
  final String paymentUrl;
  final String paymentId;
  final double amount;

  PaymentResponseEntity({
    required this.paymentUrl,
    required this.paymentId,
    required this.amount,
  });
}
