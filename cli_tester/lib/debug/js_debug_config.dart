import 'package:flutter_js_bridge_cli_tester/debug/js_log_level.dart';

/// Configuration for debugging features in the JS Bridge
class JSDebugConfig {
  /// Whether logging is enabled
  final bool isLoggingEnabled;

  /// The minimum log level to record
  final JSLogLevel logLevel;

  /// Whether message inspection is enabled
  final bool isMessageInspectionEnabled;

  /// Whether performance monitoring is enabled
  final bool isPerformanceMonitoringEnabled;

  /// Whether error tracking is enabled
  final bool isErrorTrackingEnabled;

  /// Creates a new debug configuration
  ///
  /// [isLoggingEnabled] Whether logging is enabled
  /// [logLevel] The minimum log level to record
  /// [isMessageInspectionEnabled] Whether message inspection is enabled
  /// [isPerformanceMonitoringEnabled] Whether performance monitoring is enabled
  /// [isErrorTrackingEnabled] Whether error tracking is enabled
  const JSDebugConfig({
    this.isLoggingEnabled = false,
    this.logLevel = JSLogLevel.info,
    this.isMessageInspectionEnabled = false,
    this.isPerformanceMonitoringEnabled = false,
    this.isErrorTrackingEnabled = true,
  });

  /// Creates a copy of this configuration with the specified changes
  JSDebugConfig copyWith({
    bool? isLoggingEnabled,
    JSLogLevel? logLevel,
    bool? isMessageInspectionEnabled,
    bool? isPerformanceMonitoringEnabled,
    bool? isErrorTrackingEnabled,
  }) {
    return JSDebugConfig(
      isLoggingEnabled: isLoggingEnabled ?? this.isLoggingEnabled,
      logLevel: logLevel ?? this.logLevel,
      isMessageInspectionEnabled:
          isMessageInspectionEnabled ?? this.isMessageInspectionEnabled,
      isPerformanceMonitoringEnabled:
          isPerformanceMonitoringEnabled ?? this.isPerformanceMonitoringEnabled,
      isErrorTrackingEnabled:
          isErrorTrackingEnabled ?? this.isErrorTrackingEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JSDebugConfig &&
        other.isLoggingEnabled == isLoggingEnabled &&
        other.logLevel == logLevel &&
        other.isMessageInspectionEnabled == isMessageInspectionEnabled &&
        other.isPerformanceMonitoringEnabled == isPerformanceMonitoringEnabled &&
        other.isErrorTrackingEnabled == isErrorTrackingEnabled;
  }

  @override
  int get hashCode {
    return isLoggingEnabled.hashCode ^
        logLevel.hashCode ^
        isMessageInspectionEnabled.hashCode ^
        isPerformanceMonitoringEnabled.hashCode ^
        isErrorTrackingEnabled.hashCode;
  }

  @override
  String toString() {
    return 'JSDebugConfig('
        'isLoggingEnabled: $isLoggingEnabled, '
        'logLevel: JSLogLevel.${logLevel.name}, '
        'isMessageInspectionEnabled: $isMessageInspectionEnabled, '
        'isPerformanceMonitoringEnabled: $isPerformanceMonitoringEnabled, '
        'isErrorTrackingEnabled: $isErrorTrackingEnabled)';
  }
}
