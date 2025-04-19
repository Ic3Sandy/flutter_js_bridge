import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_js_bridge/flutter_js_bridge.dart';
import 'package:flutter_js_bridge/src/debug/js_bridge_logger.dart';

void main() {
  group('JSBridgeLogger', () {
    late JSBridgeLogger logger;
    late List<JSLogRecord> capturedLogs;

    setUp(() {
      capturedLogs = [];
      logger = JSBridgeLogger(
        logLevel: JSLogLevel.debug,
        onLog: (record) => capturedLogs.add(record),
      );
    });

    test('should log messages at different levels', () {
      // Act
      logger.debug('Debug message');
      logger.info('Info message');
      logger.warning('Warning message');
      logger.error('Error message');

      // Assert
      expect(capturedLogs.length, 4);
      expect(capturedLogs[0].level, JSLogLevel.debug);
      expect(capturedLogs[0].message, 'Debug message');
      expect(capturedLogs[1].level, JSLogLevel.info);
      expect(capturedLogs[1].message, 'Info message');
      expect(capturedLogs[2].level, JSLogLevel.warning);
      expect(capturedLogs[2].message, 'Warning message');
      expect(capturedLogs[3].level, JSLogLevel.error);
      expect(capturedLogs[3].message, 'Error message');
    });

    test('should respect log level filtering', () {
      // Arrange
      logger = JSBridgeLogger(
        logLevel: JSLogLevel.warning,
        onLog: (record) => capturedLogs.add(record),
      );

      // Act
      logger.debug('Debug message');
      logger.info('Info message');
      logger.warning('Warning message');
      logger.error('Error message');

      // Assert
      expect(capturedLogs.length, 2);
      expect(capturedLogs[0].level, JSLogLevel.warning);
      expect(capturedLogs[0].message, 'Warning message');
      expect(capturedLogs[1].level, JSLogLevel.error);
      expect(capturedLogs[1].message, 'Error message');
    });

    test('should include timestamp in log records', () {
      // Act
      logger.info('Test message');

      // Assert
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0].timestamp, isA<DateTime>());
      expect(
        DateTime.now().difference(capturedLogs[0].timestamp).inSeconds,
        lessThan(1),
      );
    });

    test('should include context in log records', () {
      // Act
      logger.info('Test message', context: {'key': 'value'});

      // Assert
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0].context, {'key': 'value'});
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
      expect(capturedLogs.length, 1);
      expect(capturedLogs[0].error, error);
      expect(capturedLogs[0].stackTrace, stackTrace);
    });

    test('should format log records as strings', () {
      // Act
      logger.info('Test message', context: {'key': 'value'});
      final record = capturedLogs[0];
      final formatted = record.toString();

      // Assert
      expect(formatted, contains('[INFO]'));
      expect(formatted, contains('Test message'));
      expect(formatted, contains('key: value'));
      expect(formatted, contains(record.timestamp.toIso8601String()));
    });
  });
}
