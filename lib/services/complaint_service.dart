import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:ispmanagement/models/complaint_model.dart';
import '../config/api_endpoints.dart';

import '../services/api_service.dart';

class ComplaintService {
  final ApiService _apiService = ApiService();

  // Get all complaints for the current user
  Future<List<Complaint>> getComplaints() async {
    try {
      final response = await _apiService.get(ApiEndpoints.complaints);

      if (response != null) {
        // Check if the response is paginated (has a 'results' key)
        if (response is Map && response.containsKey('results')) {
          final List<Complaint> complaints = (response['results'] as List)
              .map((item) => Complaint.fromJson(item))
              .toList();
          return complaints;
        }
        // If it's a direct list
        else if (response is List) {
          final List<Complaint> complaints = response
              .map((item) => Complaint.fromJson(item))
              .toList();
          return complaints;
        }
      }

      return [];
    } catch (e) {
      log('Error getting complaints: $e');
      rethrow;
    }
  }

  // Get a specific complaint by ID
  Future<Complaint?> getComplaint(int id) async {
    try {
      final response = await _apiService.get('${ApiEndpoints.complaints}$id/');

      if (response != null) {
        return Complaint.fromJson(response);
      }

      return null;
    } catch (e) {
      log('Error getting complaint: $e');
      rethrow;
    }
  }

  // Create a new complaint
  Future<Complaint?> createComplaint(Complaint complaint) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.complaints,
        data: complaint.toJson(),
      );

      if (response != null) {
        return Complaint.fromJson(response);
      }

      return null;
    } catch (e) {
      log('Error creating complaint: $e');
      rethrow;
    }
  }

  // Add a comment to a complaint
  Future<ComplaintComment?> addComplaintComment(ComplaintComment comment) async {
    try {
      // Ensure the complaint ID is not null
      if (comment.complaintId == null) {
        throw ArgumentError('Complaint ID is required to add a comment');
      }

      // Construct the correct URL
      final url = ApiEndpoints.getUrlWithPathParam(
          ApiEndpoints.complaintComments,
          'id',
          comment.complaintId.toString()
      );

      final response = await _apiService.post(
        url,
        data: {
          'comment': comment.comment,
        },
      );

      if (response != null) {
        return ComplaintComment.fromJson(response);
      }

      return null;
    } catch (e) {
      log('Error adding complaint comment: $e');
      rethrow;
    }
  }

  // Update complaint status (for user-allowed statuses)
  Future<Complaint?> updateComplaintStatus(int complaintId, {
    String? status,
    String? priority,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (status != null) data['status'] = status;
      if (priority != null) data['priority'] = priority;

      final response = await _apiService.patch(
        '${ApiEndpoints.complaints}$complaintId/',
        data: data,
      );

      if (response != null) {
        return Complaint.fromJson(response);
      }

      return null;
    } catch (e) {
      log('Error updating complaint status: $e');
      rethrow;
    }
  }
}