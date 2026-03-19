class PaymentRequestEntity {
  final String appointmentId;
  final String paymentMethod; // هتكون دايماً "Card" حالياً [cite: 61, 467]

  PaymentRequestEntity({
    required this.appointmentId,
    this.paymentMethod = "Card",
  });
}
