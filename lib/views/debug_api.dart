import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/api_endpoints.dart';
import '../services/api_service.dart';
import '../utils/ui_helpers.dart';

class DebugApiScreen extends StatefulWidget {
  const DebugApiScreen({Key? key}) : super(key: key);

  @override
  _DebugApiScreenState createState() => _DebugApiScreenState();
}

class _DebugApiScreenState extends State<DebugApiScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _payloadController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();

  String _selectedMethod = 'GET';
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _urlController.text = '/api/users/register/';  // Default to registration endpoint
    _payloadController.text = '''{
  "username": "testuser",
  "email": "test@example.com",
  "password": "Test@123",
  "password2": "Test@123",
  "first_name": "Test",
  "last_name": "User",
  "phone_number": "1234567890",
  "address": "123 Test Street"
}''';
  }

  @override
  void dispose() {
    _urlController.dispose();
    _payloadController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Debug Tool'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Base URL display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Base URL:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ApiEndpoints.baseUrl,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: ApiEndpoints.baseUrl));
                            UIHelpers.showToast(message: 'Base URL copied to clipboard');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // HTTP Method dropdown
            Row(
              children: [
                const Text('Method:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedMethod,
                  items: ['GET', 'POST', 'PUT', 'DELETE'].map((method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMethod = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Endpoint input
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Endpoint',
                hintText: 'e.g., /api/users/register/',
                border: OutlineInputBorder(),
                prefixText: '/',
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),

            const SizedBox(height: 16),

            // JSON payload input (for POST/PUT)
            if (_selectedMethod == 'POST' || _selectedMethod == 'PUT') ...[
              const Text('Request Body (JSON):', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _payloadController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '{\n  "key": "value"\n}',
                ),
                maxLines: 12,
                style: const TextStyle(fontFamily: 'monospace'),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.format_align_left),
                    label: const Text('Format JSON'),
                    onPressed: _formatJSON,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear'),
                    onPressed: () {
                      setState(() {
                        _payloadController.clear();
                      });
                    },
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Send request button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: Text(_isLoading ? 'Sending...' : 'Send Request'),
                onPressed: _isLoading ? null : _sendRequest,
              ),
            ),

            const SizedBox(height: 16),

            // Status message
            if (_statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _statusMessage.contains('Error') ? Colors.red : Colors.green,
                  ),
                ),
              ),

            // Response display
            if (_responseController.text.isNotEmpty) ...[
              const Text('Response:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _responseController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                maxLines: 15,
                readOnly: true,
                style: const TextStyle(fontFamily: 'monospace'),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Response'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _responseController.text));
                      UIHelpers.showToast(message: 'Response copied to clipboard');
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    onPressed: () {
                      setState(() {
                        _responseController.clear();
                        _statusMessage = '';
                      });
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _formatJSON() {
    try {
      final jsonText = _payloadController.text;
      if (jsonText.trim().isEmpty) return;

      final dynamic jsonData = jsonDecode(jsonText);
      final formattedJson = const JsonEncoder.withIndent('  ').convert(jsonData);

      setState(() {
        _payloadController.text = formattedJson;
      });
    } catch (e) {
      UIHelpers.showToast(
        message: 'Invalid JSON: ${e.toString()}',
        isError: true,
      );
    }
  }

  Future<void> _sendRequest() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
      _responseController.clear();
    });

    try {
      final endpoint = _urlController.text.trim();
      if (endpoint.isEmpty) {
        throw Exception('Endpoint cannot be empty');
      }

      // Remove leading slash if present since base URL already has trailing slash
      final finalEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;

      dynamic response;

      switch (_selectedMethod) {
        case 'GET':
          response = await _apiService.get(finalEndpoint);
          break;
        case 'POST':
          final payload = _payloadController.text.trim();
          if (payload.isEmpty) {
            throw Exception('Request body cannot be empty for POST');
          }

          try {
            final jsonData = jsonDecode(payload);
            response = await _apiService.post(finalEndpoint, data: jsonData);
          } catch (e) {
            throw Exception('Invalid JSON: ${e.toString()}');
          }
          break;
        case 'PUT':
          final payload = _payloadController.text.trim();
          if (payload.isEmpty) {
            throw Exception('Request body cannot be empty for PUT');
          }

          try {
            final jsonData = jsonDecode(payload);
            response = await _apiService.put(finalEndpoint, data: jsonData);
          } catch (e) {
            throw Exception('Invalid JSON: ${e.toString()}');
          }
          break;
        case 'DELETE':
          response = await _apiService.delete(finalEndpoint);
          break;
      }

      setState(() {
        _isLoading = false;
        _statusMessage = 'Request successful!';
        _responseController.text = const JsonEncoder.withIndent('  ').convert(response);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error: ${e.toString()}';
        _responseController.text = '';
      });
    }
  }
}