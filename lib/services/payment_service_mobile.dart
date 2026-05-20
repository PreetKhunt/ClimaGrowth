import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../utils/constants.dart';
import 'payment_service_base.dart';

class MobilePaymentService extends PaymentService {
  late Razorpay _razorpay;

  MobilePaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    if (kDebugMode) print('Mobile PaymentService initialized');
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

    final options = {
      'key': kRazorpayTestKey,
      'amount': amountInPaise,
      'currency': 'INR',
      'name': 'ClimaGrowth',
      'description': description,
      'prefill': {
        'contact': customerPhone.isEmpty ? '9999999999' : customerPhone,
        'email': customerEmail.isEmpty ? 'test@climagrowth.com' : customerEmail,
        'name': customerName.isEmpty ? 'Test User' : customerName,
      },
      'theme': {
        'color': '#E55934',
      },
      'retry': {
        'enabled': true,
        'max_count': 1,
      },
    };

    if (kDebugMode) {
      print('Opening Razorpay with amount: $amountInPaise paise');
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      if (kDebugMode) print('Razorpay open error: $e');
      onError?.call(e.toString());
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    if (kDebugMode) print('Mobile payment SUCCESS: ${response.paymentId}');
    onSuccess?.call(response.paymentId ?? '', response.orderId ?? '');
  }

  void _handleError(PaymentFailureResponse response) {
    if (kDebugMode) print('Mobile payment ERROR: ${response.message}');
    onError?.call(response.message ?? 'Payment failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (kDebugMode) print('External wallet: ${response.walletName}');
  }

  @override
  void dispose() {
    _razorpay.clear();
  }
}

PaymentService createPaymentService() => MobilePaymentService();
