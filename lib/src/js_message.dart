import 'dart:convert';

/// A model class for messages exchanged between JavaScript and Flutter
class JSMessage {
  /// Unique identifier for the message
  final String id;

  /// The type or action of the message
  final String action;

  /// The data payload of the message
  final dynamic data;

  /// Whether this message expects a response
  final bool expectsResponse;

  /// Creates a new message
  JSMessage({required this.id, required this.action, this.data, this.expectsResponse = false});

  /// Creates a message from a JSON map
  factory JSMessage.fromJson(Map<String, dynamic> json) {
    return JSMessage(
      id: json['id'] as String,
      action: json['action'] as String,
      data: json['data'],
      expectsResponse: json['expectsResponse'] as bool? ?? false,
    );
  }

  /// Creates a message from a JSON string
  factory JSMessage.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
    return JSMessage.fromJson(json);
  }

  /// Converts the message to JSON map
  Map<String, dynamic> toJson() {
    return {'id': id, 'action': action, 'data': data, 'expectsResponse': expectsResponse};
  }

  /// Converts the message to a JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }
}
