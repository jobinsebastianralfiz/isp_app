// Create a new file: document_upload_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/app_constants.dart';
import '../../models/connection_models.dart';
import '../../providers/connection_provider.dart';
import '../../utils/ui_helpers.dart';

class DocumentUploadScreen extends StatefulWidget {
  final ConnectionApplication application;

  const DocumentUploadScreen({Key? key, required this.application}) : super(key: key);

  @override
  _DocumentUploadScreenState createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final Map<String, File?> _selectedFiles = {
    'id_proof': null,
    'address_proof': null,
    'photo': null,
  };

  @override
  Widget build(BuildContext context) {
    final connectionProvider = Provider.of<ConnectionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Documents'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Required Documents',
                  style: AppConstants.subheadingStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please upload the following documents to proceed with your application verification.',
                  style: AppConstants.bodyStyle,
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDocumentUploadTile(
                  title: 'ID Proof',
                  description: 'Aadhar Card, Passport, Voter ID, etc.',
                  documentType: 'id_proof',
                  isUploading: connectionProvider.documentUploadResponse.isLoading,
                ),
                const SizedBox(height: 16),
                _buildDocumentUploadTile(
                  title: 'Address Proof',
                  description: 'Utility Bill, Rent Agreement, etc.',
                  documentType: 'address_proof',
                  isUploading: connectionProvider.documentUploadResponse.isLoading,
                ),
                const SizedBox(height: 16),
                _buildDocumentUploadTile(
                  title: 'Photograph',
                  description: 'Recent passport size photograph',
                  documentType: 'photo',
                  isUploading: connectionProvider.documentUploadResponse.isLoading,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _areAllDocumentsUploaded()
                  ? () => _finishDocumentUpload()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Finish'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadTile({
    required String title,
    required String description,
    required String documentType,
    required bool isUploading,
  }) {
    File? selectedFile = _selectedFiles[documentType];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: AppConstants.lightTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            if (selectedFile != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(selectedFile),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedFiles[documentType] = null;
                      });
                    },
                  ),
                ],
              )
            else
              GestureDetector(
                onTap: () => _pickImage(documentType),
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 40,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(height: 8),
                      const Text('Tap to upload'),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            if (selectedFile != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      selectedFile.path.split('/').last,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isUploading
                        ? null
                        : () => _uploadDocument(documentType, selectedFile),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                    ),
                    child: isUploading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Upload'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(String documentType) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedFiles[documentType] = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadDocument(String documentType, File file) async {
    final connectionProvider = Provider.of<ConnectionProvider>(context, listen: false);

    // Check if application id is null
    if (widget.application.id == null) {
      UIHelpers.showSnackBar(
        context,
        message: 'Invalid application ID',
        isError: true,
      );
      return;
    }

    try {
      await connectionProvider.uploadDocument(
        widget.application.id!, // Use non-null assertion operator since you've verified it's not null
        file,
        documentType,
      );

      if (connectionProvider.documentUploadResponse.isError) {
        UIHelpers.showSnackBar(
          context,
          message: connectionProvider.documentUploadResponse.message ?? 'Failed to upload document',
          isError: true,
        );
      } else {
        UIHelpers.showSnackBar(
          context,
          message: 'Document uploaded successfully',
        );
      }
    } catch (e) {
      UIHelpers.showSnackBar(
        context,
        message: 'Failed to upload document: $e',
        isError: true,
      );
    }
  }

  bool _areAllDocumentsUploaded() {
    // Check if all documents have been uploaded
    final connectionProvider = Provider.of<ConnectionProvider>(context, listen: false);
    if (connectionProvider.application == null) return false;

    // Get all uploaded documents for this application
    final documents = connectionProvider.application!.documents ?? [];

    // Check if we have at least one document of each type
    bool hasIdProof = documents.any((doc) => doc.documentType == 'id_proof');
    bool hasAddressProof = documents.any((doc) => doc.documentType == 'address_proof');
    bool hasPhoto = documents.any((doc) => doc.documentType == 'photo');

    return hasIdProof && hasAddressProof && hasPhoto;
  }

  void _finishDocumentUpload() {
    // Navigate back to the home screen or connection status screen
    Navigator.of(context).popUntil((route) => route.isFirst);

    // Show success message
    UIHelpers.showSnackBar(
      context,
      message: 'All documents uploaded successfully! Your application is under review.',
    );
  }
}