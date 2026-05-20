abstract class PaymentService {
  void Function(String paymentId, String orderId)? onSuccess;
  void Function(String message)? onError;

  void openCheckout({
    required double amountInRupees,
    required String description,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? orderId,
  });

  void dispose();
}
