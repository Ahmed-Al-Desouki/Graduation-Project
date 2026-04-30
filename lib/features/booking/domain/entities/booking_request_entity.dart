class PaymentRequestEntity {
  final String appointmentId;
  final String paymentMethod;

  PaymentRequestEntity({
    required this.appointmentId,
    this.paymentMethod = "Card",
  });
}
