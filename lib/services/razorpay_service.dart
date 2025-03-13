import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../models/billing_model.dart';
import '../providers/connection_provider.dart';
import '../services/connection_service.dart';
import '../utils/ui_helpers.dart';
import 'package:provider/provider.dart';

class RazorpayService {
  final ConnectionService _connectionService = ConnectionService();
  late Razorpay _razorpay;

  // Nullable context and bill to allow for more flexible usage
  BuildContext? _context;
  MonthlyBilling? _currentBill;

  // Callback for payment result
  Function(bool)? _onPaymentResult;

  // Constructor
  RazorpayService() {
    _razorpay = Razorpay();
    _setupRazorpayListeners();
  }

  // Setup Razorpay event listeners
  void _setupRazorpayListeners() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // Initialize Razorpay with context, bill, and optional callback
  void initialize({
    required BuildContext context,
    required MonthlyBilling bill,
    Function(bool)? onPaymentResult,
  }) {
    _context = context;
    _currentBill = bill;
    _onPaymentResult = onPaymentResult;
  }

  // Initiate payment with comprehensive options
  void initiatePayment({
    required BuildContext context,
    required MonthlyBilling bill,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    Function(bool)? onPaymentResult,
  }) {
    // Update context and bill
    _context = context;
    _currentBill = bill;

    // Override callback if provided
    if (onPaymentResult != null) {
      _onPaymentResult = onPaymentResult;
    }

    // Validate bill amount
    if (bill.billAmount <= 0) {
      _handleInvalidBill();
      return;
    }

    // Prepare Razorpay payment options
    final paymentOptions = _prepareRazorpayOptions(
      bill,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
    );

    // Attempt to open Razorpay checkout
    _openRazorpayCheckout(paymentOptions);
  }

  // Prepare Razorpay payment options
  Map<String, dynamic> _prepareRazorpayOptions(
      MonthlyBilling bill, {
        String? customerName,
        String? customerEmail,
        String? customerPhone,
      }) {
    return {
      'key': 'rzp_test_xwcE99NTPVZiHX', // Replace with your actual key
      'amount': (bill.billAmount * 100).toInt(), // Convert to paisa
      'name': 'ISP Management',
      'description': 'Monthly Bill Payment for Bill #${bill.id}',
      'prefill': {
        'name': customerName ?? '',
        'contact': customerPhone ?? '',
        'email': customerEmail ?? '',
      },
      'notes': {
        'bill_id': bill.id.toString(),
      }
    };
  }

  // Open Razorpay checkout
  void _openRazorpayCheckout(Map<String, dynamic> options) {
    try {
      _razorpay.open(options);
    } catch (e) {
      log('Razorpay Initiation Error: $e');
      _handlePaymentInitializationError();
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Validate context and bill
    if (_context == null || _currentBill == null) {
      _notifyPaymentFailure('Invalid payment context');
      return;
    }

    try {
      // Prepare payment details with fallback values
      final paymentDetails = {
        'payment_id': response.paymentId ?? '',
        'order_id': response.orderId ?? (_currentBill!.id.toString()), // Fallback to bill ID
        'signature': response.signature ?? 'razorpay_signature_not_available',
      };

      // Log payment details
      log('Razorpay Payment Details:');
      paymentDetails.forEach((key, value) {
        log('$key: $value');
      });

      // Confirm payment through provider
      final provider = Provider.of<ConnectionProvider>(_context!, listen: false);
      final success = await provider.confirmPayment(_currentBill!.id!, paymentDetails);

      // Handle payment confirmation result
      if (success) {
        _notifyPaymentSuccess();
      } else {
        _notifyPaymentFailure('Payment confirmation failed');
      }
    } catch (e, stackTrace) {
      _handlePaymentConfirmationError(e, stackTrace);
    }
  }

  // Handle payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    log('Payment Failed: ${response.code} - ${response.message}');
    _notifyPaymentFailure(response.message!);
  }

  // Handle external wallet selection
  void _handleExternalWallet(ExternalWalletResponse response) {
    log('External Wallet Selected: ${response.walletName}');
    UIHelpers.showToast(message: 'Wallet: ${response.walletName}');
  }

  // Helper methods for handling various scenarios
  void _handleInvalidBill() {
    log('Invalid bill amount');
    UIHelpers.showToast(message: 'Invalid Bill Amount');
    _notifyPaymentFailure('Invalid bill amount');
  }

  void _handlePaymentInitializationError() {
    log('Payment initialization failed');
    UIHelpers.showToast(message: 'Payment Initialization Failed');
    _notifyPaymentFailure('Payment initialization failed');
  }

  void _handlePaymentConfirmationError(Object e, StackTrace stackTrace) {
    log('Payment Confirmation Error',
        error: e,
        stackTrace: stackTrace
    );
    UIHelpers.showToast(message: 'Payment processing error');
    _notifyPaymentFailure('Payment processing error');
  }

  void _logPaymentDetails(Map<String, dynamic> paymentDetails) {
    log('Razorpay Payment Details:');
    paymentDetails.forEach((key, value) {
      log('$key: $value');
    });
  }

  void _notifyPaymentSuccess() {
    _onPaymentResult?.call(true);
    UIHelpers.showToast(message: 'Payment successful');
  }

  void _notifyPaymentFailure(String reason) {
    _onPaymentResult?.call(false);
    UIHelpers.showToast(message: 'Payment failed: $reason');
  }

  // Cleanup method
  void dispose() {
    _razorpay.clear();
  }
}