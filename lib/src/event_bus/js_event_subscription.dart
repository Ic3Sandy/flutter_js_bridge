import 'package:flutter_js_bridge/src/event_bus/js_event_interface.dart';
import 'package:flutter_js_bridge/src/js_event.dart';

/// A subscription to a JavaScript event
class JSEventSubscription implements IJSEventSubscription {
  final Function _onCancel;
  final String _eventName;
  final JSEventHandler _handler;
  final bool _isWildcard;
  final bool Function(JSEvent)? _filter;
  bool _isCancelled = false;

  /// Creates a new subscription to events
  ///
  /// [eventName] The name of the event to subscribe to, or '*' for all events
  /// [handler] The function to call when the event is received
  /// [onCancel] Function to call when this subscription is cancelled
  /// [isWildcard] Whether this is a wildcard subscription that receives all events
  /// [filter] Optional filter function to only receive specific events
  JSEventSubscription(
    this._eventName,
    this._handler,
    this._onCancel, {
    bool isWildcard = false,
    bool Function(JSEvent)? filter,
  }) : _isWildcard = isWildcard,
       _filter = filter;

  /// Cancels this subscription
  @override
  void cancel() {
    if (!_isCancelled) {
      _onCancel();
      _isCancelled = true;
    }
  }

  /// Whether this subscription is for the given event name
  bool matchesEvent(String eventName) {
    return _isWildcard || _eventName == eventName;
  }

  /// Whether this subscription passes the filter for the given event
  bool passesFilter(JSEvent event) {
    return _filter == null || _filter(event);
  }

  /// The handler for this subscription
  JSEventHandler get handler => _handler;

  /// Whether this subscription has been cancelled
  @override
  bool get isCancelled => _isCancelled;
}
