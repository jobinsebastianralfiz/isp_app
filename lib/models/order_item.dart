import 'package:ispmanagement/models/product_model.dart';

class Order {
  final int id;
  final String orderNumber;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String status;
  final String statusDisplay;  // Add this field
  final String paymentStatus;
  final String paymentStatusDisplay;  // Add this field
  final String paymentMethod;
  final String? transactionId;
  final String? trackingNumber;
  final String? shippingCarrier;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.status,
    required this.statusDisplay,  // Add this parameter
    required this.paymentStatus,
    required this.paymentStatusDisplay,  // Add this parameter
    required this.paymentMethod,
    this.transactionId,
    this.trackingNumber,
    this.shippingCarrier,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final List<OrderItem> orderItems = [];

    if (json['items'] != null && json['items'] is List) {
      for (var item in json['items']) {
        orderItems.add(OrderItem.fromJson(item));
      }
    }

    // Helper function to parse double values safely
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          return 0.0;
        }
      }
      return 0.0;
    }

    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? 'Pending',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      addressLine1: json['address_line1'] ?? '',
      addressLine2: json['address_line2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postal_code'] ?? '',
      country: json['country'] ?? '',
      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentStatusDisplay: json['payment_status_display'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      transactionId: json['transaction_id'],
      trackingNumber: json['tracking_number'],
      shippingCarrier: json['shipping_carrier'],
      subtotal: parseDouble(json['subtotal']),
      shipping: parseDouble(json['shipping']),
      tax: parseDouble(json['tax']),
      total: parseDouble(json['total']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      items: orderItems,
    );
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final Product product;
  final int quantity;
  final double price;
  final double subtotal;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.product,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Helper function to parse double values safely
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          return 0.0;
        }
      }
      return 0.0;
    }

    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['order'] ?? 0,
      product: json['product_details'] != null
          ? Product.fromJson(json['product_details'])
          : (json['product'] is Map
          ? Product.fromJson(json['product'])
          : Product.empty()), // Handle case where product might be just an ID
      quantity: json['quantity'] ?? 0,
      price: parseDouble(json['price']),
      subtotal: parseDouble(json['subtotal']),
    );
  }
}