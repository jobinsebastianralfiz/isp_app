import 'package:flutter/foundation.dart';
import '../models/complaint_model.dart';

import '../services/complaint_service.dart';

class ComplaintProvider with ChangeNotifier {
  final ComplaintService _complaintService = ComplaintService();

  List<Complaint> _complaints = [];
  Complaint? _selectedComplaint;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Complaint> get complaints => _complaints;
  Complaint? get selectedComplaint => _selectedComplaint;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all complaints
  Future<void> fetchComplaints() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _complaints = await _complaintService.getComplaints();
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // Fetch a specific complaint by ID
  Future<void> fetchComplaint(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedComplaint = await _complaintService.getComplaint(id);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // Create a new complaint
  Future<Complaint?> createComplaint(Complaint complaint) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newComplaint = await _complaintService.createComplaint(complaint);
      if (newComplaint != null) {
        _complaints.insert(0, newComplaint);
        _selectedComplaint = newComplaint;
      }
      _isLoading = false;
      notifyListeners();
      return newComplaint;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Add a comment to a complaint
  Future<ComplaintComment?> addComplaintComment(ComplaintComment comment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newComment = await _complaintService.addComplaintComment(comment);
      if (newComment != null && _selectedComplaint != null) {
        // Update the selected complaint's comments
        _selectedComplaint!.comments ??= [];
        _selectedComplaint!.comments!.add(newComment);
      }
      _isLoading = false;
      notifyListeners();
      return newComment;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Update complaint status
  Future<void> updateComplaintStatus(int complaintId, {
    String? status,
    String? priority,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedComplaint = await _complaintService.updateComplaintStatus(
        complaintId,
        status: status,
        priority: priority,
      );

      if (updatedComplaint != null) {
        // Update the complaint in the list
        final index = _complaints.indexWhere((c) => c.id == complaintId);
        if (index != -1) {
          _complaints[index] = updatedComplaint;
        }

        // Update the selected complaint if it's the same
        if (_selectedComplaint?.id == complaintId) {
          _selectedComplaint = updatedComplaint;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}