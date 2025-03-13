// Create this as a new file: lib/models/active_connection_model.dart

import 'package:ispmanagement/models/connection_models.dart';
import 'package:ispmanagement/models/pacakge_models.dart';

class ActiveConnection {
  final int? id;
  final String user;
  final ConnectionApplication connectionApplication;
  final int packageId;
  final Package? package;
  final DateTime? installationDate;
  final DateTime? connectionStartDate;
  final DateTime? nextBillingDate;
  final String status;
  final String ipAddress;
  final String macAddress;
  final String? notes;

  ActiveConnection({
    this.id,
    required this.user,
    required this.connectionApplication,
    required this.packageId,
    this.package,
    this.installationDate,
    this.connectionStartDate,
    this.nextBillingDate,
    required this.status,
    required this.ipAddress,
    required this.macAddress,
    this.notes,
  });

  factory ActiveConnection.fromJson(Map<String, dynamic> json) {
    // Parse the nested connection application
    final connectionApp = ConnectionApplication.fromJson(json['connection_application']);

    // Parse package details if available
    Package? packageObj;
    if (json['package_details'] != null) {
      packageObj = Package.fromJson(json['package_details']);
    }

    return ActiveConnection(
      id: json['id'],
      user: json['user'] ?? '',
      connectionApplication: connectionApp,
      packageId: json['package'] ?? 0,
      package: packageObj,
      installationDate: json['installation_date'] != null
          ? DateTime.parse(json['installation_date'])
          : null,
      connectionStartDate: json['connection_start_date'] != null
          ? DateTime.parse(json['connection_start_date'])
          : null,
      nextBillingDate: json['next_billing_date'] != null
          ? DateTime.parse(json['next_billing_date'])
          : null,
      status: json['status'] ?? 'unknown',
      ipAddress: json['ip_address'] ?? '',
      macAddress: json['mac_address'] ?? '',
      notes: json['notes'],
    );
  }

  // Convert to ConnectionApplication for UI usage
  ConnectionApplication toConnectionApplication() {
    return ConnectionApplication(
      id: connectionApplication.id,
      status: connectionApplication.status,
      fullName: connectionApplication.fullName,
      email: connectionApplication.email,
      phone: connectionApplication.phone,
      address: connectionApplication.address,
      packageId: packageId,
      packageName: connectionApplication.packageName,
      createdAt: connectionApplication.createdAt,
      updatedAt: connectionApplication.updatedAt,
      notes: connectionApplication.notes,
      installationDate: installationDate ?? connectionApplication.installationDate,
      installationCompletedDate: connectionApplication.installationCompletedDate,
      documents: connectionApplication.documents,
      connectionNumber: connectionApplication.connectionNumber ?? id?.toString(),
      package: package ?? connectionApplication.package,
    );
  }
}