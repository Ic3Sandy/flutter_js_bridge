import 'package:flutter_js_bridge/flutter_js_bridge.dart';

/// Direction of a message in the JS Bridge
enum JSMessageDirection {
  /// Message sent from Flutter to JavaScript
  outgoing,

  /// Message received from JavaScript to Flutter
  incoming,
}

/// A record of a message passing through the JS Bridge
class JSMessageRecord {
  /// The message that was sent or received
  final JSMessage message;

  /// The direction of the message
  final JSMessageDirection direction;

  /// The time at which the message was recorded
  final DateTime timestamp;

  /// Processing time in milliseconds for response messages
  final int? processingTimeMs;

  /// Creates a new message record
  JSMessageRecord({
    required this.message,
    required this.direction,
    required this.timestamp,
    this.processingTimeMs,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    final directionStr = direction == JSMessageDirection.outgoing
        ? 'OUTGOING'
        : 'INCOMING';
    
    buffer.write('${timestamp.toIso8601String()} [$directionStr] ');
    buffer.write('ID: ${message.id}, Action: ${message.action}');
    
    if (message.expectsResponse) {
      buffer.write(' (Expects Response)');
    }
    
    if (message.isResponse) {
      buffer.write(' (Response)');
    }
    
    if (processingTimeMs != null) {
      buffer.write(' - Processing Time: ${processingTimeMs}ms');
    }
    
    buffer.write('\nData: ${message.data}');
    
    return buffer.toString();
  }
}

/// A component that inspects and records messages passing through the JS Bridge
class JSMessageInspector {
  /// Whether the inspector is enabled
  bool _enabled;

  /// Callback function that is called when a message is inspected
  final void Function(JSMessageRecord record)? onMessageInspected;

  /// Map of message IDs to their outgoing timestamps for calculating processing time
  final Map<String, DateTime> _outgoingTimestamps = {};

  /// List of recorded messages
  final List<JSMessageRecord> _messageHistory = [];

  /// Creates a new message inspector
  ///
  /// [onMessageInspected] Optional callback function that is called when a message is inspected
  /// [enabled] Whether the inspector is enabled by default
  JSMessageInspector({
    this.onMessageInspected,
    bool enabled = true,
  }) : _enabled = enabled;

  /// Records an outgoing message
  ///
  /// [message] The message that was sent
  void recordOutgoingMessage(JSMessage message) {
    if (!_enabled) return;

    final timestamp = DateTime.now();
    
    // Store the timestamp for calculating processing time of responses
    if (message.expectsResponse) {
      _outgoingTimestamps[message.id] = timestamp;
    }
    
    final record = JSMessageRecord(
      message: message,
      direction: JSMessageDirection.outgoing,
      timestamp: timestamp,
    );
    
    _messageHistory.add(record);
    onMessageInspected?.call(record);
  }

  /// Records an incoming message
  ///
  /// [message] The message that was received
  void recordIncomingMessage(JSMessage message) {
    if (!_enabled) return;

    final timestamp = DateTime.now();
    int? processingTimeMs;
    
    // Calculate processing time for response messages
    if (message.isResponse && _outgoingTimestamps.containsKey(message.id)) {
      final requestTime = _outgoingTimestamps[message.id]!;
      processingTimeMs = timestamp.difference(requestTime).inMilliseconds;
      
      // Clean up the timestamp entry
      _outgoingTimestamps.remove(message.id);
    }
    
    final record = JSMessageRecord(
      message: message,
      direction: JSMessageDirection.incoming,
      timestamp: timestamp,
      processingTimeMs: processingTimeMs,
    );
    
    _messageHistory.add(record);
    onMessageInspected?.call(record);
  }

  /// Sets whether the inspector is enabled
  ///
  /// [enabled] Whether the inspector should be enabled
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Clears the message history
  void clearHistory() {
    _messageHistory.clear();
    _outgoingTimestamps.clear();
  }

  /// Gets the number of messages in the history
  int get messageCount => _messageHistory.length;

  /// Gets a copy of the message history
  List<JSMessageRecord> getMessageHistory() {
    return List.unmodifiable(_messageHistory);
  }

  /// Gets the most recent messages, up to the specified limit
  List<JSMessageRecord> getRecentMessages(int limit) {
    if (_messageHistory.length <= limit) {
      return getMessageHistory();
    }
    
    return List.unmodifiable(
      _messageHistory.sublist(_messageHistory.length - limit),
    );
  }

  /// Filters messages by action
  List<JSMessageRecord> filterByAction(String action) {
    return _messageHistory
        .where((record) => record.message.action == action)
        .toList();
  }

  /// Filters messages by ID
  List<JSMessageRecord> filterById(String id) {
    return _messageHistory
        .where((record) => record.message.id == id)
        .toList();
  }

  /// Filters messages by direction
  List<JSMessageRecord> filterByDirection(JSMessageDirection direction) {
    return _messageHistory
        .where((record) => record.direction == direction)
        .toList();
  }
}
