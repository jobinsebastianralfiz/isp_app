import 'package:flutter/material.dart';
import 'package:ispmanagement/models/complaint_model.dart';
import 'package:ispmanagement/providers/complaint_provider.dart';
import 'package:provider/provider.dart';



class ComplaintDetailScreen extends StatefulWidget {
  final int? complaintId;

  const ComplaintDetailScreen({Key? key, required this.complaintId}) : super(key: key);

  @override
  _ComplaintDetailScreenState createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch complaint details when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.complaintId != null) {
        Provider.of<ComplaintProvider>(context, listen: false)
            .fetchComplaint(widget.complaintId!);
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    final complaintProvider = Provider.of<ComplaintProvider>(
      context,
      listen: false,
    );

    final complaint = complaintProvider.selectedComplaint;
    if (complaint == null) return;

    final comment = ComplaintComment(
      complaintId: complaint.id,
      comment: commentText,
    );

    await complaintProvider.addComplaintComment(comment);
    _commentController.clear();
  }

  void _updateComplaintStatus(String status) async {
    final complaintProvider = Provider.of<ComplaintProvider>(
      context,
      listen: false,
    );

    final complaint = complaintProvider.selectedComplaint;
    if (complaint == null) return;

    await complaintProvider.updateComplaintStatus(
      complaint.id!,
      status: status,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, complaintProvider, child) {
          // Show loading indicator
          if (complaintProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if complaint is selected
          final complaint = complaintProvider.selectedComplaint;
          if (complaint == null) {
            return const Center(
              child: Text('Complaint not found'),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildComplaintHeader(complaint),
              ),
              SliverToBoxAdapter(
                child: _buildComplaintBody(complaint),
              ),
              _buildCommentsSection(complaint, complaintProvider),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildCommentInput(),
    );
  }

  Widget _buildComplaintHeader(Complaint complaint) {
    Color statusColor = _getStatusColor(complaint.status);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            complaint.subject,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
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
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(complaint.createdAt ?? DateTime.now()),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintBody(Complaint complaint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            complaint.description,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Complaint Type: ${complaint.complaintType.toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              if (complaint.status != 'closed')
                PopupMenuButton<String>(
                  onSelected: _updateComplaintStatus,
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'pending',
                      child: const Text('Mark as Pending'),
                      enabled: complaint.status != 'pending',
                    ),
                    PopupMenuItem(
                      value: 'closed',
                      child: const Text('Close Complaint'),
                      enabled: complaint.status != 'closed',
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildCommentsSection(
      Complaint complaint,
      ComplaintProvider complaintProvider,
      ) {
    // Ensure comments is not null and handle empty case
    final comments = complaint.comments ?? [];

    return SliverList(
      delegate: SliverChildListDelegate([
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Comments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Check if comments is empty
        if (comments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'No comments yet',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        // Use safe mapping
        ...comments.map((comment) {
          try {
            return _buildCommentItem(comment);
          } catch (e) {
            // Log the error and return an empty container if there's an issue
            print('Error building comment item: $e');
            return const SizedBox.shrink();
          }
        }).toList(),
      ]),
    );
  }

  Widget _buildCommentItem(ComplaintComment comment) {
    // Add null checks and provide fallback values
    final userDetails = comment.userDetails ?? {};
    final firstName = userDetails['first_name'] ?? '';
    final lastName = userDetails['last_name'] ?? '';

    final userName = (firstName + ' ' + lastName).trim().isNotEmpty
        ? (firstName + ' ' + lastName).trim()
        : userDetails['username'] ?? 'Anonymous';

    return ListTile(
      leading: CircleAvatar(
        child: Text(userName[0].toUpperCase()),
      ),
      title: Text(
        userName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment.comment),
          const SizedBox(height: 4),
          Text(
            _formatDate(comment.createdAt ?? DateTime.now()),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

  Widget _buildCommentInput() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _addComment,
            ),
          ],
        ),
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
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}