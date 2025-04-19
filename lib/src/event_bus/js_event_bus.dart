import 'dart:async';

import 'package:flutter_js_bridge/src/event_bus/js_event_interface.dart';
import 'package:flutter_js_bridge/src/event_bus/js_event_subscription.dart';
import 'package:flutter_js_bridge/src/js_bridge_controller.dart';
import 'package:flutter_js_bridge/src/js_event.dart';

/// A bus for JavaScript events that allows subscribing to specific event types
class JSEventBus implements IJSEventBus {
  final JSBridgeController _controller;
  final List<JSEventSubscription> _subscriptions = [];
  final StreamController<JSEvent> _eventStreamController =
      StreamController<JSEvent>.broadcast();
  bool _isDisposed = false;

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
    if (_isDisposed) return null;
    if (args.isEmpty || args[0] == null) return null;

    // Convert the event data to a JSEvent
    final eventData = args[0];
    final JSEvent event =
        eventData is JSEvent
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
    if (_isDisposed) return;

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
  @override
  IJSEventSubscription on(String eventName, JSEventHandler handler) {
    _checkDisposed();

    // Create a variable to hold the subscription reference
    late final JSEventSubscription subscription;

    // Create the subscription with a callback that can reference itself
    subscription = JSEventSubscription(
      eventName,
      handler,
      () => _removeSubscription(subscription),
    );

    _subscriptions.add(subscription);
    return subscription;
  }

  /// Subscribes to all events
  ///
  /// [handler] The function to call when any event is received
  ///
  /// Returns a subscription that can be cancelled
  @override
  IJSEventSubscription onAny(JSEventHandler handler) {
    _checkDisposed();

    // Create a variable to hold the subscription reference
    late final JSEventSubscription subscription;

    // Create the subscription with a callback that can reference itself
    subscription = JSEventSubscription(
      '*',
      handler,
      () => _removeSubscription(subscription),
      isWildcard: true,
    );

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
  @override
  IJSEventSubscription onWhere(
    String eventName,
    bool Function(JSEvent) filter,
    JSEventHandler handler,
  ) {
    _checkDisposed();

    // Create a variable to hold the subscription reference
    late final JSEventSubscription subscription;

    // Create the subscription with a callback that can reference itself
    subscription = JSEventSubscription(
      eventName,
      handler,
      () => _removeSubscription(subscription),
      filter: filter,
    );

    _subscriptions.add(subscription);
    return subscription;
  }

  /// Gets a stream of all events
  ///
  /// This can be used with the Stream API for more advanced event handling
  @override
  Stream<JSEvent> get eventStream {
    _checkDisposed();
    return _eventStreamController.stream;
  }

  /// Gets a filtered stream of events with the given name
  ///
  /// [eventName] The name of the event to filter for
  @override
  Stream<JSEvent> eventStreamOf(String eventName) {
    _checkDisposed();
    return _eventStreamController.stream.where(
      (event) => event.name == eventName,
    );
  }

  /// Publishes an event to JavaScript
  ///
  /// [event] The event to publish
  @override
  void publish(JSEvent event) {
    _checkDisposed();
    _controller.sendToJavaScript('event', data: _eventToJson(event));

    // Also notify local subscribers
    _notifySubscribers(event);
  }

  /// Removes a subscription from the bus
  void _removeSubscription(JSEventSubscription subscription) {
    if (!_isDisposed) {
      _subscriptions.remove(subscription);
    }
  }

  /// Whether there are any subscribers for the given event name
  ///
  /// [eventName] The name of the event to check for subscribers
  @override
  bool hasSubscribers(String eventName) {
    _checkDisposed();
    return _subscriptions.any(
      (subscription) =>
          !subscription.isCancelled && subscription.matchesEvent(eventName),
    );
  }

  /// Releases all resources used by this event bus
  @override
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    _controller.unregisterHandler('event');

    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      if (!subscription.isCancelled) {
        // Use internal method to avoid subscription trying to remove itself from the list
        subscription.cancel();
      }
    }
    _subscriptions.clear();

    // Close the stream controller
    _eventStreamController.close();
  }

  /// Checks if this event bus has been disposed
  void _checkDisposed() {
    if (_isDisposed) {
      throw StateError('Cannot use a disposed JSEventBus');
    }
  }
}
