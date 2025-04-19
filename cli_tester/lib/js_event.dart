/// A class for JavaScript events received in Dart
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

  @override
  String toString() {
    return 'JSEvent(name: $name, data: $data, origin: $origin, isMainFrame: $isMainFrame)';
  }
}

/// Callback function type for JavaScript events
typedef JSEventHandler = void Function(JSEvent event);

/// Callback function type for JavaScript interactions with return values
typedef JSCallbackHandler = dynamic Function(List<dynamic> arguments);
