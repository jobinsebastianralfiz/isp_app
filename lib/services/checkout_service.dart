// lib/services/store_checkout_service.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'payment_service.dart';

class StoreCheckoutService {
  late Razorpay _razorpay;
  final PaymentService _paymentService;

  // Context and callbacks
  BuildContext? _context;
  Function(PaymentSuccessResponse)? _onPaymentSuccess;
  Function(PaymentFailureResponse)? _onPaymentFailure;
  Function(ExternalWalletResponse)? _onExternalWallet;

  // Constructor
  StoreCheckoutService({PaymentService? paymentService})
      : _paymentService = paymentService ?? PaymentService() {
    _razorpay = Razorpay();
    _setupRazorpayListeners();
  }

  // Setup Razorpay event listeners
  void _setupRazorpayListeners() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // Initialize with callbacks
  void initialize({
    required BuildContext context,
    required Function(PaymentSuccessResponse) onPaymentSuccess,
    required Function(PaymentFailureResponse) onPaymentFailure,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) {
    _context = context;
    _onPaymentSuccess = onPaymentSuccess;
    _onPaymentFailure = onPaymentFailure;
    _onExternalWallet = onExternalWallet;
  }

  // In StoreCheckoutService.dart, update the initiatePayment method

  Future<void> initiatePayment({
    required BuildContext context,
    required double amount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    Function(PaymentSuccessResponse)? onPaymentSuccess,
    Function(PaymentFailureResponse)? onPaymentFailure,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) async {
    // Update context and callbacks if provided
    _context = context;
    if (onPaymentSuccess != null) _onPaymentSuccess = onPaymentSuccess;
    if (onPaymentFailure != null) _onPaymentFailure = onPaymentFailure;
    if (onExternalWallet != null) _onExternalWallet = onExternalWallet;

    // Validate amount
    if (amount <= 0) {
      _handleInvalidAmount();
      return;
    }

    try {
      // Create Razorpay order from backend
      final orderData = await _paymentService.createRazorpayOrder(amount: amount);

      // Log the response for debugging
      log('Razorpay order response: $orderData');

      if (orderData == null) {
        throw Exception('No order data returned from server');
      }

      // Prepare Razorpay payment options using the correct keys
      final paymentOptions = {
        'key': orderData['key'], // Razorpay key from backend
        'amount': orderData['amount'],
        'order_id': orderData['id'], // Use 'id' instead of 'order_id'
        'name': 'ISP Management Store',
        'description': 'Payment for Order',
        'prefill': {
          'name': customerName,
          'contact': customerPhone,
          'email': customerEmail,
        },
        'theme': {
          'color': '#3399cc'
        }
      };

      // Open Razorpay checkout
      _razorpay.open(paymentOptions);
    } catch (e) {
      log('Razorpay Order Creation Error: $e');
      _handlePaymentInitializationError(e.toString());
    }
  }
  // Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log('Payment Success:');
    log('Payment ID: ${response.paymentId}');
    log('Order ID: ${response.orderId}');
    log('Signature: ${response.signature}');

    if (_onPaymentSuccess != null) {
      _onPaymentSuccess!(response);
    }
  }

  // Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    log('Payment Failed: ${response.code} - ${response.message}');

    if (_onPaymentFailure != null) {
      _onPaymentFailure!(response);
    }
  }

  // Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    log('External Wallet Selected: ${response.walletName}');

    if (_onExternalWallet != null) {
      _onExternalWallet!(response);
    }
  }

  // Handle invalid amount
  void _handleInvalidAmount() {
    log('Invalid payment amount');
    final error = PaymentFailureResponse(
        400,  // Using 400 as the error code
        "Payment amount must be greater than zero",
        null
    );
    _handlePaymentError(error);
  }

  // Handle initialization error
  void _handlePaymentInitializationError(String errorMessage) {
    log('Payment initialization failed: $errorMessage');
    final error = PaymentFailureResponse(
        500,  // Using 500 as the error code
        "Failed to initialize payment: $errorMessage",
        null
    );
    _handlePaymentError(error);
  }

  // Verify payment with backend
  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      return await _paymentService.verifyPayment(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );
    } catch (e) {
      log('Payment verification error: $e');
      return false;
    }
  }

  // Cleanup
  void dispose() {
    _razorpay.clear();
  }
}