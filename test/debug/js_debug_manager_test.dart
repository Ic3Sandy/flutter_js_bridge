import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_js_bridge/flutter_js_bridge.dart';
import 'package:flutter_js_bridge/src/debug/js_bridge_logger.dart';
import 'package:flutter_js_bridge/src/debug/js_debug_config.dart';
import 'package:flutter_js_bridge/src/debug/js_debug_manager.dart';
import 'package:flutter_js_bridge/src/debug/js_message_inspector.dart';

void main() {
  group('JSDebugManager', () {
    late JSDebugManager debugManager;
    late List<JSLogRecord> capturedLogs;
    late List<JSMessageRecord> capturedMessages;

    setUp(() {
      capturedLogs = [];
      capturedMessages = [];
      debugManager = JSDebugManager(
        config: JSDebugConfig(
          isLoggingEnabled: true,
          logLevel: JSLogLevel.debug,
          isMessageInspectionEnabled: true,
          isPerformanceMonitoringEnabled: true,
        ),
        onLog: (record) => capturedLogs.add(record),
        onMessageInspected: (record) => capturedMessages.add(record),
      );
    });

    test('should log messages at different levels', () {
      // Act
      debugManager.debug('Debug message');
      debugManager.info('Info message');
      debugManager.warning('Warning message');
      debugManager.error('Error message');

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

    test('should respect config for logging', () {
      // Arrange
      debugManager.updateConfig(JSDebugConfig(
        isLoggingEnabled: false,
      ));

      // Act
      debugManager.debug('Debug message');
      debugManager.info('Info message');
      debugManager.warning('Warning message');
      debugManager.error('Error message', error: Exception('Test error'));

      // Assert
      expect(capturedLogs.length, 1); // Only error is logged due to isErrorTrackingEnabled
      expect(capturedLogs[0].level, JSLogLevel.error);
      expect(capturedLogs[0].message, 'Error message');
      expect(capturedLogs[0].error, isA<Exception>());
    });

    test('should record messages when enabled', () {
      // Arrange
      final message = JSMessage(
        id: 'test-id',
        action: 'test-action',
        data: {'key': 'value'},
        expectsResponse: true,
      );

      // Act
      debugManager.recordOutgoingMessage(message);
      debugManager.recordIncomingMessage(message);

      // Assert
      expect(capturedMessages.length, 2);
      expect(capturedMessages[0].message, message);
      expect(capturedMessages[0].direction, JSMessageDirection.outgoing);
      expect(capturedMessages[1].message, message);
      expect(capturedMessages[1].direction, JSMessageDirection.incoming);
    });

    test('should not record messages when disabled', () {
      // Arrange
      debugManager.updateConfig(JSDebugConfig(
        isLoggingEnabled: true,
        isMessageInspectionEnabled: false,
      ));
      final message = JSMessage(
        id: 'test-id',
        action: 'test-action',
        data: {'key': 'value'},
      );

      // Act
      debugManager.recordOutgoingMessage(message);
      debugManager.recordIncomingMessage(message);

      // Assert
      expect(capturedMessages, isEmpty);
    });

    test('should track operation performance when enabled', () async {
      // Act
      final result = await debugManager.trackOperation('test-operation', () async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 'result';
      });

      // Assert
      expect(result, 'result');
      final stats = debugManager.performanceMonitor.getOperationStats('test-operation');
      expect(stats, isNotNull);
      expect(stats!.count, 1);
      expect(stats.operationName, 'test-operation');
    });

    test('should reset all debugging data', () {
      // Arrange
      final message = JSMessage(
        id: 'test-id',
        action: 'test-action',
        data: {'key': 'value'},
      );
      debugManager.recordOutgoingMessage(message);
      debugManager.trackSyncOperation('test-operation', () => 'result');

      // Act
      debugManager.reset();

      // Assert
      expect(debugManager.messageInspector.messageCount, 0);
      expect(debugManager.performanceMonitor.getOperationStats('test-operation'), isNull);
    });
  });
}
