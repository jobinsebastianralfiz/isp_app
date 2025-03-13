import 'package:flutter/material.dart';
import 'package:ispmanagement/models/complaint_model.dart';
import 'package:ispmanagement/providers/complaint_provider.dart';
import 'package:ispmanagement/providers/auth_provider.dart'; // Import your AuthProvider
import 'package:ispmanagement/views/complaints/chat_boat_screen.dart';
import 'package:ispmanagement/views/complaints/complaints_details.dart';
import 'package:ispmanagement/views/complaints/create_complaints.dart';
import 'package:provider/provider.dart';

class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({Key? key}) : super(key: key);

  @override
  _ComplaintsListScreenState createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch complaints when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).fetchComplaints();
    });
  }

  // Navigate to chat bot screen
  void _navigateToChatBot() {
    // Get the current user from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      // Show error if user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to access support chat')),
      );
      return;
    }

    // Use the user's ID to initialize the chat bot
    final userId = currentUser.id.toString();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatBotScreen(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent),
            tooltip: 'Chat with Support',
            onPressed: _navigateToChatBot,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateComplaintScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, complaintProvider, child) {
          // Show loading indicator
          if (complaintProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error message if there's an error
          if (complaintProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${complaintProvider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      complaintProvider.fetchComplaints();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show empty state if no complaints
          if (complaintProvider.complaints.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.topic_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Complaints Yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Click + to create a new complaint',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // Display list of complaints
          return RefreshIndicator(
            onRefresh: () => complaintProvider.fetchComplaints(),
            child: ListView.builder(
              itemCount: complaintProvider.complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaintProvider.complaints[index];
                return _buildComplaintListItem(context, complaint);
              },
            ),
          );
        },
      ),
      // Add a floating action button for quick access to chat
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToChatBot,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.chat),
        tooltip: 'Chat with Support',
      ),
    );
  }

  Widget _buildComplaintListItem(BuildContext context, Complaint complaint) {
    // Determine color based on status
    Color statusColor = _getStatusColor(complaint.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          complaint.subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              complaint.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    complaint.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  complaint.createdAt != null
                      ? _formatDate(complaint.createdAt!)
                      : 'No date',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComplaintDetailScreen(complaintId: complaint.id!),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}