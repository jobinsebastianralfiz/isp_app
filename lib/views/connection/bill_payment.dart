import 'package:flutter/material.dart';
import 'package:ispmanagement/models/billing_model.dart';
import 'package:ispmanagement/services/razorpay_service.dart';
import 'package:ispmanagement/utils/ui_helpers.dart'; // Ensure this import exists

class BillPaymentScreen extends StatefulWidget {
  final MonthlyBilling bill;

  const BillPaymentScreen({Key? key, required this.bill}) : super(key: key);

  @override
  _BillPaymentScreenState createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  late RazorpayService _razorpayService;
  bool _isPaymentInProgress = false;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();

    // Initialize Razorpay with current bill and payment result callback
    _razorpayService.initialize(
        context: context,
        bill: widget.bill,
        onPaymentResult: (success) {
          setState(() {
            _isPaymentInProgress = false;
          });

          if (success) {
            // Navigate back or show success message
            Navigator.of(context).pop();
          }
        }
    );

    // Automatically trigger payment if screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initiatePayment();
    });
  }

  @override
  void dispose() {
    // Clean up Razorpay resources
    _razorpayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Payment'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBillDetails(),
            const SizedBox(height: 20),
            _buildPaymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBillDetails() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bill Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            _buildDetailRow('Billing Period', widget.bill.billingPeriod),
            _buildDetailRow('Bill Amount', widget.bill.formattedBillAmount),
            _buildDetailRow('Status', widget.bill.paymentStatus.toUpperCase()),
            _buildDetailRow('Due Date', widget.bill.formattedDueDate),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return ElevatedButton(
      onPressed: _isPaymentInProgress ? null : _initiatePayment,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.green,
      ),
      child: Text(
        _isPaymentInProgress ? 'Processing...' : 'Pay Now',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _initiatePayment() {
    // Check if bill is already paid
    if (widget.bill.isPaid) {
      UIHelpers.showToast(message: 'This bill has already been paid.');
      return;
    }

    // Prevent multiple payment attempts
    setState(() {
      _isPaymentInProgress = true;
    });

    // Initiate Razorpay payment
    _razorpayService.initiatePayment(
        context: context,
        bill: widget.bill,
        onPaymentResult: (success) {
          setState(() {
            _isPaymentInProgress = false;
          });

          if (success) {
            // Navigate back or show success message
            Navigator.of(context).pop();
          }
        }
    );
  }
}