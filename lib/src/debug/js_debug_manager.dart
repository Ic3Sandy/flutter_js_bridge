import 'package:flutter_js_bridge/flutter_js_bridge.dart';
import 'package:flutter_js_bridge/src/debug/js_bridge_logger.dart';
import 'package:flutter_js_bridge/src/debug/js_debug_config.dart';
import 'package:flutter_js_bridge/src/debug/js_message_inspector.dart';
import 'package:flutter_js_bridge/src/debug/js_performance_monitor.dart';

/// A manager for debugging features in the JS Bridge
class JSDebugManager {
  /// The debug configuration
  JSDebugConfig _config;

  /// The logger for the JS Bridge
  late final JSBridgeLogger _logger;

  /// The message inspector for the JS Bridge
  late final JSMessageInspector _messageInspector;

  /// The performance monitor for the JS Bridge
  late final JSPerformanceMonitor _performanceMonitor;

  /// Creates a new debug manager with the specified configuration
  ///
  /// [config] The debug configuration
  /// [onLog] Optional callback function that is called when a log entry is created
  /// [onMessageInspected] Optional callback function that is called when a message is inspected
  JSDebugManager({
    JSDebugConfig? config,
    void Function(JSLogRecord record)? onLog,
    void Function(JSMessageRecord record)? onMessageInspected,
  }) : _config = config ?? const JSDebugConfig() {
    _logger = JSBridgeLogger(
      logLevel: _config.logLevel,
      onLog: onLog,
    );

    _messageInspector = JSMessageInspector(
      enabled: _config.isMessageInspectionEnabled,
      onMessageInspected: onMessageInspected,
    );

    _performanceMonitor = JSPerformanceMonitor();
  }

  /// Gets the current debug configuration
  JSDebugConfig get config => _config;

  /// Updates the debug configuration
  ///
  /// [config] The new debug configuration
  void updateConfig(JSDebugConfig config) {
    _config = config;
    _messageInspector.setEnabled(config.isMessageInspectionEnabled);
  }

  /// Gets the logger for the JS Bridge
  JSBridgeLogger get logger => _logger;

  /// Gets the message inspector for the JS Bridge
  JSMessageInspector get messageInspector => _messageInspector;

  /// Gets the performance monitor for the JS Bridge
  JSPerformanceMonitor get performanceMonitor => _performanceMonitor;

  /// Logs a debug message
  ///
  /// [message] The message to log
  /// [context] Optional context information
  void debug(String message, {Map<String, dynamic>? context}) {
    if (_config.isLoggingEnabled) {
      _logger.debug(message, context: context);
    }
  }

  /// Logs an info message
  ///
  /// [message] The message to log
  /// [context] Optional context information
  void info(String message, {Map<String, dynamic>? context}) {
    if (_config.isLoggingEnabled) {
      _logger.info(message, context: context);
    }
  }

  /// Logs a warning message
  ///
  /// [message] The message to log
  /// [context] Optional context information
  void warning(String message, {Map<String, dynamic>? context}) {
    if (_config.isLoggingEnabled) {
      _logger.warning(message, context: context);
    }
  }

  /// Logs an error message
  ///
  /// [message] The message to log
  /// [error] Optional error object
  /// [stackTrace] Optional stack trace
  /// [context] Optional context information
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    // Always log errors if error tracking is enabled, regardless of logging setting
    if (_config.isErrorTrackingEnabled) {
      _logger.error(
        message,
        error: error,
        stackTrace: stackTrace,
        context: context,
      );
    } else if (_config.isLoggingEnabled) {
      // Only log if general logging is enabled and error tracking is disabled
      _logger.error(
        message,
        error: error,
        stackTrace: stackTrace,
        context: context,
      );
    }
  }

  /// Records an outgoing message
  ///
  /// [message] The message that was sent
  void recordOutgoingMessage(JSMessage message) {
    if (_config.isMessageInspectionEnabled) {
      _messageInspector.recordOutgoingMessage(message);
    }
  }

  /// Records an incoming message
  ///
  /// [message] The message that was received
  void recordIncomingMessage(JSMessage message) {
    if (_config.isMessageInspectionEnabled) {
      _messageInspector.recordIncomingMessage(message);
    }
  }

  /// Tracks the duration of an asynchronous operation
  ///
  /// [operationName] The name of the operation to track
  /// [operation] The operation to track
  /// Returns the result of the operation
  Future<T> trackOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    if (_config.isPerformanceMonitoringEnabled) {
      return await _performanceMonitor.trackOperationWithResult(operationName, operation);
    } else {
      return operation();
    }
  }

  /// Tracks the duration of a synchronous operation
  ///
  /// [operationName] The name of the operation to track
  /// [operation] The operation to track
  /// Returns the result of the operation
  T trackSyncOperation<T>(
    String operationName,
    T Function() operation,
  ) {
    if (_config.isPerformanceMonitoringEnabled) {
      return _performanceMonitor.trackSyncOperationWithResult(operationName, operation);
    } else {
      return operation();
    }
  }

  /// Resets all debugging data
  void reset() {
    _messageInspector.clearHistory();
    _performanceMonitor.resetStats();
  }
}
