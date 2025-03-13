import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../config/api_endpoints.dart';
import '../../models/order_item.dart';
import '../../providers/store_provider.dart';
import '../../utils/ui_helpers.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isLoading = true;
  Order? _order;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() => _isLoading = true);

    try {
      final orderDetails = await Provider.of<StoreProvider>(context, listen: false)
          .fetchOrderDetails(widget.orderId);

      setState(() {
        _order = orderDetails;
      });
    } catch (e) {
      UIHelpers.showToast(message: 'Error loading order details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelOrder() async {
    try {
      await Provider.of<StoreProvider>(context, listen: false)
          .cancelOrder(widget.orderId);

      // Reload order details to reflect the cancelled status
      await _loadOrderDetails();

      UIHelpers.showToast(message: 'Order cancelled successfully');
    } catch (e) {
      UIHelpers.showToast(message: 'Failed to cancel order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_order != null ? 'Order #${_order!.orderNumber}' : 'Order Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Order not found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      )
          : _buildOrderDetails(),
    );
  }

  Widget _buildOrderDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderStatusCard(),
          const SizedBox(height: 20),
          _buildOrderItemsCard(),
          const SizedBox(height: 20),
          _buildPriceBreakdownCard(),
          const SizedBox(height: 20),
          _buildShippingDetailsCard(),
          const SizedBox(height: 20),
          _buildPaymentDetailsCard(),

          // Only show cancel button for orders that are pending or processing
          if (_order!.status.toLowerCase() == 'pending' ||
              _order!.status.toLowerCase() == 'processing')
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cancelOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Cancel Order',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusBadge(_order!.status),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Order Number',
              _order!.orderNumber,
            ),
            _buildInfoRow(
              'Order Date',
              DateFormat('MMM dd, yyyy, hh:mm a').format(_order!.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              _order!.items.length,
                  (index) => _buildOrderItemTile(_order!.items[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemTile(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.product.images.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: '${ApiEndpoints.baseUrl}${item.product.images.first}',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 70,
                height: 70,
                color: Colors.grey[200],
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 70,
                height: 70,
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
            )
                : Container(
              width: 70,
              height: 70,
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported),
            ),
          ),
          const SizedBox(width: 12),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${item.quantity}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Price: ₹${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Subtotal
          Text(
            '₹${item.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPriceRow('Subtotal', _order!.subtotal),
            _buildPriceRow('Shipping', _order!.shipping),
            _buildPriceRow('Tax', _order!.tax),
            const Divider(height: 24),
            _buildPriceRow(
              'Total',
              _order!.total,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${_order!.firstName} ${_order!.lastName}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(_order!.addressLine1),
            if (_order!.addressLine2.isNotEmpty) Text(_order!.addressLine2),
            Text('${_order!.city}, ${_order!.state} ${_order!.postalCode}'),
            Text(_order!.country),
            const SizedBox(height: 8),
            Text('Phone: ${_order!.phone}'),
            Text('Email: ${_order!.email}'),

            if (_order!.status.toLowerCase() == 'shipped' ||
                _order!.status.toLowerCase() == 'delivered') ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Tracking Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_order!.trackingNumber?.isNotEmpty ?? false)
                _buildInfoRow('Tracking Number', _order!.trackingNumber!),
              if (_order!.shippingCarrier?.isNotEmpty ?? false)
                _buildInfoRow('Shipping Carrier', _order!.shippingCarrier!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Payment Method',
              _order!.paymentMethod,
            ),
            _buildInfoRow(
              'Payment Status',
              _order!.paymentStatus.capitalize(),
            ),
            if (_order!.transactionId?.isNotEmpty ?? false)
              _buildInfoRow(
                'Transaction ID',
                _order!.transactionId!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.black : Colors.grey[600],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'processing':
        color = Colors.blue;
        text = 'Processing';
        break;
      case 'shipped':
        color = Colors.indigo;
        text = 'Shipped';
        break;
      case 'delivered':
        color = Colors.green;
        text = 'Delivered';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}

// Extension to capitalize first letter of string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}