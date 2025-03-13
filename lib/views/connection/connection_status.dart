import 'package:flutter/material.dart';
import 'package:ispmanagement/views/connection/documetn%20uoliad.dart';
import 'package:provider/provider.dart';
import '../../config/app_constants.dart';
import '../../models/connection_models.dart';
import '../../providers/connection_provider.dart';
import '../../utils/ui_helpers.dart';


class ConnectionStatusScreen extends StatefulWidget {
  const ConnectionStatusScreen({Key? key}) : super(key: key);

  @override
  _ConnectionStatusScreenState createState() => _ConnectionStatusScreenState();
}

class _ConnectionStatusScreenState extends State<ConnectionStatusScreen> {
  @override
  void initState() {
    super.initState();
    // Load user's applications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplications();
    });
  }

  Future<void> _loadApplications() async {
    final connectionProvider = Provider.of<ConnectionProvider>(context, listen: false);
    await connectionProvider.getConnectionApplications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _loadApplications,
        child: Consumer<ConnectionProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.applicationsResponse.isError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading applications',
                      style: AppConstants.subheadingStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.applicationsResponse.message ?? 'Please try again later',
                      style: AppConstants.bodyStyle.copyWith(
                        color: AppConstants.lightTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadApplications,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final applications = provider.applications;

            if (applications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Applications Found',
                      style: AppConstants.subheadingStyle,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'You haven\'t applied for any connections yet',
                        style: AppConstants.bodyStyle.copyWith(
                          color: AppConstants.lightTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Debug: print what we received
            print('Found ${applications.length} applications');

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final application = applications[index];
                // Debug: print application data
                print('Application ${index}: ${application.fullName}, ID: ${application.id}');
                return _buildApplicationCard(application);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildApplicationCard(ConnectionApplication application) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColor(application.status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Application #${application.id ?? "N/A"}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Applied on: ${_formatDate(application.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(application.status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getStatusText(application.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Application details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Package information section
                Text(
                  application.packageName ?? 'Package ID: ${application.packageId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Customer information
                Text(
                  'Name: ${application.fullName}',
                  style: AppConstants.bodyStyle,
                ),
                Text(
                  'Email: ${application.email}',
                  style: AppConstants.bodyStyle,
                ),
                Text(
                  'Phone: ${application.phone}',
                  style: AppConstants.bodyStyle,
                ),
                Text(
                  'Address: ${application.address}',
                  style: AppConstants.bodyStyle,
                ),

                const Divider(height: 24),

                // Status timeline
                _buildStatusTimeline(application),

                // Document status
                if (application.status == 'pending' || application.status == 'document_verification') ...[
                  const Divider(height: 24),
                  _buildDocumentStatus(application),
                ],

                // Actions
                _buildActionButtons(application),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(ConnectionApplication application) {
    final statusList = [
      'pending',
      'document_verification',
      'approved',
      'installation_scheduled',
      'active',
    ];

    final currentStatusIndex = statusList.indexOf(application.status);
    if (currentStatusIndex == -1) {
      // If status is not in our list (e.g., "rejected"), show basic status info
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(application.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getStatusText(application.status),
              style: TextStyle(
                color: _getStatusColor(application.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusDescription(application.status),
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.lightTextColor,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Application Status',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(statusList.length, (index) {
            final isCompleted = index <= currentStatusIndex;
            final isLast = index == statusList.length - 1;

            return Expanded(
              child: Row(
                children: [
                  // Circle indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? AppConstants.primaryColor : Colors.grey[300],
                    ),
                    child: isCompleted
                        ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                        : null,
                  ),

                  // Connecting line
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: isCompleted && index < currentStatusIndex
                            ? AppConstants.primaryColor
                            : Colors.grey[300],
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Applied',
              style: TextStyle(fontSize: 12),
            ),
            const Text(
              'Documents',
              style: TextStyle(fontSize: 12),
            ),
            const Text(
              'Approved',
              style: TextStyle(fontSize: 12),
            ),
            const Text(
              'Scheduled',
              style: TextStyle(fontSize: 12),
            ),
            const Text(
              'Active',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _getStatusDescription(application.status),
          style: TextStyle(
            fontSize: 14,
            color: AppConstants.lightTextColor,
          ),
        ),
        if (application.installationDate != null) ...[
          const SizedBox(height: 8),
          Text(
            'Installation Date: ${_formatDate(application.installationDate)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDocumentStatus(ConnectionApplication application) {
    final documents = application.documents ?? [];
    final hasIdProof = documents.any((doc) => doc.documentType == 'id_proof');
    final hasAddressProof = documents.any((doc) => doc.documentType == 'address_proof');
    final hasPhoto = documents.any((doc) => doc.documentType == 'photo');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Required Documents',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        _buildDocumentStatusItem('ID Proof', hasIdProof),
        const SizedBox(height: 8),
        _buildDocumentStatusItem('Address Proof', hasAddressProof),
        const SizedBox(height: 8),
        _buildDocumentStatusItem('Photograph', hasPhoto),
      ],
    );
  }

  Widget _buildDocumentStatusItem(String title, bool isUploaded) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isUploaded ? Colors.green[100] : Colors.grey[200],
            border: Border.all(
              color: isUploaded ? Colors.green : Colors.grey,
              width: 1,
            ),
          ),
          child: isUploaded
              ? const Icon(
            Icons.check,
            color: Colors.green,
            size: 16,
          )
              : null,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: isUploaded ? Colors.black : Colors.grey,
          ),
        ),
        const Spacer(),
        if (!isUploaded)
          Text(
            'Required',
            style: TextStyle(
              color: Colors.red[400],
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(ConnectionApplication application) {
    // Get documents status
    final documents = application.documents ?? [];
    final areAllDocumentsUploaded =
        documents.any((doc) => doc.documentType == 'id_proof') &&
            documents.any((doc) => doc.documentType == 'address_proof') &&
            documents.any((doc) => doc.documentType == 'photo');

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!areAllDocumentsUploaded && (application.status == 'pending' || application.status == 'document_verification'))
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentUploadScreen(application: application),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
              ),
              child: const Text('Upload Documents'),
            ),

          if (application.status == 'installation_scheduled')
            OutlinedButton(
              onPressed: () {
                UIHelpers.showToast(message: 'Contacting support...');
                // Add functionality to contact support
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
              ),
              child: const Text('Contact Support'),
            ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'document_verification':
        return Colors.blue;
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

  String _getStatusText(String status) {
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
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'pending':
        return 'Your application has been received. Please upload the required documents for verification.';
      case 'document_verification':
        return 'Your documents are under verification. We will contact you soon.';
      case 'approved':
        return 'Your application has been approved. We will schedule an installation soon.';
      case 'installation_scheduled':
        return 'Installation has been scheduled. Our technician will visit your location on the scheduled date.';
      case 'active':
        return 'Your connection is active and running. Enjoy our services!';
      case 'rejected':
        return 'Unfortunately, your application has been rejected. Please contact support for more information.';
      default:
        return 'Application status: ${status.replaceAll('_', ' ')}';
    }
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Not available';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }
}