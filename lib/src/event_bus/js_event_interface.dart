import 'package:flutter_js_bridge/src/js_event.dart';

// Use the JSEventHandler from js_event.dart

/// Interface for event subscriptions
abstract class IJSEventSubscription {
  /// Cancels this subscription
  void cancel();

  /// Whether this subscription has been cancelled
  bool get isCancelled;
}

/// Interface for event bus implementations
abstract class IJSEventBus {
  /// Subscribes to events with the given name
  ///
  /// [eventName] The name of the event to subscribe to
  /// [handler] The function to call when the event is received
  ///
  /// Returns a subscription that can be cancelled
  IJSEventSubscription on(String eventName, JSEventHandler handler);

  /// Subscribes to all events
  ///
  /// [handler] The function to call when any event is received
  ///
  /// Returns a subscription that can be cancelled
  IJSEventSubscription onAny(JSEventHandler handler);

  /// Subscribes to events with the given name that match the filter
  ///
  /// [eventName] The name of the event to subscribe to
  /// [filter] A function that returns true if the event should be handled
  /// [handler] The function to call when a matching event is received
  ///
  /// Returns a subscription that can be cancelled
  IJSEventSubscription onWhere(
    String eventName,
    bool Function(JSEvent) filter,
    JSEventHandler handler,
  );

  /// Gets a stream of all events
  Stream<JSEvent> get eventStream;

  /// Gets a filtered stream of events with the given name
  ///
  /// [eventName] The name of the event to filter for
  Stream<JSEvent> eventStreamOf(String eventName);

  /// Publishes an event to JavaScript
  ///
  /// [event] The event to publish
  void publish(JSEvent event);

  /// Whether there are any subscribers for the given event name
  ///
  /// [eventName] The name of the event to check for subscribers
  bool hasSubscribers(String eventName);

  /// Releases all resources used by this event bus
  void dispose();
}
