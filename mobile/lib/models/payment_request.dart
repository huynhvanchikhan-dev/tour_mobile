class PaymentRequest {
  final String bookingId;
  final String appuser;
  final int amount;
  final String order_id;
  final String qrUrl;
  final String paymentMethod;

  PaymentRequest({required this.bookingId, required this.appuser, required this.amount, required this.order_id, required this.qrUrl, required this.paymentMethod});
  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'appuser': appuser,
      'amount': amount,
      'order_id': order_id,
      'qrUrl': qrUrl,
      'paymentMethod': paymentMethod,
    };
  }
}