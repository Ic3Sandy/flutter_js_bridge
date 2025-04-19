import 'package:flutter/foundation.dart';

/// Log levels for the JS Bridge logger
enum JSLogLevel {
  /// Detailed information, typically of interest only when diagnosing problems
  debug,

  /// Confirmation that things are working as expected
  info,

  /// Indication that something unexpected happened, but the application can continue
  warning,

  /// Serious error that might prevent the application from continuing
  error,
}

/// A record of a log entry in the JS Bridge
class JSLogRecord {
  /// The time at which the log entry was created
  final DateTime timestamp;

  /// The log level
  final JSLogLevel level;

  /// The log message
  final String message;

  /// Additional context information
  final Map<String, dynamic>? context;

  /// Error object if this is an error log
  final Object? error;

  /// Stack trace if this is an error log
  final StackTrace? stackTrace;

  /// Creates a new log record
  JSLogRecord({
    required this.timestamp,
    required this.level,
    required this.message,
    this.context,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('${timestamp.toIso8601String()} [${level.name.toUpperCase()}] $message');

    if (context != null && context!.isNotEmpty) {
      // Format context in a way that matches the test expectation
      final contextEntries = context!.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      buffer.write(' - Context: $contextEntries');
    }

    if (error != null) {
      buffer.write('\nError: $error');
    }

    if (stackTrace != null) {
      buffer.write('\nStack trace:\n$stackTrace');
    }

    return buffer.toString();
  }
}

/// A logger for the JS Bridge that provides different log levels and formatting
class JSBridgeLogger {
  /// The minimum log level to record
  final JSLogLevel logLevel;

  /// Callback function that is called when a log entry is created
  final void Function(JSLogRecord record)? onLog;

  /// Creates a new JS Bridge logger
  ///
  /// [logLevel] The minimum log level to record
  /// [onLog] Optional callback function that is called when a log entry is created
  JSBridgeLogger({
    this.logLevel = JSLogLevel.info,
    this.onLog,
  });

  /// Logs a debug message
  ///
  /// [message] The message to log
  /// [context] Optional context information
  void debug(String message, {Map<String, dynamic>? context}) {
    _log(JSLogLevel.debug, message, context: context);
  }

  /// Logs an info message
  ///
  /// [message] The message to log
  /// [context] Optional context information
  void info(String message, {Map<String, dynamic>? context}) {
    _log(JSLogLevel.info, message, context: context);
  }

  /// Logs a warning message
  ///
  /// [message] The message to log
  /// [context] Optional context information
  void warning(String message, {Map<String, dynamic>? context}) {
    _log(JSLogLevel.warning, message, context: context);
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
    _log(
      JSLogLevel.error,
      message,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Internal method to log a message
  void _log(
    JSLogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    // Skip if the log level is below the minimum
    if (level.index < logLevel.index) {
      return;
    }

    final record = JSLogRecord(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );

    // Call the onLog callback if provided
    onLog?.call(record);

    // In debug mode, also print to the console
    if (kDebugMode) {
      print(record.toString());
    }
  }
}
