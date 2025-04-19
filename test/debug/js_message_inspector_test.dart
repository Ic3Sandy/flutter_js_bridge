import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_js_bridge/flutter_js_bridge.dart';

void main() {
  group('JSMessageInspector', () {
    late JSMessageInspector inspector;
    late List<JSMessageRecord> capturedMessages;

    setUp(() {
      capturedMessages = [];
      inspector = JSMessageInspector(
        onMessageInspected: (record) => capturedMessages.add(record),
        enabled: true,
      );
    });

    test('should record outgoing messages when enabled', () {
      // Arrange
      final message = JSMessage(
        id: 'test-id',
        action: 'test-action',
        data: {'key': 'value'},
        expectsResponse: true,
      );

      // Act
      inspector.recordOutgoingMessage(message);

      // Assert
      expect(capturedMessages.length, 1);
      expect(capturedMessages[0].message, message);
      expect(capturedMessages[0].direction, JSMessageDirection.outgoing);
      expect(capturedMessages[0].timestamp, isA<DateTime>());
    });

    test('should record incoming messages when enabled', () {
      // Arrange
      final message = JSMessage(
        id: 'test-id',
        action: 'test-action',
        data: {'key': 'value'},
        expectsResponse: false,
      );

      // Act
      inspector.recordIncomingMessage(message);

      // Assert
      expect(capturedMessages.length, 1);
      expect(capturedMessages[0].message, message);
      expect(capturedMessages[0].direction, JSMessageDirection.incoming);
      expect(capturedMessages[0].timestamp, isA<DateTime>());
    });

    test('should not record messages when disabled', () {
      // Arrange
      inspector = JSMessageInspector(
        onMessageInspected: (record) => capturedMessages.add(record),
        enabled: false,
      );
      final message = JSMessage(
        id: 'test-id',
        action: 'test-action',
        data: {'key': 'value'},
      );

      // Act
      inspector.recordOutgoingMessage(message);
      inspector.recordIncomingMessage(message);

      // Assert
      expect(capturedMessages, isEmpty);
    });

    test('should toggle enabled state', () {
      // Arrange
      final message = JSMessage(
        id: 'test-id',
        action: 'test-action',
        data: {'key': 'value'},
      );

      // Act - disable
      inspector.setEnabled(false);
      inspector.recordOutgoingMessage(message);
      
      // Assert
      expect(capturedMessages, isEmpty);
      
      // Act - enable
      inspector.setEnabled(true);
      inspector.recordOutgoingMessage(message);
      
      // Assert
      expect(capturedMessages.length, 1);
    });

    test('should include processing time for response messages', () {
      // Arrange
      final requestMessage = JSMessage(
        id: 'test-id',
        action: 'test-action',
        data: {'key': 'value'},
        expectsResponse: true,
      );
      final responseMessage = JSMessage(
        id: 'test-id',
        action: 'test-action-response',
        data: {'result': 'success'},
        isResponse: true,
      );

      // Act
      inspector.recordOutgoingMessage(requestMessage);
      // Simulate some processing time
      Future.delayed(const Duration(milliseconds: 10), () {
        inspector.recordIncomingMessage(responseMessage);
      });

      // Wait for the delayed action to complete
      return Future.delayed(const Duration(milliseconds: 20), () {
        // Assert
        expect(capturedMessages.length, 2);
        expect(capturedMessages[1].processingTimeMs, isNotNull);
        expect(capturedMessages[1].processingTimeMs, greaterThan(0));
      });
    });

    test('should clear message history', () {
      // Arrange
      final message = JSMessage(
        id: 'test-id',
        action: 'test-action',
        data: {'key': 'value'},
      );
      
      // Record some messages
      inspector.recordOutgoingMessage(message);
      inspector.recordIncomingMessage(message);
      
      // Act
      inspector.clearHistory();
      
      // Assert - this should test internal state, we'll need a getter in the implementation
      expect(inspector.messageCount, 0);
    });
  });
}
