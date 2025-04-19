import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_js_bridge/flutter_js_bridge.dart';


void main() {
  group('JSDebugManager', () {
    // Test fixtures
    const kDebugMessage = 'Debug message';
    const kInfoMessage = 'Info message';
    const kWarningMessage = 'Warning message';
    const kErrorMessage = 'Error message';
    final kTestContext = {'key': 'value'};
    final kTestError = Exception('Test error'); // Used in error tracking tests
    
    // Test state
    late JSDebugManager debugManager;
    late List<JSLogRecord> capturedLogs;
    late List<JSMessageRecord> capturedMessages;


    /// Creates a debug manager with specified configuration
    JSDebugManager createDebugManager({
      bool isLoggingEnabled = true,
      JSLogLevel logLevel = JSLogLevel.debug,
      bool isMessageInspectionEnabled = true,
      bool isPerformanceMonitoringEnabled = true,
      bool isErrorTrackingEnabled = true,
    }) {
      return JSDebugManager(
        config: JSDebugConfig(
          isLoggingEnabled: isLoggingEnabled,
          logLevel: logLevel,
          isMessageInspectionEnabled: isMessageInspectionEnabled,
          isPerformanceMonitoringEnabled: isPerformanceMonitoringEnabled,
          isErrorTrackingEnabled: isErrorTrackingEnabled,
        ),
        onLog: (record) => capturedLogs.add(record),
        onMessageInspected: (record) => capturedMessages.add(record),
      );
    }

    setUp(() {
      capturedLogs = [];
      capturedMessages = [];
      debugManager = createDebugManager();
    });

    group('configuration', () {
      test('should update config with new values', () {
        // Arrange
        const newConfig = JSDebugConfig(
          isLoggingEnabled: false,
          logLevel: JSLogLevel.error,
          isMessageInspectionEnabled: false,
          isPerformanceMonitoringEnabled: false,
          isErrorTrackingEnabled: false,
        );

        // Act
        debugManager.updateConfig(newConfig);

        // Assert
        expect(debugManager.config.isLoggingEnabled, false, reason: 'Logging enabled should be updated');
        expect(debugManager.config.logLevel, JSLogLevel.error, reason: 'Log level should be updated');
        expect(debugManager.config.isMessageInspectionEnabled, false, reason: 'Message inspection enabled should be updated');
        expect(debugManager.config.isPerformanceMonitoringEnabled, false, reason: 'Performance monitoring enabled should be updated');
        expect(debugManager.config.isErrorTrackingEnabled, false, reason: 'Error tracking enabled should be updated');
      });
    });

    group('logging', () {
      test('should log messages at different levels', () {
        // Act
        debugManager.debug(kDebugMessage);
        debugManager.info(kInfoMessage);
        debugManager.warning(kWarningMessage);
        debugManager.error(kErrorMessage);

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

      test('should include error in error logs', () {
        // Act
        debugManager.error(kErrorMessage, error: kTestError);
        
        // Assert
        expect(capturedLogs.length, 1, reason: 'Should capture the error log');
        expect(capturedLogs[0].level, JSLogLevel.error, reason: 'Log should be at error level');
        expect(capturedLogs[0].message, kErrorMessage, reason: 'Log should contain error message');
        expect(capturedLogs[0].error, kTestError, reason: 'Log should include the provided error');
      });

      test('should respect config for logging enabled/disabled', () {
        // Arrange
        debugManager.updateConfig(const JSDebugConfig(
          isLoggingEnabled: false,
          logLevel: JSLogLevel.debug,
          isMessageInspectionEnabled: true,
          isPerformanceMonitoringEnabled: true,
        ));

        // Act
        debugManager.debug(kDebugMessage);
        debugManager.info(kInfoMessage);

        // Assert
        expect(capturedLogs.isEmpty, true, reason: 'No logs should be captured when logging is disabled');
      });

      test('should include context in logs when provided', () {
        // Act
        debugManager.debug(kDebugMessage, context: kTestContext);

        // Assert
        expect(capturedLogs.length, 1, reason: 'Should capture the log message');
        expect(capturedLogs[0].context, kTestContext, reason: 'Log record should include the provided context');
      });
    });

    group('message inspection', () {
      test('should record messages when enabled', () {
        // Arrange
        final message = JSMessage(
          id: 'test-id',
          action: 'test-action',
          data: const {'key': 'value'},
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

      test('should respect config for message inspection enabled/disabled', () {
        // Arrange
        debugManager.updateConfig(const JSDebugConfig(
          isLoggingEnabled: true,
          logLevel: JSLogLevel.warning,
          isMessageInspectionEnabled: false,
          isPerformanceMonitoringEnabled: true,
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
        expect(capturedMessages.isEmpty, true, reason: 'No messages should be captured when message inspection is disabled');
      });
    });

    group('performance monitoring', () {
      test('should track async operation performance', () async {
        // Arrange
        const operationName = 'test-async-operation';
        const expectedResult = 'result';

        // Act
        final result = await debugManager.trackOperation(
          operationName,
          () async {
            await Future.delayed(const Duration(milliseconds: 10));
            return expectedResult;
          },
        );

        // Assert
        expect(result, expectedResult, reason: 'Operation should return the expected result');

        // Check if any operations were recorded
        final opStats = debugManager.performanceMonitor.getOperationStats(operationName);
        expect(opStats != null, isTrue, 
            reason: 'Should have recorded operation stats');
        
        expect(opStats!.count, 1, 
            reason: 'Operation should be counted once');
        expect(opStats.totalDuration.inMilliseconds >= 10, isTrue, 
            reason: 'Operation duration should be at least 10ms');
      });
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
