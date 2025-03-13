// Remove Package class and import it from package_models.dart


 // Import the Package model

import 'package:ispmanagement/models/pacakge_models.dart';

class ConnectionApplication {
  final int? id;
  final String status;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final int packageId;
  final String? packageName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final DateTime? installationDate;
  final DateTime? installationCompletedDate;
  final List<ApplicationDocument>? documents;
  final String? connectionNumber;  // Add this field
  final Package? package;  // Add this field

  ConnectionApplication({
    this.id,
    required this.status,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.packageId,
    this.packageName,
    this.createdAt,
    this.updatedAt,
    this.notes,
    this.installationDate,
    this.installationCompletedDate,
    this.documents,
    this.connectionNumber,
    this.package,
  });

  factory ConnectionApplication.fromJson(Map<String, dynamic> json) {
    List<ApplicationDocument> docs = [];
    if (json['documents'] != null) {
      docs = (json['documents'] as List)
          .map((doc) => ApplicationDocument.fromJson(doc))
          .toList();
    }

    // Create a Package object if package_details exists
    Package? packageObj;
    if (json['package_details'] != null) {
      packageObj = Package.fromJson(json['package_details']);
    }

    return ConnectionApplication(
      id: json['id'],
      status: json['status'],
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      packageId: json['package'],
      packageName: json['package_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      notes: json['notes'],
      installationDate: json['installation_date'] != null
          ? DateTime.parse(json['installation_date'])
          : null,
      installationCompletedDate: json['installation_completed_date'] != null
          ? DateTime.parse(json['installation_completed_date'])
          : null,
      documents: docs,
      connectionNumber: json['connection_number'],
      package: packageObj,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    // Only include id if it exists (for updates)
    if (id != null) {
      data['id'] = id;
    }

    data['full_name'] = fullName;
    data['email'] = email;
    data['phone'] = phone;
    data['address'] = address;
    data['package'] = packageId;

    return data;
  }
}

class ApplicationDocument {
  final int? id;
  final int? applicationId;
  final String documentType;
  final String filePath;
  final bool? isVerified;
  final DateTime? verificationDate;
  final String? rejectionReason;
  final String? fileUrl;

  ApplicationDocument({
    this.id,
    this.applicationId,
    required this.documentType,
    required this.filePath,
    this.isVerified,
    this.verificationDate,
    this.rejectionReason,
    this.fileUrl,
  });

  factory ApplicationDocument.fromJson(Map<String, dynamic> json) {
    return ApplicationDocument(
      id: json['id'],
      applicationId: json['application'],
      documentType: json['document_type'],
      filePath: json['file'] ?? '',
      isVerified: json['is_verified'],
      verificationDate: json['verification_date'] != null
          ? DateTime.parse(json['verification_date'])
          : null,
      rejectionReason: json['rejection_reason'],
      fileUrl: json['file_url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['document_type'] = documentType;
    data['file'] = filePath;

    return data;
  }
}

class ConnectionApplicationRequest {
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final int packageId;

  ConnectionApplicationRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.packageId,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'package': packageId,
    };
  }
}