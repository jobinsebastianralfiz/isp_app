// lib/views/chat/chat_bot_screen.dart

import 'package:flutter/material.dart';
import 'package:ispmanagement/views/complaints/chat_service.dart';

class ChatBotScreen extends StatefulWidget {
  final String userId;

  const ChatBotScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late final ChatService _chatService;

  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final history = await _chatService.getChatHistory(widget.userId);

      setState(() {
        _messages.clear();
        _messages.addAll(history);
        _isLoading = false;
      });

      if (_messages.isEmpty) {
        // If no history, add welcome message
        _addBotMessage("Hello! I'm your ISP support assistant. How can I help you today?");
      } else {
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error and add default message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load chat history: $e'))
      );

      _addBotMessage("Hello! I'm your ISP support assistant. How can I help you today?");
    }
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isBot: true,
        ),
      );
    });
    _scrollToBottom();
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    // Add user message to chat
    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isBot: false,
        ),
      );
      _isSending = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // Get bot response
    final response = await _chatService.sendMessage(widget.userId, message);

    setState(() {
      _isSending = false;
      _messages.add(
        ChatMessage(
          text: response,
          isBot: true,
        ),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ISP Support Assistant'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh chat history',
            onPressed: _loadChatHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Loading indicator for sending
          if (_isSending)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // Message input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                // Message text field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                // Send button
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: FloatingActionButton(
                    onPressed: _sendMessage,
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.send),
                    mini: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = !message.isBot;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                child: const Icon(
                  Icons.support_agent,
                  color: Colors.white,
                  size: 16,
                ),
                radius: 16,
              ),
            ),

          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),

          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                backgroundColor: Colors.orange,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 16,
                ),
                radius: 16,
              ),
            ),
        ],
      ),
    );
  }
}