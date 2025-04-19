import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_js_bridge/flutter_js_bridge.dart';

/// Tests for the [JSEvent] class.
void main() {
  group('JSEvent', () {
    // Test fixtures
    const testEventName = 'test-event';
    final testEventData = {'key': 'value'};
    const testOrigin = 'https://example.com';
    const testIsMainFrame = true;
    
    test('constructor with all parameters - should create an event with proper values', () {
      // Arrange & Act
      final event = JSEvent(
        name: testEventName,
        data: testEventData,
        origin: testOrigin,
        isMainFrame: testIsMainFrame,
      );

      // Assert
      expect(event.name, testEventName);
      expect(event.data, testEventData);
      expect(event.origin, testOrigin);
      expect(event.isMainFrame, testIsMainFrame);
    });

    test('constructor with minimal parameters - should use default values', () {
      // Arrange & Act
      const minimalEventName = 'minimal-event';
      final event = JSEvent(name: minimalEventName);

      // Assert
      expect(event.name, minimalEventName);
      expect(event.data, null);
      expect(event.origin, null);
      expect(event.isMainFrame, true);
    });

    test('complex data - should handle complex data structures', () {
      // Arrange
      final complexData = {
        'string': 'text',
        'number': 42,
        'boolean': true,
        'array': [1, 2, 3],
        'nested': {'a': 1, 'b': 2},
      };

      // Act
      final event = JSEvent(name: 'complex-event', data: complexData);

      // Assert
      expect(event.data, complexData);
    });
    
    test('empty name - should throw ArgumentError', () {
      // Act & Assert
      expect(
        () => JSEvent(name: ''),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Event name cannot be empty',
        )),
      );
    });
    
    test('toString - should return a formatted string representation', () {
      // Arrange
      final event = JSEvent(
        name: testEventName,
        data: testEventData,
        origin: testOrigin,
      );
      
      // Act
      final result = event.toString();
      
      // Assert
      expect(result, contains(testEventName));
      expect(result, contains(testOrigin));
      expect(result, contains(testEventData.toString()));
    });
    
    test('copyWith - should create a copy with specified changes', () {
      // Arrange
      final original = JSEvent(
        name: testEventName,
        data: testEventData,
        origin: testOrigin,
      );
      
      // Act
      final copy = original.copyWith(
        name: 'new-name',
        isMainFrame: false,
      );
      
      // Assert
      expect(copy.name, 'new-name');
      expect(copy.data, testEventData);
      expect(copy.origin, testOrigin);
      expect(copy.isMainFrame, false);
    });
    
    test('equality - should correctly compare two events', () {
      // Arrange
      final event1 = JSEvent(
        name: testEventName,
        data: testEventData,
        origin: testOrigin,
      );
      
      final event2 = JSEvent(
        name: testEventName,
        data: testEventData,
        origin: testOrigin,
      );
      
      final differentEvent = JSEvent(
        name: 'different-name',
        data: testEventData,
        origin: testOrigin,
      );
      
      // Assert
      expect(event1, equals(event2));
      expect(event1, isNot(equals(differentEvent)));
    });
  });
}
