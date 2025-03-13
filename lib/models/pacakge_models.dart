// This file contains all the package-related models for the application
// It combines the functionality of both previous Package implementations

class Package {
  final int id;
  final String name;
  final String description;
  final double price;
  final dynamic speed;  // Changed to dynamic to handle both int and string
  final String? speedUnit;  // Added speed unit
  final List<String> features;
  final String validity;
  final String status;
  final String? image;
  final int durationDays;
  final bool? isPopular;  // Added is_popular field
  final Map<String, dynamic>? provider;  // Added provider field
  final String? formattedPrice;  // Added formatted_price field

  Package({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.speed,
    this.speedUnit,
    required this.features,
    required this.validity,
    this.status = 'active',
    this.image,
    this.durationDays = 30,
    this.isPopular,
    this.provider,
    this.formattedPrice,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    // Handle features which could be a list or a string
    List<String> featuresList = [];
    if (json['features'] != null) {
      if (json['features'] is List) {
        featuresList = List<String>.from(json['features']);
      } else if (json['features'] is String) {
        featuresList = (json['features'] as String).split(',').map((e) => e.trim()).toList();
      }
    }

    return Package(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] is int)
          ? json['price'].toDouble()
          : double.parse(json['price'].toString()),
      speed: json['speed'], // Now accepts any type
      speedUnit: json['speed_unit'],
      features: featuresList,
      validity: json['validity'] ?? '30 days',
      status: json['status'] ?? 'active',
      image: json['image'],
      durationDays: json['duration_days'] ?? 30,
      isPopular: json['is_popular'],
      provider: json['provider'],
      formattedPrice: json['formatted_price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'speed': speed,
      'speed_unit': speedUnit,
      'features': features,
      'validity': validity,
      'status': status,
      'image': image,
      'duration_days': durationDays,
      'is_popular': isPopular,
      'provider': provider,
      'formatted_price': formattedPrice,
    };
  }

  // Helper getter to format speed display
  String get speedDisplay {
    if (speed == null) return '';
    if (speedUnit != null) {
      return '$speed $speedUnit';
    }
    return speed.toString();
  }
}

class UserPackage {
  final int id;
  final int userId;
  final int packageId;
  final String packageName;
  final double purchasePrice;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String paymentStatus;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;

  UserPackage({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.packageName,
    required this.purchasePrice,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.paymentStatus,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
  });

  factory UserPackage.fromJson(Map<String, dynamic> json) {
    return UserPackage(
      id: json['id'],
      userId: json['user'] is int ? json['user'] : int.parse(json['user'].toString()),
      packageId: json['package'] is int ? json['package'] : int.parse(json['package'].toString()),
      packageName: json['package_name'] ?? 'Unknown Package',
      purchasePrice: json['purchase_price'] is int
          ? json['purchase_price'].toDouble()
          : double.parse(json['purchase_price'].toString()),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'],
      paymentStatus: json['payment_status'],
      razorpayOrderId: json['razorpay_order_id'],
      razorpayPaymentId: json['razorpay_payment_id'],
      razorpaySignature: json['razorpay_signature'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'package': packageId,
      'package_name': packageName,
      'purchase_price': purchasePrice,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'payment_status': paymentStatus,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
    };
  }

  bool get isActive => status == 'active';
  bool get isExpired => endDate.isBefore(DateTime.now());
  bool get isPaid => paymentStatus == 'completed';

  // Calculate days remaining until expiration
  int get daysRemaining {
    if (isExpired) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }
}

class SubscriptionRequest {
  final String paymentId;
  final String orderId;
  final String signature;

  SubscriptionRequest({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'order_id': orderId,
      'signature': signature,
    };
  }
}