// lib/services/payment_service.dart
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../config/api_endpoints.dart';
import '../services/api_service.dart';

class PaymentService {
  final ApiService _apiService;

  PaymentService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Create Razorpay order from backend
  Future<Map<String, dynamic>> createRazorpayOrder({
    required double amount,
  }) async {
    try {
      // Convert amount to smallest currency unit (paise)
      final amountInPaise = (amount * 100).toInt();

      // Call backend to create Razorpay order
      final response = await _apiService.post(
        'api/store/payments/create-order/',
        data: {
          'amount': amountInPaise,
          'currency': 'INR',
        },
      );

      // Log the response for debugging
      dev.log('Razorpay order creation response: $response');

      // Validate response
      if (response == null) {
        throw Exception('Empty response from server');
      }

      if (!response.containsKey('order_id') ||
          !response.containsKey('amount') ||
          !response.containsKey('key')) {
        dev.log('Invalid response format: $response');
        throw Exception('Invalid order creation response format');
      }

      return response;
    } catch (e) {
      dev.log('Error creating Razorpay order: $e');
      rethrow;
    }
  }

  // Verify payment after successful transaction
  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      // Log the verification data for debugging
      dev.log('Verifying payment:');
      dev.log('Order ID: $orderId');
      dev.log('Payment ID: $paymentId');
      dev.log('Signature: $signature');

      // Send payment verification request to backend
      final response = await _apiService.post(
        'api/store/payments/verify-payment/',
        data: {
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
        },
      );

      // Log the response for debugging
      dev.log('Payment verification response: $response');

      // Backend should return whether payment is verified
      return response['verified'] ?? false;
    } catch (e) {
      dev.log('Payment verification error: $e');
      return false;
    }
  }
}

// Razorpay Payment Flow Helper
class RazorpayPaymentFlow {
  static Future<void> initiatePayment({
    required BuildContext context,
    required Razorpay razorpay,
    required PaymentService paymentService,
    required double amount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required Function(PaymentSuccessResponse) onPaymentSuccess,
    required Function(PaymentFailureResponse) onPaymentFailure,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) async {
    try {
      // 1. Create Razorpay order from backend
      final paymentOrder = await paymentService.createRazorpayOrder(
        amount: amount,
      );

      // Debug log
      dev.log('Payment order data: $paymentOrder');

      // 2. Prepare Razorpay payment options
      var options = {
        'key': paymentOrder['key'],
        'amount': paymentOrder['amount'].toString(),
        'order_id': paymentOrder['order_id'],
        'name': 'ISP Management Store',
        'description': 'Payment for Order',
        'prefill': {
          'contact': customerPhone,
          'email': customerEmail,
          'name': customerName,
        },
        'theme': {
          'color': '#3399cc'
        }
      };

      // Debug log
      dev.log('Razorpay options: $options');

      // 3. Set up Razorpay event listeners
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onPaymentSuccess);
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onPaymentFailure);

      if (onExternalWallet != null) {
        razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
      }

      // 4. Open Razorpay checkout
      razorpay.open(options);
    } catch (e) {
      // Handle any initialization errors
      dev.log('Razorpay initialization error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment initialization error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}