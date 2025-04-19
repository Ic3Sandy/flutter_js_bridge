import 'dart:async';
import 'js_event.dart';
import 'js_bridge_controller.dart';

/// A subscription to a JavaScript event
class JSEventSubscription {
  final JSEventBus _eventBus;
  final String _eventName;
  final JSEventHandler _handler;
  final bool _isWildcard;
  final bool Function(JSEvent)? _filter;
  bool _isCancelled = false;

  /// Creates a new subscription to events
  /// 
  /// [eventName] The name of the event to subscribe to, or '*' for all events
  /// [handler] The function to call when the event is received
  /// [isWildcard] Whether this is a wildcard subscription that receives all events
  /// [filter] Optional filter function to only receive specific events
  JSEventSubscription(
    this._eventBus,
    this._eventName,
    this._handler, {
    bool isWildcard = false,
    bool Function(JSEvent)? filter,
  })  : _isWildcard = isWildcard,
        _filter = filter;

  /// Cancels this subscription
  void cancel() {
    if (!_isCancelled) {
      _eventBus._removeSubscription(this);
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
  bool get isCancelled => _isCancelled;
}

/// A bus for JavaScript events that allows subscribing to specific event types
class JSEventBus {
  final JSBridgeController _controller;
  final List<JSEventSubscription> _subscriptions = [];
  final StreamController<JSEvent> _eventStreamController = StreamController<JSEvent>.broadcast();

  /// Creates a new event bus with the given bridge controller
  /// 
  /// [controller] The JSBridgeController to use for communication with JavaScript
  JSEventBus(this._controller) {
    // Register a global handler for all events
    _controller.registerHandler('event', _handleEvent);
  }
  
  /// Converts a JSEvent to a JSON map
  Map<String, dynamic> _eventToJson(JSEvent event) {
    return {
      'name': event.name,
      'data': event.data,
      if (event.origin != null) 'origin': event.origin,
      'isMainFrame': event.isMainFrame,
    };
  }

  /// Creates a JSEvent from a JSON map
  JSEvent _createEventFromJson(Map<String, dynamic> json) {
    return JSEvent(
      name: json['name'] as String,
      data: json['data'],
      origin: json['origin'] as String?,
      isMainFrame: json['isMainFrame'] as bool? ?? true,
    );
  }

  /// Handles events coming from JavaScript
  dynamic _handleEvent(List<dynamic> args) {
    if (args.isEmpty || args[0] == null) return null;

    // Convert the event data to a JSEvent
    final eventData = args[0];
    final JSEvent event = eventData is JSEvent
        ? eventData
        : _createEventFromJson(eventData as Map<String, dynamic>);

    // Add the event to the stream
    _eventStreamController.add(event);
    
    // Notify all matching subscribers
    _notifySubscribers(event);

    return null;
  }

  /// Notifies all subscribers that match the event
  void _notifySubscribers(JSEvent event) {
    // Create a copy of the subscriptions to avoid issues if handlers modify the list
    final subscriptions = List<JSEventSubscription>.from(_subscriptions);

    for (final subscription in subscriptions) {
      if (subscription.isCancelled) continue;
      if (!subscription.matchesEvent(event.name)) continue;
      if (!subscription.passesFilter(event)) continue;

      // Notify the subscriber
      subscription.handler(event);
    }
  }

  /// Subscribes to events with the given name
  /// 
  /// [eventName] The name of the event to subscribe to
  /// [handler] The function to call when the event is received
  /// 
  /// Returns a subscription that can be cancelled
  JSEventSubscription on(String eventName, JSEventHandler handler) {
    final subscription = JSEventSubscription(this, eventName, handler);
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Subscribes to all events
  /// 
  /// [handler] The function to call when any event is received
  /// 
  /// Returns a subscription that can be cancelled
  JSEventSubscription onAny(JSEventHandler handler) {
    final subscription = JSEventSubscription(this, '*', handler, isWildcard: true);
    _subscriptions.add(subscription);
    return subscription;
  }

  /// Subscribes to events with the given name that match the filter
  /// 
  /// [eventName] The name of the event to subscribe to
  /// [filter] A function that returns true if the event should be handled
  /// [handler] The function to call when a matching event is received
  /// 
  /// Returns a subscription that can be cancelled
  JSEventSubscription onWhere(
    String eventName,
    bool Function(JSEvent) filter,
    JSEventHandler handler,
  ) {
    final subscription = JSEventSubscription(
      this,
      eventName,
      handler,
      filter: filter,
    );
    _subscriptions.add(subscription);
    return subscription;
  }
  
  /// Gets a stream of all events
  /// 
  /// This can be used with the Stream API for more advanced event handling
  Stream<JSEvent> get eventStream => _eventStreamController.stream;
  
  /// Gets a filtered stream of events with the given name
  /// 
  /// [eventName] The name of the event to filter for
  Stream<JSEvent> eventStreamOf(String eventName) {
    return _eventStreamController.stream.where((event) => event.name == eventName);
  }

  /// Publishes an event to JavaScript
  /// 
  /// [event] The event to publish
  void publish(JSEvent event) {
    _controller.sendToJavaScript('event', data: _eventToJson(event));
  }

  /// Removes a subscription from the bus
  void _removeSubscription(JSEventSubscription subscription) {
    _subscriptions.remove(subscription);
  }

  /// Whether there are any subscribers for the given event name
  /// 
  /// [eventName] The name of the event to check for subscribers
  bool hasSubscribers(String eventName) {
    return _subscriptions.any(
      (subscription) =>
          !subscription.isCancelled && subscription.matchesEvent(eventName),
    );
  }
}
