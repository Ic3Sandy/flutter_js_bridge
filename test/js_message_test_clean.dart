import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_js_bridge/flutter_js_bridge.dart';

/// Tests for the [JSMessage] class following Clean Code principles.
void main() {
  group('JSMessage', () {
    // Test fixtures
    const kTestId = 'test-id';
    const kTestAction = 'test-action';
    final kTestData = {'key': 'value'};
    const kExpectsResponse = true;
    const kIsResponse = false;
    
    /// Creates a test message with default test values
    JSMessage createTestMessage({
      String? id,
      String? action,
      dynamic data,
      bool? expectsResponse,
      bool? isResponse,
    }) {
      return JSMessage(
        id: id ?? kTestId,
        action: action ?? kTestAction,
        data: data ?? kTestData,
        expectsResponse: expectsResponse ?? kExpectsResponse,
        isResponse: isResponse ?? kIsResponse,
      );
    }

    group('constructor', () {
      test('should create a message with provided values', () {
        // Arrange & Act
        final message = createTestMessage();

        // Assert
        expect(message.id, kTestId, reason: 'ID should match provided value');
        expect(message.action, kTestAction, reason: 'Action should match provided value');
        expect(message.data, kTestData, reason: 'Data should match provided value');
        expect(message.expectsResponse, kExpectsResponse, reason: 'ExpectsResponse should match provided value');
        expect(message.isResponse, kIsResponse, reason: 'IsResponse should match provided value');
      });
      
      test('should throw ArgumentError when ID is empty', () {
        // Act & Assert
        expect(
          () => createTestMessage(id: ''),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Message ID cannot be empty',
          )),
          reason: 'Constructor should validate ID is not empty',
        );
      });
      
      test('should throw ArgumentError when action is empty', () {
        // Act & Assert
        expect(
          () => createTestMessage(action: ''),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Message action cannot be empty',
          )),
          reason: 'Constructor should validate action is not empty',
        );
      });
    });

    group('serialization', () {
      test('toJson/fromJson should correctly convert between message and JSON map', () {
        // Arrange
        final message = createTestMessage();

        // Act
        final json = message.toJson();
        final fromJson = JSMessage.fromJson(json);

        // Assert
        expect(fromJson.id, message.id, reason: 'ID should be preserved in serialization');
        expect(fromJson.action, message.action, reason: 'Action should be preserved in serialization');
        expect(fromJson.data, message.data, reason: 'Data should be preserved in serialization');
        expect(fromJson.expectsResponse, message.expectsResponse, 
            reason: 'ExpectsResponse should be preserved in serialization');
        expect(fromJson.isResponse, message.isResponse, 
            reason: 'IsResponse should be preserved in serialization');
      });

      test('toJsonString/fromJsonString should correctly convert between message and JSON string', () {
        // Arrange
        final message = createTestMessage();

        // Act
        final jsonString = message.toJsonString();
        final fromJsonString = JSMessage.fromJsonString(jsonString);

        // Assert
        expect(fromJsonString.id, message.id, reason: 'ID should be preserved in string serialization');
        expect(fromJsonString.action, message.action, reason: 'Action should be preserved in string serialization');
        expect(fromJsonString.data, message.data, reason: 'Data should be preserved in string serialization');
        expect(fromJsonString.expectsResponse, message.expectsResponse, 
            reason: 'ExpectsResponse should be preserved in string serialization');
        expect(fromJsonString.isResponse, message.isResponse, 
            reason: 'IsResponse should be preserved in string serialization');
      });

      test('should handle complex data types in JSON conversion', () {
        // Arrange
        final complexData = {
          'string': 'text',
          'number': 42,
          'boolean': true,
          'array': [1, 2, 3],
          'nested': {'a': 1, 'b': 2},
        };

        final message = createTestMessage(data: complexData);

        // Act
        final jsonString = message.toJsonString();
        final fromJsonString = JSMessage.fromJsonString(jsonString);

        // Assert
        expect(fromJsonString.data, complexData, 
            reason: 'Complex data structures should be preserved in serialization');
      });
    });

    group('edge cases', () {
      test('should handle null data in JSON conversion', () {
        // Arrange
        final message = JSMessage(
          id: 'null-test',
          action: 'null-action',
          data: null,
          expectsResponse: false,
          isResponse: false,
        );

        // Act
        final jsonString = message.toJsonString();
        final fromJsonString = JSMessage.fromJsonString(jsonString);

        // Assert
        expect(fromJsonString.data, null, reason: 'Null data should be preserved in serialization');
        expect(fromJsonString.isResponse, false, reason: 'isResponse should be preserved in serialization');
      });

      test('toString should return a formatted string representation', () {
        // Arrange
        final message = createTestMessage();

        // Act
        final result = message.toString();

        // Assert
        expect(result, contains(kTestId), reason: 'toString should include the message ID');
        expect(result, contains(kTestAction), reason: 'toString should include the action');
        expect(result, contains(kTestData.toString()), reason: 'toString should include the data');
        expect(result, contains(kExpectsResponse.toString()), 
            reason: 'toString should include expectsResponse value');
        expect(result, contains(kIsResponse.toString()), 
            reason: 'toString should include isResponse value');
      });

      test('copyWith should create a copy with specified changes', () {
        // Arrange
        final original = createTestMessage();
        const newId = 'new-id';
        const newAction = 'new-action';
        const newExpectsResponse = false;
        const newIsResponse = true;

        // Act
        final copy = original.copyWith(
          id: newId,
          action: newAction,
          expectsResponse: newExpectsResponse,
          isResponse: newIsResponse,
        );

        // Assert
        expect(copy.id, newId, reason: 'ID should be updated with the new value');
        expect(copy.action, newAction, reason: 'Action should be updated with the new value');
        expect(copy.data, kTestData, reason: 'Data should remain unchanged');
        expect(copy.expectsResponse, newExpectsResponse, 
            reason: 'ExpectsResponse should be updated with the new value');
        expect(copy.isResponse, newIsResponse, 
            reason: 'IsResponse should be updated with the new value');
      });

      test('equality operator should correctly compare two messages', () {
        // Arrange
        final message1 = createTestMessage();
        final message2 = createTestMessage(); // Same values
        final differentMessage = createTestMessage(id: 'different-id');

        // Assert
        expect(message1, equals(message2), 
            reason: 'Messages with the same values should be considered equal');
        expect(message1, isNot(equals(differentMessage)), 
            reason: 'Messages with different values should not be considered equal');
      });

      test('createResponse should create a response message with correct properties', () {
        // Arrange
        final original = createTestMessage();
        final responseData = {'result': 'success'};

        // Act
        final response = original.createResponse(responseData);

        // Assert
        expect(response.id, original.id, 
            reason: 'Response message should have the same ID as the original message');
        expect(response.action, 'response', 
            reason: 'Response message should have "response" as the action');
        expect(response.data, responseData, 
            reason: 'Response message should contain the provided response data');
        expect(response.expectsResponse, false, 
            reason: 'Response message should not expect a response');
        expect(response.isResponse, true, 
            reason: 'Response message should have isResponse set to true');
      });
    });
  });
}
