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
  JSEvent({required this.name, this.data, this.origin, this.isMainFrame = true});
}

/// Callback function type for JavaScript events
typedef JSEventHandler = void Function(JSEvent event);

/// Callback function type for JavaScript interactions with return values
typedef JSCallbackHandler = dynamic Function(List<dynamic> arguments);
