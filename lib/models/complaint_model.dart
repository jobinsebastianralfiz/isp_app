import 'package:flutter/foundation.dart';

class Complaint {
  final int? id;
  final String? complaintNumber;
  final String subject;
  final String description;
  final String complaintType;
  final String status;
  final String priority;
  final int? connectionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  List<ComplaintComment>? comments;

  // Static list of valid complaint types
  static const List<String> validComplaintTypes = [
    'technical',
    'billing',
    'service',
    'other'
  ];

  // Static list of valid statuses
  static const List<String> validStatuses = [
    'pending',
    'in_progress',
    'resolved',
    'closed'
  ];

  // Static list of valid priorities
  static const List<String> validPriorities = [
    'low',
    'medium',
    'high',
    'critical'
  ];

  // Static validation methods
  static String validateComplaintType(String type) {
    return validComplaintTypes.contains(type)
        ? type
        : 'other';
  }

  static String validateStatus(String status) {
    return validStatuses.contains(status)
        ? status
        : 'pending';
  }

  static String validatePriority(String priority) {
    return validPriorities.contains(priority)
        ? priority
        : 'medium';
  }

  // Complaint constructor with validation
  Complaint({
    this.id,
    this.complaintNumber,
    required this.subject,
    required this.description,
    required String complaintType,
    String? status,
    String? priority,
    this.connectionId,
    this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.comments,
  }) :
        complaintType = validateComplaintType(complaintType),
        status = validateStatus(status ?? 'pending'),
        priority = validatePriority(priority ?? 'medium') {
    // Additional validation
    _validateSubject();
    _validateDescription();
  }

  // Subject validation
  void _validateSubject() {
    if (subject.trim().isEmpty) {
      throw ArgumentError('Subject cannot be empty');
    }
    if (subject.length < 5) {
      throw ArgumentError('Subject must be at least 5 characters long');
    }
  }

  // Description validation
  void _validateDescription() {
    if (description.trim().isEmpty) {
      throw ArgumentError('Description cannot be empty');
    }
    if (description.length < 10) {
      throw ArgumentError('Description must be at least 10 characters long');
    }
  }

  // FromJson factory method with robust parsing
  factory Complaint.fromJson(Map<String, dynamic> json) {
    // Handle comments parsing
    List<ComplaintComment> comments = [];
    if (json['comments'] != null) {
      comments = (json['comments'] as List)
          .map((item) => ComplaintComment.fromJson(item))
          .toList();
    }

    return Complaint(
      id: json['id'],
      complaintNumber: json['complaint_number'],
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      complaintType: validateComplaintType(json['complaint_type'] ?? 'other'),
      status: validateStatus(json['status'] ?? 'pending'),
      priority: validatePriority(json['priority'] ?? 'medium'),
      connectionId: json['connection'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.tryParse(json['resolved_at'])
          : null,
      comments: comments,
    );
  }

  // ToJson method with comprehensive data mapping
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'subject': subject,
      'description': description,
      'complaint_type': complaintType,
      'status': status,
      'priority': priority,
    };

    // Optional fields
    if (connectionId != null) {
      data['connection'] = connectionId;
    }

    return data;
  }

  // Equality and hashCode for comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Complaint &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              subject == other.subject &&
              description == other.description;

  @override
  int get hashCode =>
      id.hashCode ^ subject.hashCode ^ description.hashCode;

  // Clone method for creating copies with optional modifications
  Complaint copyWith({
    int? id,
    String? complaintNumber,
    String? subject,
    String? description,
    String? complaintType,
    String? status,
    String? priority,
    int? connectionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    List<ComplaintComment>? comments,
  }) {
    return Complaint(
      id: id ?? this.id,
      complaintNumber: complaintNumber ?? this.complaintNumber,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      complaintType: complaintType ?? this.complaintType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      connectionId: connectionId ?? this.connectionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      comments: comments ?? this.comments,
    );
  }

  // ToString for debugging
  @override
  String toString() {
    return 'Complaint(id: $id, subject: $subject, type: $complaintType, status: $status)';
  }
}

class ComplaintComment {
  final int? id;
  final int? complaintId;
  final String comment;
  final bool isStaffComment;
  final DateTime? createdAt;
  final Map<String, dynamic>? userDetails;

  ComplaintComment({
    this.id,
    this.complaintId,
    required this.comment,
    this.isStaffComment = false,
    this.createdAt,
    this.userDetails,
  }) {
    _validateComment();
  }

  // Comment validation
  void _validateComment() {
    if (comment.trim().isEmpty) {
      throw ArgumentError('Comment cannot be empty');
    }
    if (comment.length < 3) {
      throw ArgumentError('Comment must be at least 3 characters long');
    }
  }

  factory ComplaintComment.fromJson(Map<String, dynamic> json) {
    return ComplaintComment(
      id: json['id'],
      complaintId: json['complaint'],
      comment: json['comment'] ?? '',
      isStaffComment: json['is_staff_comment'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      userDetails: json['user_details'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'complaint': complaintId,
      'comment': comment,
    };

    return data;
  }

  // Equality and hashCode
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ComplaintComment &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              comment == other.comment;

  @override
  int get hashCode => id.hashCode ^ comment.hashCode;

  // ToString for debugging
  @override
  String toString() {
    return 'ComplaintComment(id: $id, comment: $comment)';
  }
}