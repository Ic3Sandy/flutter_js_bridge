import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_js_bridge/flutter_js_bridge.dart';

/// Tests for the [JSMessage] class.
void main() {
  group('JSMessage', () {
    // Test fixtures
    const testId = 'test-id';
    const testAction = 'test-action';
    final testData = {'key': 'value'};
    const expectsResponse = true;

    JSMessage createTestMessage() {
      return JSMessage(
        id: testId,
        action: testAction,
        data: testData,
        expectsResponse: expectsResponse,
      );
    }

    test('constructor - should create a message with proper values', () {
      // Arrange & Act
      final message = createTestMessage();

      // Assert
      expect(message.id, testId);
      expect(message.action, testAction);
      expect(message.data, testData);
      expect(message.expectsResponse, expectsResponse);
    });

    test('toJson/fromJson - should convert between message and JSON map', () {
      // Arrange
      final message = createTestMessage();

      // Act
      final json = message.toJson();
      final fromJson = JSMessage.fromJson(json);

      // Assert
      expect(fromJson.id, message.id);
      expect(fromJson.action, message.action);
      expect(fromJson.data, message.data);
      expect(fromJson.expectsResponse, message.expectsResponse);
    });

    test(
      'toJsonString/fromJsonString - should convert between message and JSON string',
      () {
        // Arrange
        final message = createTestMessage();

        // Act
        final jsonString = message.toJsonString();
        final fromJsonString = JSMessage.fromJsonString(jsonString);

        // Assert
        expect(fromJsonString.id, message.id);
        expect(fromJsonString.action, message.action);
        expect(fromJsonString.data, message.data);
        expect(fromJsonString.expectsResponse, message.expectsResponse);
      },
    );

    test(
      'complex data - should handle complex data types in JSON conversion',
      () {
        // Arrange
        final complexData = {
          'string': 'text',
          'number': 42,
          'boolean': true,
          'array': [1, 2, 3],
          'nested': {'a': 1, 'b': 2},
        };

        final message = JSMessage(
          id: 'complex-id',
          action: 'complex-action',
          data: complexData,
          expectsResponse: true,
        );

        // Act
        final jsonString = message.toJsonString();
        final fromJsonString = JSMessage.fromJsonString(jsonString);

        // Assert
        expect(fromJsonString.data, complexData);
      },
    );

    test('null data - should handle null data in JSON conversion', () {
      // Arrange
      final message = JSMessage(
        id: 'null-test',
        action: 'null-action',
        data: null,
        expectsResponse: false,
      );

      // Act
      final jsonString = message.toJsonString();
      final fromJsonString = JSMessage.fromJsonString(jsonString);

      // Assert
      expect(fromJsonString.data, null);
    });

    group('validation', () {
      test('empty id - should throw ArgumentError', () {
        // Act & Assert
        expect(
          () => JSMessage(id: '', action: testAction),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Message ID cannot be empty',
            ),
          ),
        );
      });

      test('empty action - should throw ArgumentError', () {
        // Act & Assert
        expect(
          () => JSMessage(id: testId, action: ''),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Message action cannot be empty',
            ),
          ),
        );
      });
    });

    test('toString - should return a formatted string representation', () {
      // Arrange
      final message = createTestMessage();

      // Act
      final result = message.toString();

      // Assert
      expect(result, contains(testId));
      expect(result, contains(testAction));
      expect(result, contains(testData.toString()));
      expect(result, contains(expectsResponse.toString()));
    });

    test('copyWith - should create a copy with specified changes', () {
      // Arrange
      final original = createTestMessage();

      // Act
      final copy = original.copyWith(
        id: 'new-id',
        action: 'new-action',
        expectsResponse: false,
      );

      // Assert
      expect(copy.id, 'new-id');
      expect(copy.action, 'new-action');
      expect(copy.data, testData);
      expect(copy.expectsResponse, false);
    });

    test('equality - should correctly compare two messages', () {
      // Arrange
      final message1 = createTestMessage();
      final message2 = JSMessage(
        id: testId,
        action: testAction,
        data: testData,
        expectsResponse: expectsResponse,
      );
      final differentMessage = JSMessage(
        id: 'different-id',
        action: testAction,
        data: testData,
        expectsResponse: expectsResponse,
      );

      // Assert
      expect(message1, equals(message2));
      expect(message1, isNot(equals(differentMessage)));
    });

    test(
      'createResponse - should create a response message with correct properties',
      () {
        // Arrange
        final original = createTestMessage();
        final responseData = {'result': 'success'};

        // Act
        final response = original.createResponse(responseData);

        // Assert
        expect(response.id, original.id);
        expect(response.action, 'response');
        expect(response.data, responseData);
        expect(response.expectsResponse, false);
      },
    );
  });
}
