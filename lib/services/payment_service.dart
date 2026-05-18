import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  late Razorpay _razorpay;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void startCheckout(
    double amount,
    String userId,
    String userName,
    String userEmail,
    String userPhone,
  ) {
    var options = {
      'key': 'rzp_test_YOUR_KEY_HERE', // Replace with actual test key
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'ClimaGrowth Market',
      'description': 'Purchase from ClimaGrowth Supplies Store',
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
        'name': userName,
      },
      'external': {
        'wallets': ['paytm', 'googlepay', 'phonepe']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Create order in Firestore
    await _firestore.collection('orders').add({
      'orderId': response.paymentId,
      'userId': 'current_user_id', // Get from AuthProvider
      'items': [], // Get from CartProvider
      'paymentId': response.paymentId,
      'paymentStatus': 'completed',
      'orderStatus': 'placed',
      'placedAt': DateTime.now(),
      'expectedDelivery': DateTime.now().add(const Duration(days: 7)),
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Error: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('Wallet: ${response.walletName}');
  }

  void dispose() {
    _razorpay.clear();
  }
}
