// lib/models/billing_models.dart
import 'package:intl/intl.dart';

class MonthlyBilling {
  final int? id;
  final int? activeConnectionId;
  final DateTime? billingPeriodStart;
  final DateTime? billingPeriodEnd;
  final double billAmount;
  final String paymentStatus;
  final DateTime? dueDate;
  final DateTime? paymentDate;
  final String? transactionId;
  final String? paymentGateway;
  final String? notes;
  final Map<String, dynamic>? packageInfo;
  final int? daysUntilNextBilling;

  MonthlyBilling({
    this.id,
    this.activeConnectionId,
    this.billingPeriodStart,
    this.billingPeriodEnd,
    required this.billAmount,
    required this.paymentStatus,
    this.dueDate,
    this.paymentDate,
    this.transactionId,
    this.paymentGateway,
    this.notes,
    this.packageInfo,
    this.daysUntilNextBilling,
  });

  factory MonthlyBilling.fromJson(Map<String, dynamic> json) {
    // Handle nested package information
    Map<String, dynamic>? packageInfo;

    // Try to extract package information from different possible locations
    if (json['package'] != null) {
      // If package is a map
      if (json['package'] is Map) {
        packageInfo = {
          'id': json['package']['id'],
          'name': json['package']['name'] ?? 'N/A',
          'speed': json['package']['speed'] != null
              ? '${json['package']['speed']} ${json['package']['speed_unit'] ?? ''}'
              : 'N/A',
          'features': json['package']['features'] ?? [],
        };
      }
      // If package is a list
      else if (json['package'] is List && json['package'].isNotEmpty) {
        final packageData = json['package'][0];
        packageInfo = {
          'id': packageData['id'],
          'name': packageData['name'] ?? 'N/A',
          'speed': packageData['speed'] != null
              ? '${packageData['speed']} ${packageData['speed_unit'] ?? ''}'
              : 'N/A',
          'features': packageData['features'] ?? [],
        };
      }
    }

    // Fallback to package details from active connection if needed
    if (packageInfo == null && json['active_connection'] is Map) {
      final activeConn = json['active_connection'];
      if (activeConn['package_details'] != null) {
        packageInfo = {
          'id': activeConn['package_details']['id'],
          'name': activeConn['package_details']['name'] ?? 'N/A',
          'speed': activeConn['package_details']['speed'] != null
              ? '${activeConn['package_details']['speed']} ${activeConn['package_details']['speed_unit'] ?? ''}'
              : 'N/A',
          'features': activeConn['package_details']['features'] ?? [],
        };
      }
    }

    return MonthlyBilling(
      id: json['id'],
      activeConnectionId: json['active_connection'] is Map
          ? json['active_connection']['id']
          : json['active_connection'],
      billingPeriodStart: json['billing_period_start'] != null
          ? DateTime.parse(json['billing_period_start'])
          : null,
      billingPeriodEnd: json['billing_period_end'] != null
          ? DateTime.parse(json['billing_period_end'])
          : null,
      billAmount: json['bill_amount'] != null
          ? double.parse(json['bill_amount'].toString())
          : 0.0,
      paymentStatus: json['payment_status'] ?? 'pending',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
      transactionId: json['transaction_id'],
      paymentGateway: json['payment_gateway'],
      notes: json['notes'],
      packageInfo: packageInfo,
      daysUntilNextBilling: _parseDaysUntilNextBilling(json['days_until_next_billing']),
    );
  }

// Helper method to parse days until next billing
  static int? _parseDaysUntilNextBilling(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    try {
      return int.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  // Helper methods
  String get formattedBillAmount {
    return '₹${billAmount.toStringAsFixed(2)}';
  }

  String get billingPeriod {
    if (billingPeriodStart == null || billingPeriodEnd == null) {
      return 'N/A';
    }

    final formatter = DateFormat('dd MMM yyyy');
    return '${formatter.format(billingPeriodStart!)} - ${formatter.format(billingPeriodEnd!)}';
  }

  String get formattedDueDate {
    if (dueDate == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(dueDate!);
  }

  String get statusColor {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        return '#4CAF50';  // Green
      case 'pending':
        return '#FFC107';  // Yellow
      case 'overdue':
        return '#F44336';  // Red
      default:
        return '#9E9E9E';  // Grey
    }
  }

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';
  bool get isPending => paymentStatus.toLowerCase() == 'pending';
  bool get isOverdue => paymentStatus.toLowerCase() == 'overdue';
}