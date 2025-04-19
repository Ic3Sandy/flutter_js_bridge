import 'dart:convert';

/// A message for communication between JavaScript and Dart
class JSMessage {
  /// Unique identifier for the message
  final String id;
  
  /// Action to perform
  final String action;
  
  /// Data payload
  final dynamic data;
  
  /// Whether a response is expected
  final bool expectsResponse;
  
  /// Creates a new message
  JSMessage({
    required this.id,
    required this.action,
    this.data,
    this.expectsResponse = false,
  });
  
  /// Creates a message from a JSON string
  factory JSMessage.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return JSMessage(
      id: json['id'] as String,
      action: json['action'] as String,
      data: json['data'],
      expectsResponse: json['expectsResponse'] as bool? ?? false,
    );
  }
  
  /// Converts the message to a JSON string
  String toJsonString() {
    return jsonEncode({
      'id': id,
      'action': action,
      'data': data,
      'expectsResponse': expectsResponse,
    });
  }
}
