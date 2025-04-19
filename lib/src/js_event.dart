/// A class for JavaScript events received in Flutter
class JSEvent {
  /// The source event name
  final String name;

  /// The event data
  final dynamic data;

  /// The source origin of the event
  final String? origin;

  /// Whether the event originated from the main frame
  final bool isMainFrame;

  /// Creates a new JavaScript event
  ///
  /// [name] must not be empty
  /// [data] optional data payload for the event
  /// [origin] optional source origin of the event
  /// [isMainFrame] whether the event originated from the main frame, defaults to true
  JSEvent({
    required this.name,
    this.data,
    this.origin,
    this.isMainFrame = true,
  }) {
    if (name.isEmpty) {
      throw ArgumentError('Event name cannot be empty');
    }
  }

  /// Creates a copy of this event with the given fields replaced with new values
  JSEvent copyWith({
    String? name,
    dynamic data,
    String? origin,
    bool? isMainFrame,
  }) {
    return JSEvent(
      name: name ?? this.name,
      data: data ?? this.data,
      origin: origin ?? this.origin,
      isMainFrame: isMainFrame ?? this.isMainFrame,
    );
  }

  @override
  String toString() {
    return 'JSEvent(name: $name, data: $data, origin: $origin, isMainFrame: $isMainFrame)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is JSEvent &&
        other.name == name &&
        other.origin == origin &&
        other.isMainFrame == isMainFrame &&
        _deepEquals(other.data, data);
  }

  @override
  int get hashCode => Object.hash(name, origin, isMainFrame, data);

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

/// Callback function type for JavaScript events
typedef JSEventHandler = void Function(JSEvent event);

/// Callback function type for JavaScript interactions with return values
typedef JSCallbackHandler = dynamic Function(List<dynamic> arguments);
