// checkout_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ispmanagement/config/api_endpoints.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../models/cart_model.dart';
import '../../services/cart_service.dart';
import '../../services/checkout_service.dart';
import '../../services/order_service.dart';
import '../../services/payment_service.dart';
import '../../utils/ui_helpers.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  final PaymentService _paymentService = PaymentService();
  final StoreCheckoutService _checkoutService = StoreCheckoutService();

  // Form Key for Validation
  final _formKey = GlobalKey<FormState>();

  // State Variables
  Cart? _cart;
  bool _isLoading = true;
  bool _isPlacingOrder = false;

  // Store order data temporarily for payment flow
  Map<String, dynamic> _tempOrderData = {};

  // Personal Information Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Address Controllers
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  // Payment Method
  String _paymentMethod = 'Razorpay';
  late Razorpay _razorpay;
  @override
  void initState() {
    super.initState();
    _loadCart();
    _initializeCheckoutService();
  }

  @override
  void dispose() {
    _disposeControllers();
    _checkoutService.dispose();
    super.dispose();
  }

  void _initializeCheckoutService() {
    _checkoutService.initialize(
      context: context,
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentFailure: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  void _disposeControllers() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cart = await _cartService.getCart();
      setState(() {
        _cart = cart;
        _isLoading = false;
      });
    } catch (e) {
      _showErrorSnackBar('Error loading cart: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle Razorpay payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      setState(() {
        _isPlacingOrder = true;
      });

      // Log all response details for debugging
      print('Payment Success:');
      print('Payment ID: ${response.paymentId}');
      print('Order ID: ${response.orderId}');
      print('Signature: ${response.signature}');

      // Add all required payment details to order data
      _tempOrderData['transaction_id'] = response.paymentId;
      _tempOrderData['razorpay_signature'] = response.signature;
      _tempOrderData['razorpay_order_id'] = response.orderId;

      // Log the complete order data
      print('Order data to send:');
      _tempOrderData.forEach((key, value) {
        print('$key: $value');
      });

      // Create the order after successful payment
      final order = await _orderService.createOrder(_tempOrderData);

      if (order != null) {
        // Navigate to success screen
        Navigator.of(context).pushReplacementNamed(
          '/store/order-success',
          arguments: order.id,
        );
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      _showErrorSnackBar('Error creating order: $e');
      setState(() {
        _isPlacingOrder = false;
      });
    }
  }

  Future<void> _initiatePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final totalAmount = _calculateTotalAmount();

      // Store order data for later use after payment
      _tempOrderData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address_line1': _addressLine1Controller.text,
        'address_line2': _addressLine2Controller.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'postal_code': _postalCodeController.text,
        'country': _countryController.text,
        'payment_method': 'Razorpay',
        'shipping': '5.0', // Include shipping cost
      };

      // Use the checkout service to initiate payment
      await _checkoutService.initiatePayment(
        context: context,
        amount: totalAmount,
        customerName: '${_firstNameController.text} ${_lastNameController.text}',
        customerEmail: _emailController.text,
        customerPhone: _phoneController.text,
      );
    } catch (e) {
      _showErrorSnackBar('Payment initialization failed: $e');
      setState(() {
        _isPlacingOrder = false;
      });
    }
  }
  // Handle Razorpay payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    _showErrorSnackBar('Payment failed: ${response.message ?? "Unknown error"}');
    setState(() {
      _isPlacingOrder = false;
    });
  }

  // Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet selected: ${response.walletName}')),
    );
  }


  // Place order directly (for non-Razorpay methods)
  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPlacingOrder = true;
    });

    final orderData = {
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'address_line1': _addressLine1Controller.text,
      'address_line2': _addressLine2Controller.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'postal_code': _postalCodeController.text,
      'country': _countryController.text,
      'payment_method': _paymentMethod,
    };

    try {
      final order = await _orderService.createOrder(orderData);

      if (order != null) {
        Navigator.of(context).pushReplacementNamed(
          '/store/order-success',
          arguments: order.id,
        );
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      _showErrorSnackBar('Error placing order: $e');
      setState(() {
        _isPlacingOrder = false;
      });
    }
  }

  // Calculate the total amount for payment
  double _calculateTotalAmount() {
    if (_cart == null) return 0.0;

    final subtotal = _cart!.total;
    const shipping = 5.0;
    final tax = subtotal * 0.05;
    return subtotal + shipping + tax;
  }

  // Notification Methods
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Build Methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cart == null || _cart!.items.isEmpty
          ? _buildEmptyCartView()
          : _buildCheckoutForm(),
    );
  }

  Widget _buildEmptyCartView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/store'),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Shipping Information'),
            _buildPersonalInfoFields(),
            _buildAddressFields(),
            const SizedBox(height: 24),
            _buildSectionTitle('Payment Method'),
            _buildPaymentMethodSelection(),
            const SizedBox(height: 24),
            _buildSectionTitle('Order Summary'),
            _buildOrderSummary(),
            const SizedBox(height: 24),
            _buildPlaceOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPersonalInfoFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _firstNameController,
                label: 'First Name',
                validator: (value) =>
                value == null || value.isEmpty
                    ? 'Please enter first name'
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _lastNameController,
                label: 'Last Name',
                validator: (value) =>
                value == null || value.isEmpty
                    ? 'Please enter last name'
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email';
            }
            // Basic email validation
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            return !emailRegex.hasMatch(value)
                ? 'Enter a valid email'
                : null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          keyboardType: TextInputType.phone,
          validator: (value) =>
          value == null || value.isEmpty
              ? 'Please enter phone number'
              : null,
        ),
      ],
    );
  }

  Widget _buildAddressFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressLine1Controller,
          label: 'Address Line 1',
          validator: (value) =>
          value == null || value.isEmpty
              ? 'Please enter address'
              : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressLine2Controller,
          label: 'Address Line 2 (Optional)',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cityController,
                label: 'City',
                validator: (value) =>
                value == null || value.isEmpty
                    ? 'Please enter city'
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _stateController,
                label: 'State/Province',
                validator: (value) =>
                value == null || value.isEmpty
                    ? 'Please enter state'
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _postalCodeController,
                label: 'Postal Code',
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty
                    ? 'Please enter postal code'
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _countryController,
                label: 'Country',
                validator: (value) =>
                value == null || value.isEmpty
                    ? 'Please enter country'
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      children: [
        _buildPaymentMethodTile(
          title: 'Razorpay',
          icon: Icons.payment,
          value: 'Razorpay',
        ),
        _buildPaymentMethodTile(
          title: 'Bank Transfer',
          icon: Icons.account_balance,
          value: 'Bank Transfer',
        ),
        _buildPaymentMethodTile(
          title: 'Cash on Delivery',
          icon: Icons.money,
          value: 'Cash on Delivery',
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile({
    required String title,
    required IconData icon,
    required String value,
  }) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      value: value,
      groupValue: _paymentMethod,
      onChanged: (selectedValue) {
        setState(() {
          _paymentMethod = selectedValue!;
        });
      },
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Cart Items List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cart!.items.length,
          itemBuilder: (context, index) {
            final item = _cart!.items[index];
            return _buildOrderSummaryItem(item);
          },
        ),
        const Divider(thickness: 1),

        // Cost Breakdown
        _buildCostBreakdownRow('Subtotal', '₹ {_cart!.total.toStringAsFixed(2)}'),
        _buildCostBreakdownRow('Shipping', '₹5.00'),
        _buildCostBreakdownRow('Tax (5%)', '₹${(_cart!.total * 0.05).toStringAsFixed(2)}'),

        const Divider(thickness: 1),

        // Total
        _buildTotalRow(),
      ],
    );
  }

  Widget _buildOrderSummaryItem(CartItem item) {
    return ListTile(
      leading: _buildProductImage(item),
      title: Text(item.product.name),
      subtitle: Text(
          '${item.quantity} x ₹${item.product.price.toStringAsFixed(2)}'
      ),
      trailing: Text(
        '₹${item.subtotal.toStringAsFixed(2)}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProductImage(CartItem item) {
    return item.product.images.isNotEmpty
        ? CachedNetworkImage(
      imageUrl: '${ApiEndpoints.baseUrl}${item.product.images.first}',
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
      const CircularProgressIndicator(),
      errorWidget: (context, url, error) =>
      const Icon(Icons.error),
    )
        : Container(
      width: 50,
      height: 50,
      color: Colors.grey[300],
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildCostBreakdownRow(String title, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    final total = _cart!.total + 5.0 + (_cart!.total * 0.05);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '₹${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPlacingOrder
            ? null
            : (_paymentMethod == 'Razorpay'
            ? _initiatePayment
            : _placeOrder),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: _paymentMethod == 'Razorpay'
              ? Colors.purple
              : Theme.of(context).primaryColor,
        ),
        child: _isPlacingOrder
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          _paymentMethod == 'Razorpay'
              ? 'Pay with Razorpay'
              : 'Place Order',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}