import 'package:flutter/material.dart';
import 'package:ispmanagement/models/complaint_model.dart';
import 'package:ispmanagement/providers/complaint_provider.dart';
import 'package:provider/provider.dart';



class CreateComplaintScreen extends StatefulWidget {
  const CreateComplaintScreen({Key? key}) : super(key: key);

  @override
  _CreateComplaintScreenState createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Use a more descriptive list with user-friendly labels
  final List<Map<String, String>> _complaintTypes = [
    {'value': 'technical', 'label': 'Technical Issue'},
    {'value': 'billing', 'label': 'Billing Concern'},
    {'value': 'service', 'label': 'Service Request'},
    {'value': 'other', 'label': 'Other'}
  ];

  // Initialize with the first type
  late String _selectedComplaintType;

  @override
  void initState() {
    super.initState();
    // Set initial value to first complaint type
    _selectedComplaintType = _complaintTypes.first['value']!;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitComplaint() async {
    // Unfocus any active text fields to dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // Create a new Complaint object
      final complaint = Complaint(
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        complaintType: _selectedComplaintType,
      );

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Attempt to create complaint
      final complaintProvider = Provider.of<ComplaintProvider>(
        context,
        listen: false,
      );

      final createdComplaint = await complaintProvider.createComplaint(complaint);

      // Remove loading dialog
      Navigator.of(context).pop();

      if (createdComplaint != null) {
        // Show success dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Complaint Submitted'),
            content: const Text('Your complaint has been successfully created.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        // Pop back to complaints list
        Navigator.of(context).pop();
      } else {
        // Show error dialog with more detailed error message
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Submission Failed'),
            content: Text(
              complaintProvider.errorMessage ??
                  'Unable to submit complaint. Please check your connection and try again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Complaint'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a subject';
                  }
                  if (value.trim().length < 5) {
                    return 'Subject must be at least 5 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Complaint Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                value: _selectedComplaintType,
                items: _complaintTypes.map((type) {
                  return DropdownMenuItem(
                    value: type['value'],
                    child: Text(type['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedComplaintType = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a complaint type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitComplaint,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Submit Complaint',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}