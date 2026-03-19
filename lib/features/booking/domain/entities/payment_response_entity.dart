class PaymentResponseEntity {
  final String paymentUrl;
  final String paymentId; // الـ ID الداخلي في السيستم [cite: 85]
  final double amount;

  PaymentResponseEntity({
    required this.paymentUrl,
    required this.paymentId,
    required this.amount,
  });
}
