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
  ///
  /// [id] must not be empty
  /// [action] must not be empty
  /// [data] optional data payload for the message
  /// [expectsResponse] whether this message expects a response, defaults to false
  JSMessage({
    required this.id,
    required this.action,
    this.data,
    this.expectsResponse = false,
  }) {
    if (id.isEmpty) {
      throw ArgumentError('Message ID cannot be empty');
    }
    if (action.isEmpty) {
      throw ArgumentError('Message action cannot be empty');
    }
  }

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
    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;
    return JSMessage.fromJson(json);
  }

  /// Creates a response message for this message
  JSMessage createResponse(dynamic responseData) {
    return JSMessage(
      id: id,
      action: 'response',
      data: responseData,
      expectsResponse: false,
    );
  }

  /// Creates a copy of this message with the given fields replaced with new values
  JSMessage copyWith({
    String? id,
    String? action,
    dynamic data,
    bool? expectsResponse,
  }) {
    return JSMessage(
      id: id ?? this.id,
      action: action ?? this.action,
      data: data ?? this.data,
      expectsResponse: expectsResponse ?? this.expectsResponse,
    );
  }

  /// Converts the message to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'data': data,
      'expectsResponse': expectsResponse,
    };
  }

  /// Converts the message to a JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  @override
  String toString() {
    return 'JSMessage(id: $id, action: $action, data: $data, expectsResponse: $expectsResponse)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is JSMessage &&
        other.id == id &&
        other.action == action &&
        other.expectsResponse == expectsResponse &&
        _deepEquals(other.data, data);
  }

  @override
  int get hashCode => Object.hash(id, action, expectsResponse, data);

  /// Helper method to compare data which might be complex objects
  bool _deepEquals(dynamic a, dynamic b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;

    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      return a.entries.every(
        (entry) =>
            b.containsKey(entry.key) && _deepEquals(entry.value, b[entry.key]),
      );
    }

    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }
      return true;
    }

    return a == b;
  }
}
