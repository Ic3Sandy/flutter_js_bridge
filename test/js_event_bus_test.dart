import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_js_bridge/src/js_event.dart';

// Forward declarations for subscription types
typedef SubscriptionCancelFunction = void Function();

// A simple event bus implementation for testing
class TestEventBus {
  final Map<String, List<void Function(JSEvent)>> _subscribers = {};
  final List<void Function(JSEvent)> _wildcardSubscribers = [];
  final Map<String, List<FilteredSubscription>> _filteredSubscribers = {};

  Subscription on(String eventName, void Function(JSEvent) handler) {
    _subscribers.putIfAbsent(eventName, () => []).add(handler);

    return Subscription(() {
      final subs = _subscribers[eventName];
      if (subs != null) {
        subs.remove(handler);
        if (subs.isEmpty) {
          _subscribers.remove(eventName);
        }
      }
    });
  }

  Subscription onAny(void Function(JSEvent) handler) {
    _wildcardSubscribers.add(handler);

    return Subscription(() {
      _wildcardSubscribers.remove(handler);
    });
  }

  Subscription onWhere(
    String eventName,
    bool Function(JSEvent) filter,
    void Function(JSEvent) handler,
  ) {
    final subscription = FilteredSubscription(filter, handler);
    _filteredSubscribers.putIfAbsent(eventName, () => []).add(subscription);

    return Subscription(() {
      final subs = _filteredSubscribers[eventName];
      if (subs != null) {
        subs.remove(subscription);
        if (subs.isEmpty) {
          _filteredSubscribers.remove(eventName);
        }
      }
    });
  }

  void publish(JSEvent event) {
    // Notify specific subscribers
    final specificSubs = _subscribers[event.name];
    if (specificSubs != null) {
      for (final handler in List<Function(JSEvent)>.from(specificSubs)) {
        handler(event);
      }
    }

    // Notify filtered subscribers
    final filteredSubs = _filteredSubscribers[event.name];
    if (filteredSubs != null) {
      for (final sub in List<FilteredSubscription>.from(filteredSubs)) {
        if (sub.matchesFilter(event)) {
          sub.handler(event);
        }
      }
    }

    // Notify wildcard subscribers
    for (final handler in List<Function(JSEvent)>.from(_wildcardSubscribers)) {
      handler(event);
    }
  }

  bool hasSubscribers(String eventName) {
    return _subscribers.containsKey(eventName) &&
        _subscribers[eventName]!.isNotEmpty;
  }
}

// Subscription class for the test event bus
class Subscription {
  final SubscriptionCancelFunction _cancelFunction;
  bool _cancelled = false;

  Subscription(this._cancelFunction);

  void cancel() {
    if (!_cancelled) {
      _cancelFunction();
      _cancelled = true;
    }
  }
}

// Filtered subscription class for the test event bus
class FilteredSubscription {
  final bool Function(JSEvent) filter;
  final Function(JSEvent) handler;

  FilteredSubscription(this.filter, this.handler);

  bool matchesFilter(JSEvent event) => filter(event);
}

void main() {
  late TestEventBus eventBus;

  setUp(() {
    eventBus = TestEventBus();
  });

  group('Event Bus', () {
    test('should allow subscribing to events by name', () {
      // Arrange
      void eventHandler(JSEvent event) {}

      // Act
      final subscription = eventBus.on('userLogin', eventHandler);

      // Assert
      expect(subscription, isNotNull);
      expect(eventBus.hasSubscribers('userLogin'), isTrue);
    });

    test('should allow unsubscribing from events', () {
      // Arrange
      void eventHandler(JSEvent event) {}
      final subscription = eventBus.on('userLogin', eventHandler);

      // Act
      subscription.cancel();

      // Assert
      expect(eventBus.hasSubscribers('userLogin'), isFalse);
    });

    test('should route events to correct subscribers', () {
      // Arrange
      bool loginEventReceived = false;
      bool logoutEventReceived = false;

      eventBus.on('userLogin', (JSEvent event) {
        loginEventReceived = true;
        expect(event.name, equals('userLogin'));
        expect(event.data, equals({'userId': '123'}));
      });

      eventBus.on('userLogout', (JSEvent event) {
        logoutEventReceived = true;
      });

      // Act - publish login event
      eventBus.publish(JSEvent(name: 'userLogin', data: {'userId': '123'}));

      // Assert
      expect(loginEventReceived, isTrue);
      expect(logoutEventReceived, isFalse);
    });

    test('should support wildcard subscriptions', () {
      // Arrange
      int eventsReceived = 0;

      eventBus.onAny((JSEvent event) {
        eventsReceived++;
      });

      // Act - publish multiple events
      eventBus.publish(JSEvent(name: 'userLogin', data: {'userId': '123'}));
      eventBus.publish(JSEvent(name: 'userLogout', data: null));

      // Assert
      expect(eventsReceived, equals(2));
    });

    test('should support filtering events by criteria', () {
      // Arrange
      bool adminLoginReceived = false;

      eventBus.onWhere(
        'userLogin',
        (JSEvent event) =>
            event.data is Map && (event.data as Map)['role'] == 'admin',
        (JSEvent event) {
          adminLoginReceived = true;
        },
      );

      // Act - regular user login (should not trigger)
      eventBus.publish(
        JSEvent(name: 'userLogin', data: {'userId': '123', 'role': 'user'}),
      );
      expect(adminLoginReceived, isFalse);

      // Act - admin login (should trigger)
      eventBus.publish(
        JSEvent(name: 'userLogin', data: {'userId': '456', 'role': 'admin'}),
      );

      // Assert
      expect(adminLoginReceived, isTrue);
    });
  });
}
