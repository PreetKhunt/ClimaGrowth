import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';
import 'payment_service_base.dart';

class WebPaymentService extends PaymentService {
  WebPaymentService() {
    if (kDebugMode) print('Web PaymentService initialized');
  }

  @override
  void openCheckout({
    required double amountInRupees,
    required String description,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    String? orderId,
  }) {
    if (amountInRupees <= 0) {
      onError?.call('Invalid amount');
      return;
    }

    final amountInPaise = (amountInRupees * 100).round();
    final name = customerName.isEmpty ? 'Test User' : customerName;
    final email = customerEmail.isEmpty ? 'test@climagrowth.com' : customerEmail;
    final phone = customerPhone.isEmpty ? '9999999999' : customerPhone;

    try {
      final script = '''
        (function() {
          var options = {
            key: "$kRazorpayTestKey",
            amount: $amountInPaise,
            currency: "INR",
            name: "ClimaGrowth",
            description: "$description",
            prefill: { name: "$name", email: "$email", contact: "$phone" },
            theme: { color: "#E55934" },
            handler: function(response) {
              window._rzpPaymentId = response.razorpay_payment_id || "";
              window._rzpOrderId   = response.razorpay_order_id   || "";
              window._rzpSuccess   = true;
            },
            modal: {
              ondismiss: function() {
                window._rzpSuccess = false;
                window._rzpError   = "Payment cancelled";
              }
            }
          };
          var rzp = new Razorpay(options);
          rzp.open();
        })();
      ''';
      js.context.callMethod('eval', [script]);

      // Poll for result (Razorpay is async)
      Future.delayed(const Duration(seconds: 2), _pollResult);
    } catch (e) {
      if (kDebugMode) print('Web Razorpay error: $e');
      onError?.call('Failed to open payment: $e');
    }
  }

  void _pollResult([int attempt = 0]) {
    final success = js.context['_rzpSuccess'];
    if (success == true) {
      final pid = js.context['_rzpPaymentId']?.toString() ?? '';
      final oid = js.context['_rzpOrderId']?.toString() ?? '';
      js.context['_rzpSuccess'] = null;
      onSuccess?.call(pid, oid);
    } else if (success == false) {
      final err = js.context['_rzpError']?.toString() ?? 'Payment failed';
      js.context['_rzpSuccess'] = null;
      onError?.call(err);
    } else if (attempt < 60) {
      Future.delayed(const Duration(seconds: 1), () => _pollResult(attempt + 1));
    }
  }

  @override
  void dispose() {}
}

PaymentService createPaymentService() => WebPaymentService();
