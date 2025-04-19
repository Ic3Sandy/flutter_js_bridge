import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_js_bridge/src/js_bridge_controller.dart';
import 'package:flutter_js_bridge/src/js_event.dart';
import 'package:flutter_js_bridge/src/event_bus/js_event_bus.dart';
import 'package:flutter_js_bridge/src/event_bus/js_event_interface.dart';

import 'js_event_bus_test.mocks.dart';

@GenerateMocks([JSBridgeController])
void main() {
  late MockJSBridgeController mockController;
  late JSEventBus eventBus;

  setUp(() {
    mockController = MockJSBridgeController();
    
    // Setup the mock to capture the event handler function
    when(mockController.registerHandler(any, any))
        .thenReturn(null);
        
    eventBus = JSEventBus(mockController);
  });

  tearDown(() {
    eventBus.dispose();
  });

  group('JSEventBus - Construction', () {
    test('should register event handler with controller on creation', () {
      verify(mockController.registerHandler('event', any)).called(1);
    });

    test('should unregister event handler on dispose', () {
      eventBus.dispose();
      verify(mockController.unregisterHandler('event')).called(1);
    });
  });

  group('JSEventBus - Subscriptions', () {
    test('should allow subscribing to events by name', () {
      // Arrange & Act
      final subscription = eventBus.on('userLogin', (_) {});
      
      // Assert
      expect(subscription, isNotNull);
      expect(eventBus.hasSubscribers('userLogin'), isTrue);
    });

    test('should allow subscribing to all events with onAny', () {
      // Arrange & Act
      final subscription = eventBus.onAny((_) {});
      
      // Assert
      expect(subscription, isNotNull);
      expect(eventBus.hasSubscribers('anyEvent'), isTrue);
    });

    test('should allow subscribing with filters using onWhere', () {
      // Arrange & Act
      final subscription = eventBus.onWhere(
        'userLogin', 
        (event) => event.data is Map && (event.data as Map)['role'] == 'admin',
        (_) {}
      );
      
      // Assert
      expect(subscription, isNotNull);
      expect(eventBus.hasSubscribers('userLogin'), isTrue);
    });

    test('should allow unsubscribing from events', () {
      // Arrange
      final subscription = eventBus.on('userLogin', (_) {});
      expect(eventBus.hasSubscribers('userLogin'), isTrue);
      
      // Act
      subscription.cancel();
      
      // Assert
      expect(eventBus.hasSubscribers('userLogin'), isFalse);
    });
  });

  group('JSEventBus - Event Handling', () {
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
      
      // Act - simulate event from JavaScript
      final args = [{'name': 'userLogin', 'data': {'userId': '123'}}];
      
      // Extract the handler that was registered
      final handler = verify(mockController.registerHandler('event', captureAny))
          .captured.first as Function;
      
      // Call the handler directly
      handler(args);
      
      // Assert
      expect(loginEventReceived, isTrue);
      expect(logoutEventReceived, isFalse);
    });

    test('should support wildcard subscriptions', () {
      // Arrange
      int eventsReceived = 0;
      final events = <String>[];
      
      eventBus.onAny((JSEvent event) {
        eventsReceived++;
        events.add(event.name);
      });
      
      // Act - simulate multiple events from JavaScript
      final loginArgs = [{'name': 'userLogin', 'data': {'userId': '123'}}];
      final logoutArgs = [{'name': 'userLogout', 'data': null}];
      
      // Extract the handler that was registered
      final handler = verify(mockController.registerHandler('event', captureAny))
          .captured.first as Function;
      
      // Call the handler directly with different events
      handler(loginArgs);
      handler(logoutArgs);
      
      // Assert
      expect(eventsReceived, equals(2));
      expect(events, containsAll(['userLogin', 'userLogout']));
    });

    test('should support filtering events by criteria', () {
      // Arrange
      bool adminLoginReceived = false;
      
      eventBus.onWhere(
        'userLogin', 
        (event) => event.data is Map && (event.data as Map)['role'] == 'admin',
        (event) {
          adminLoginReceived = true;
        }
      );
      
      // Act - simulate regular user login (should not trigger)
      final userArgs = [{'name': 'userLogin', 'data': {'userId': '123', 'role': 'user'}}];
      final adminArgs = [{'name': 'userLogin', 'data': {'userId': '456', 'role': 'admin'}}];
      
      // Extract the handler that was registered
      final handler = verify(mockController.registerHandler('event', captureAny))
          .captured.first as Function;
      
      // Call the handler with user login (should not trigger)
      handler(userArgs);
      expect(adminLoginReceived, isFalse);
      
      // Call the handler with admin login (should trigger)
      handler(adminArgs);
      
      // Assert
      expect(adminLoginReceived, isTrue);
    });
  });

  group('JSEventBus - Event Publishing', () {
    test('should publish events to JavaScript', () {
      // Arrange
      final event = JSEvent(name: 'userLogin', data: {'userId': '123'});
      
      // Act
      eventBus.publish(event);
      
      // Assert
      verify(mockController.sendToJavaScript('event', data: {
        'name': 'userLogin',
        'data': {'userId': '123'},
        'isMainFrame': true,
      })).called(1);
    });

    test('should notify local subscribers when publishing events', () {
      // Arrange
      bool eventReceived = false;
      eventBus.on('userLogin', (event) {
        eventReceived = true;
        expect(event.name, equals('userLogin'));
        expect(event.data, equals({'userId': '123'}));
      });
      
      // Act
      eventBus.publish(JSEvent(name: 'userLogin', data: {'userId': '123'}));
      
      // Assert
      expect(eventReceived, isTrue);
    });
  });

  group('JSEventBus - Streams', () {
    test('should provide a stream of all events', () async {
      // Arrange
      final receivedEvents = <JSEvent>[];
      final subscription = eventBus.eventStream.listen((event) {
        receivedEvents.add(event);
      });
      
      // Act - simulate events from JavaScript
      final loginArgs = [{'name': 'userLogin', 'data': {'userId': '123'}}];
      final logoutArgs = [{'name': 'userLogout', 'data': null}];
      
      // Extract the handler that was registered
      final handler = verify(mockController.registerHandler('event', captureAny))
          .captured.first as Function;
      
      // Call the handler directly with different events
      handler(loginArgs);
      handler(logoutArgs);
      
      // Wait for stream events to be processed
      await Future.delayed(Duration.zero);
      
      // Cleanup
      subscription.cancel();
      
      // Assert
      expect(receivedEvents.length, equals(2));
      expect(receivedEvents[0].name, equals('userLogin'));
      expect(receivedEvents[1].name, equals('userLogout'));
    });

    test('should provide filtered streams for specific events', () async {
      // Arrange
      final receivedEvents = <JSEvent>[];
      final subscription = eventBus.eventStreamOf('userLogin').listen((event) {
        receivedEvents.add(event);
      });
      
      // Act - simulate events from JavaScript
      final loginArgs = [{'name': 'userLogin', 'data': {'userId': '123'}}];
      final logoutArgs = [{'name': 'userLogout', 'data': null}];
      final loginArgs2 = [{'name': 'userLogin', 'data': {'userId': '456'}}];
      
      // Extract the handler that was registered
      final handler = verify(mockController.registerHandler('event', captureAny))
          .captured.first as Function;
      
      // Call the handler directly with different events
      handler(loginArgs);
      handler(logoutArgs);
      handler(loginArgs2);
      
      // Wait for stream events to be processed
      await Future.delayed(Duration.zero);
      
      // Cleanup
      subscription.cancel();
      
      // Assert
      expect(receivedEvents.length, equals(2));
      expect(receivedEvents[0].name, equals('userLogin'));
      expect(receivedEvents[1].name, equals('userLogin'));
      expect(receivedEvents[0].data, equals({'userId': '123'}));
      expect(receivedEvents[1].data, equals({'userId': '456'}));
    });
  });

  group('JSEventBus - Error Handling', () {
    test('should throw when using a disposed event bus', () {
      // Arrange
      eventBus.dispose();
      
      // Act & Assert
      expect(() => eventBus.on('test', (_) {}), throwsStateError);
      expect(() => eventBus.onAny((_) {}), throwsStateError);
      expect(() => eventBus.onWhere('test', (_) => true, (_) {}), throwsStateError);
      expect(() => eventBus.publish(JSEvent(name: 'test', data: null)), throwsStateError);
      expect(() => eventBus.hasSubscribers('test'), throwsStateError);
      expect(() => eventBus.eventStream, throwsStateError);
      expect(() => eventBus.eventStreamOf('test'), throwsStateError);
    });
  });
}
