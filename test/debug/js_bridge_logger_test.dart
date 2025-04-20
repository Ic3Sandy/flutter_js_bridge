import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_js_bridge/flutter_js_bridge.dart';
import 'package:flutter_js_bridge/src/debug/js_bridge_logger.dart';

void main() {
  group('JSBridgeLogger', () {
    // Test fixtures
    const kDebugMessage = 'Debug message';
    const kInfoMessage = 'Info message';
    const kWarningMessage = 'Warning message';
    const kErrorMessage = 'Error message';
    final kTestContext = {'key': 'value'};
    final kTestError = Exception('Test error');
    
    // Test state
    late JSBridgeLogger logger;
    late List<JSLogRecord> capturedLogs;

    /// Creates a logger with the specified log level
    JSBridgeLogger createLogger(JSLogLevel logLevel) {
      return JSBridgeLogger(
        logLevel: logLevel,
        onLog: (record) => capturedLogs.add(record),
      );
    }
    
    setUp(() {
      capturedLogs = [];
      logger = createLogger(JSLogLevel.debug);
    });

    group('logging at different levels', () {
      test('should log messages at all levels when log level is debug', () {
        // Act
        logger.debug(kDebugMessage);
        logger.info(kInfoMessage);
        logger.warning(kWarningMessage);
        logger.error(kErrorMessage);

        // Assert
        expect(capturedLogs.length, 4, reason: 'Should capture all four log messages');
        
        expect(capturedLogs[0].level, JSLogLevel.debug, reason: 'First log should be at debug level');
        expect(capturedLogs[0].message, kDebugMessage, reason: 'First log should contain debug message');
        
        expect(capturedLogs[1].level, JSLogLevel.info, reason: 'Second log should be at info level');
        expect(capturedLogs[1].message, kInfoMessage, reason: 'Second log should contain info message');
        
        expect(capturedLogs[2].level, JSLogLevel.warning, reason: 'Third log should be at warning level');
        expect(capturedLogs[2].message, kWarningMessage, reason: 'Third log should contain warning message');

        expect(capturedLogs[3].level, JSLogLevel.error, reason: 'Fourth log should be at error level');
        expect(capturedLogs[3].message, kErrorMessage, reason: 'Fourth log should contain error message');
      });

      test('should filter logs below warning level when log level is warning', () {
        // Arrange
        logger = createLogger(JSLogLevel.warning);

        // Act
        logger.debug(kDebugMessage);
        logger.info(kInfoMessage);
        logger.warning(kWarningMessage);
        logger.error(kErrorMessage);

        // Assert
        expect(capturedLogs.length, 2, reason: 'Should only capture warning and error logs');

        expect(capturedLogs[0].level, JSLogLevel.warning, reason: 'First log should be at warning level');
        expect(capturedLogs[0].message, kWarningMessage, reason: 'First log should contain warning message');

        expect(capturedLogs[1].level, JSLogLevel.error, reason: 'Second log should be at error level');
        expect(capturedLogs[1].message, kErrorMessage, reason: 'Second log should contain error message');
      });

      test('should only log error messages when log level is error', () {
        // Arrange
        logger = createLogger(JSLogLevel.error);

        // Act
        logger.debug(kDebugMessage);
        logger.info(kInfoMessage);
        logger.warning(kWarningMessage);
        logger.error(kErrorMessage);

        // Assert
        expect(capturedLogs.length, 1, reason: 'Should only capture error logs');
        expect(capturedLogs[0].level, JSLogLevel.error, reason: 'Log should be at error level');
        expect(capturedLogs[0].message, kErrorMessage, reason: 'Log should contain error message');
      });
    });

    group('log context and errors', () {
      test('should include context in logs when provided', () {
        // Act
        logger.debug(kDebugMessage, context: kTestContext);

        // Assert
        expect(capturedLogs.length, 1, reason: 'Should capture the log message');
        expect(capturedLogs[0].context, kTestContext, reason: 'Log record should include the provided context');
      });

      test('should track errors when provided', () {
        // Act
        logger.error(kErrorMessage, error: kTestError);

        // Assert
        expect(capturedLogs.length, 1, reason: 'Should capture the error log');
        expect(capturedLogs[0].error, kTestError, reason: 'Log record should include the provided error');
      });

      test('should include error and stack trace in log records', () {
        // Arrange
        final error = Exception('Test error');
        StackTrace? stackTrace;
        try {
          throw error;
        } catch (e, st) {
          stackTrace = st;
        }

        // Act
        logger.error('Error occurred', error: error, stackTrace: stackTrace);

        // Assert
        expect(capturedLogs.length, 1, reason: 'Should capture the error log');
        expect(capturedLogs[0].error, error, reason: 'Log record should include the provided error');
        expect(capturedLogs[0].stackTrace, stackTrace, reason: 'Log record should include the provided stack trace');
      });
    });

    group('log record formatting', () {
      test('should format log record to string with all components', () {
        // Arrange
        final record = JSLogRecord(
          level: JSLogLevel.info,
          message: 'Test message',
          timestamp: DateTime(2023, 1, 1, 12, 0, 0),
          context: {'key': 'value'},
          error: Exception('Test error'),
        );

        // Act
        final result = record.toString();

        // Assert
        expect(result, contains('INFO'), reason: 'String representation should include the log level');
        expect(result, contains('Test message'), reason: 'String representation should include the message');
        expect(result, contains('2023-01-01'), reason: 'String representation should include the formatted date');
        expect(result, contains('12:00:00'), reason: 'String representation should include the formatted time');
        expect(result, contains('key: value'), reason: 'String representation should include the context');
        expect(result, contains('Exception: Test error'), reason: 'String representation should include the error');
      });

      test('should format log record without context and error', () {
        // Arrange
        final record = JSLogRecord(
          level: JSLogLevel.info,
          message: 'Test message',
          timestamp: DateTime(2023, 1, 1, 12, 0, 0),
        );

        // Act
        final result = record.toString();

        // Assert
        expect(result, contains('INFO'), reason: 'String representation should include the log level');
        expect(result, contains('Test message'), reason: 'String representation should include the message');
        expect(result, contains('2023-01-01'), reason: 'String representation should include the formatted date');
        expect(result, contains('12:00:00'), reason: 'String representation should include the formatted time');
        expect(result, isNot(contains('Context:')), reason: 'String representation should not include context section when no context is provided');
        expect(result, isNot(contains('Error:')), reason: 'String representation should not include error section when no error is provided');
      });
    });

    test('should include timestamp in logs', () {
      // Arrange
      final beforeTest = DateTime.now();
      
      // Act
      logger.debug(kDebugMessage);

      // Assert
      expect(capturedLogs.length, 1, reason: 'Should capture the log message');
      expect(capturedLogs[0].timestamp, isNotNull, reason: 'Log record should include a timestamp');
      
      // Use a more reliable timestamp comparison
      // The log timestamp should be after or equal to beforeTest and before or equal to afterTest
      final afterTest = DateTime.now();
      expect(
        capturedLogs[0].timestamp.isAfter(beforeTest.subtract(const Duration(seconds: 1))) &&
        capturedLogs[0].timestamp.isBefore(afterTest.add(const Duration(seconds: 1))),
        isTrue,
        reason: 'Log timestamp should be within a reasonable time range'
      );
    });
  });
}
