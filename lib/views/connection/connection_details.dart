import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../config/app_constants.dart';
import '../../models/connection_models.dart';
import '../../providers/connection_provider.dart';
import '../../utils/ui_helpers.dart';

class ConnectionDetailsScreen extends StatefulWidget {
  final int applicationId;

  const ConnectionDetailsScreen({
    Key? key,
    required this.applicationId,
  }) : super(key: key);

  @override
  _ConnectionDetailsScreenState createState() => _ConnectionDetailsScreenState();
}

class _ConnectionDetailsScreenState extends State<ConnectionDetailsScreen> {
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadConnectionDetails();
  }

  Future<void> _loadConnectionDetails() async {
    final connectionProvider = Provider.of<ConnectionProvider>(context, listen: false);
    await connectionProvider.getConnectionApplication(widget.applicationId);
  }

  @override
  Widget build(BuildContext context) {
    final connectionProvider = Provider.of<ConnectionProvider>(context);
    final application = connectionProvider.application;
    final bool isLoading = connectionProvider.applicationResponse.isLoading;
    final bool hasError = connectionProvider.applicationResponse.isError;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Details'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? _buildErrorView(connectionProvider.applicationResponse.message ?? 'Failed to load application details')
          : application == null
          ? _buildEmptyView()
          : _buildDetailsView(application),
      floatingActionButton: application != null && _canUploadDocuments(application)
          ? FloatingActionButton(
        backgroundColor: AppConstants.primaryColor,
        onPressed: () => _showUploadOptions(context, application),
        child: const Icon(Icons.upload_file),
      )
          : null,
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: AppConstants.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadConnectionDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Text('No connection application found.'),
    );
  }

  Widget _buildDetailsView(ConnectionApplication application) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          _buildStatusCard(application),

          const SizedBox(height: 20),

          // Application details
          Text(
            'Application Details',
            style: AppConstants.subheadingStyle,
          ),
          const SizedBox(height: 12),
          _buildDetailsCard(application),

          const SizedBox(height: 20),

          // Documents
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Documents',
                style: AppConstants.subheadingStyle,
              ),
              if (_canUploadDocuments(application))
                TextButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload'),
                  onPressed: () => _showUploadOptions(context, application),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDocumentsSection(application),

          const SizedBox(height: 20),

          // Timeline
          Text(
            'Application Timeline',
            style: AppConstants.subheadingStyle,
          ),
          const SizedBox(height: 12),
          _buildTimelineCard(application),

          const SizedBox(height: 20),

          // Notes
          if (application.notes != null && application.notes!.isNotEmpty) ...[
            Text(
              'Notes',
              style: AppConstants.subheadingStyle,
            ),
            const SizedBox(height: 12),
            _buildNotesCard(application),
            const SizedBox(height: 20),
          ],

          // Support button
          _buildSupportButton(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ConnectionApplication application) {
    final Color statusColor = _getStatusColor(application.status);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(application.status),
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatStatus(application.status),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'ID: #${application.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getStatusDescription(application.status),
              style: AppConstants.bodyStyle,
            ),
            if (application.installationDate != null && application.status == 'installation_scheduled') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Installation Scheduled',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            'Date: ${_formatDate(application.installationDate!)}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(ConnectionApplication application) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Package', application.packageName ?? 'Unknown Package'),
            _buildDetailRow('Full Name', application.fullName),
            _buildDetailRow('Email', application.email),
            _buildDetailRow('Phone', application.phone),
            _buildDetailRow('Installation Address', application.address),
            _buildDetailRow('Application Date', application.createdAt != null
                ? _formatDate(application.createdAt!)
                : 'Unknown'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(ConnectionApplication application) {
    final documents = application.documents;

    if (documents == null || documents.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No documents uploaded yet',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: documents.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final document = documents[index];
          return ListTile(
            leading: _getDocumentIcon(document.documentType),
            title: Text(_formatDocumentType(document.documentType)),
            subtitle: document.isVerified != null
                ? Text(
              document.isVerified!
                  ? 'Verified'
                  : document.rejectionReason ?? 'Not verified',
              style: TextStyle(
                color: document.isVerified! ? Colors.green : Colors.red,
              ),
            )
                : const Text('Pending verification'),
            trailing: document.fileUrl != null
                ? IconButton(
              icon: const Icon(Icons.remove_red_eye),
              onPressed: () {
                // View document
                UIHelpers.showToast(message: 'Document viewer coming soon!');
              },
            )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildTimelineCard(ConnectionApplication application) {
    final timelineItems = _getTimelineItems(application);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: List.generate(timelineItems.length, (index) {
            final item = timelineItems[index];
            final isLast = index == timelineItems.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 64,
                  child: Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: item['active'] as bool
                              ? AppConstants.primaryColor
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            item['icon'] as IconData,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 50,
                          color: item['active'] as bool
                              ? AppConstants.primaryColor
                              : Colors.grey[300],
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: item['active'] as bool
                              ? AppConstants.textColor
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['description'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: item['active'] as bool
                              ? AppConstants.lightTextColor
                              : Colors.grey,
                        ),
                      ),
                      if (item['date'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item['date'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppConstants.lightTextColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      if (!isLast)
                        const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNotesCard(ConnectionApplication application) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.note, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Admin Notes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(application.notes ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.support_agent),
        label: const Text('Contact Support'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: AppConstants.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          UIHelpers.showToast(message: 'Support contact coming soon!');
        },
      ),
    );
  }

  Future<void> _showUploadOptions(BuildContext context, ConnectionApplication application) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Document',
              style: AppConstants.subheadingStyle,
            ),
            const SizedBox(height: 20),
            const Text(
              'Please select document type and upload the required file.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                _buildDocumentTypeButton(
                  context,
                  'ID Proof',
                  Icons.credit_card,
                  'id_proof',
                  application,
                ),
                const SizedBox(height: 8),
                _buildDocumentTypeButton(
                  context,
                  'Address Proof',
                  Icons.home,
                  'address_proof',
                  application,
                ),
                const SizedBox(height: 8),
                _buildDocumentTypeButton(
                  context,
                  'Photo',
                  Icons.person,
                  'photo',
                  application,
                ),
                const SizedBox(height: 8),
                _buildDocumentTypeButton(
                  context,
                  'Other',
                  Icons.description,
                  'other',
                  application,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTypeButton(
      BuildContext context,
      String title,
      IconData icon,
      String documentType,
      ConnectionApplication application,
      ) {
    // Check if this document type already exists
    final hasDocumentType = application.documents != null &&
        application.documents!.any((doc) => doc.documentType == documentType);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: hasDocumentType
            ? Colors.green.withOpacity(0.1)
            : AppConstants.primaryColor.withOpacity(0.1),
        child: Icon(
          hasDocumentType ? Icons.check : icon,
          color: hasDocumentType ? Colors.green : AppConstants.primaryColor,
        ),
      ),
      title: Text(title),
      subtitle: Text(hasDocumentType ? 'Already uploaded' : 'Tap to upload'),
      trailing: const Icon(Icons.chevron_right),
      onTap: hasDocumentType
          ? () {
        Navigator.of(context).pop();
        UIHelpers.showSnackBar(
          context,
          message: 'Document already uploaded. Please contact support to replace it.',
        );
      }
          : () {
        Navigator.of(context).pop();
        _pickAndUploadDocument(documentType, application.id!);
      },
    );
  }

  Future<void> _pickAndUploadDocument(String documentType, int applicationId) async {
    try {
      setState(() {
        _isUploading = true;
      });

      // Show file source selection dialog
      final source = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop('gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop('camera'),
              ),
              ListTile(
                leading: const Icon(Icons.file_present),
                title: const Text('File'),
                onTap: () => Navigator.of(context).pop('file'),
              ),
            ],
          ),
        ),
      );

      if (source == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      File? file;

      // Pick file based on source
      switch (source) {
        case 'gallery':
          final picker = ImagePicker();
          final pickedFile = await picker.pickImage(source: ImageSource.gallery);
          if (pickedFile != null) {
            file = File(pickedFile.path);
          }
          break;
        case 'camera':
          final picker = ImagePicker();
          final pickedFile = await picker.pickImage(source: ImageSource.camera);
          if (pickedFile != null) {
            file = File(pickedFile.path);
          }
          break;
        case 'file':
          final result = await FilePicker.platform.pickFiles();
          if (result != null && result.files.single.path != null) {
            file = File(result.files.single.path!);
          }
          break;
      }

      if (file == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      // Upload the file
      final connectionProvider = Provider.of<ConnectionProvider>(context, listen: false);
      await connectionProvider.uploadDocument(
        applicationId,
        file,
        documentType,
      );

      setState(() {
        _isUploading = false;
      });

      // Show result
      if (connectionProvider.documentUploadResponse.isCompleted) {
        UIHelpers.showSnackBar(
          context,
          message: 'Document uploaded successfully',
        );
      } else if (connectionProvider.documentUploadResponse.isError) {
        UIHelpers.showSnackBar(
          context,
          message: connectionProvider.documentUploadResponse.message ?? 'Failed to upload document',
          isError: true,
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      UIHelpers.showSnackBar(
        context,
        message: 'Error uploading document: $e',
        isError: true,
      );
    }
  }

  // Helper methods

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.blue;
      case 'document_verification':
        return Colors.amber;
      case 'approved':
        return Colors.green;
      case 'installation_scheduled':
        return Colors.purple;
      case 'active':
        return Colors.teal;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'document_verification':
        return Icons.fact_check;
      case 'approved':
        return Icons.check_circle;
      case 'installation_scheduled':
        return Icons.event;
      case 'active':
        return Icons.wifi;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'document_verification':
        return 'Document Verification';
      case 'approved':
        return 'Approved';
      case 'installation_scheduled':
        return 'Installation Scheduled';
      case 'active':
        return 'Active';
      case 'rejected':
        return 'Rejected';
      default:
        return status.toUpperCase();
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'pending':
        return 'Your application is pending. Please upload all required documents.';
      case 'document_verification':
        return 'We are verifying your documents. We will get back to you soon.';
      case 'approved':
        return 'Your application has been approved. We will schedule installation soon.';
      case 'installation_scheduled':
        return 'Your installation has been scheduled. Our technician will visit your location at the scheduled time.';
      case 'active':
        return 'Your connection is active. Enjoy our services!';
      case 'rejected':
        return 'Your application has been rejected. Please contact support for more information.';
      default:
        return 'Status information not available.';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _getDocumentIcon(String documentType) {
    IconData iconData;
    Color iconColor;

    switch (documentType) {
      case 'id_proof':
        iconData = Icons.credit_card;
        iconColor = Colors.blue;
        break;
      case 'address_proof':
        iconData = Icons.home;
        iconColor = Colors.green;
        break;
      case 'photo':
        iconData = Icons.person;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.description;
        iconColor = Colors.purple;
        break;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(iconData, color: iconColor, size: 16),
    );
  }

  String _formatDocumentType(String documentType) {
    switch (documentType) {
      case 'id_proof':
        return 'ID Proof';
      case 'address_proof':
        return 'Address Proof';
      case 'photo':
        return 'Photo';
      default:
        return 'Other Document';
    }
  }

  List<Map<String, dynamic>> _getTimelineItems(ConnectionApplication application) {
    final List<Map<String, dynamic>> items = [];

    final statuses = [
      'pending',
      'document_verification',
      'approved',
      'installation_scheduled',
      'active',
    ];

    // Find current status index
    final currentStatusIndex = statuses.indexOf(application.status);
    final hasRejection = application.status == 'rejected';

    // Add application submitted item
    items.add({
      'title': 'Application Submitted',
      'description': 'Your connection application has been received',
      'date': application.createdAt != null ? _formatDate(application.createdAt!) : null,
      'icon': Icons.edit,
      'active': true,
    });

    // Document verification
    items.add({
      'title': 'Document Verification',
      'description': 'Review of your submitted documents',
      'date': null,
      'icon': Icons.fact_check,
      'active': currentStatusIndex >= 1 && !hasRejection,
    });

    // Application approved
    items.add({
      'title': 'Application Approved',
      'description': 'Your application has been approved',
      'date': null,
      'icon': Icons.check_circle,
      'active': currentStatusIndex >= 2 && !hasRejection,
    });

    // Installation scheduled
    items.add({
      'title': 'Installation Scheduled',
      'description': 'Technician visit scheduled',
      'date': application.installationDate != null ? _formatDate(application.installationDate!) : null,
      'icon': Icons.event,
      'active': currentStatusIndex >= 3 && !hasRejection,
    });

    // Connection active
    items.add({
      'title': 'Connection Active',
      'description': 'Your internet connection is active',
      'date': application.installationCompletedDate != null ? _formatDate(application.installationCompletedDate!) : null,
      'icon': Icons.wifi,
      'active': currentStatusIndex >= 4 && !hasRejection,
    });

    // If rejected, add rejection item
    if (hasRejection) {
      items.add({
        'title': 'Application Rejected',
        'description': application.notes ?? 'Your application has been rejected',
        'date': application.updatedAt != null ? _formatDate(application.updatedAt!) : null,
        'icon': Icons.cancel,
        'active': true,
      });
    }

    return items;
  }

  bool _canUploadDocuments(ConnectionApplication application) {
    // Can upload if status is pending or document_verification
    return application.status == 'pending' || application.status == 'document_verification';
  }
}