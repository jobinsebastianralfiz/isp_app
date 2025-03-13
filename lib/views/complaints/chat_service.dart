// lib/views/chat/chat_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ispmanagement/config/api_endpoints.dart';

// Message model
class ChatMessage {
  final int? id;
  final String text;
  final bool isBot;
  final DateTime timestamp;

  ChatMessage({
    this.id,
    required this.text,
    required this.isBot,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      text: json['message'],
      isBot: json['is_bot'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

// Chat bot service
class ChatService {
  final String baseUrl = ApiEndpoints.baseUrl;
  final String chatMessageEndpoint = 'telegram_bot/chat/message/';
  final String chatHistoryEndpoint = 'telegram_bot/chat/history/';

  // Send message to chat bot and get response
  Future<String> sendMessage(String userId, String message) async {
    try {
      final url = Uri.parse('$baseUrl$chatMessageEndpoint');

      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'user_id': userId,
            'message': message
          })
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['response'] ?? 'No response from bot';
      } else {
        throw Exception('Failed to get response: ${response.body}');
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Get chat history
  Future<List<ChatMessage>> getChatHistory(String userId) async {
    try {
      final url = Uri.parse('$baseUrl$chatHistoryEndpoint?user_id=$userId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> messagesJson = responseData['messages'];
        return messagesJson.map((msg) => ChatMessage.fromJson(msg)).toList();
      } else {
        throw Exception('Failed to get chat history: ${response.body}');
      }
    } catch (e) {
      print('Error fetching chat history: $e');
      return [];
    }
  }
}