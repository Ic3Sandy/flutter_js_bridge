import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_js_bridge/flutter_js_bridge.dart';

void main() {
  group('JSDebugConfig', () {
    test('should have default values', () {
      // Act
      const config = JSDebugConfig();
      
      // Assert
      expect(config.isLoggingEnabled, false);
      expect(config.logLevel, JSLogLevel.info);
      expect(config.isMessageInspectionEnabled, false);
      expect(config.isPerformanceMonitoringEnabled, false);
      expect(config.isErrorTrackingEnabled, true);
    });

    test('should be configurable via constructor', () {
      // Act
      const config = JSDebugConfig(
        isLoggingEnabled: true,
        logLevel: JSLogLevel.debug,
        isMessageInspectionEnabled: true,
        isPerformanceMonitoringEnabled: true,
        isErrorTrackingEnabled: false,
      );
      
      // Assert
      expect(config.isLoggingEnabled, true);
      expect(config.logLevel, JSLogLevel.debug);
      expect(config.isMessageInspectionEnabled, true);
      expect(config.isPerformanceMonitoringEnabled, true);
      expect(config.isErrorTrackingEnabled, false);
    });

    test('should be configurable via copyWith', () {
      // Arrange
      const config = JSDebugConfig();
      
      // Act
      final newConfig = config.copyWith(
        isLoggingEnabled: true,
        logLevel: JSLogLevel.debug,
        isMessageInspectionEnabled: true,
        isPerformanceMonitoringEnabled: true,
        isErrorTrackingEnabled: false,
      );
      
      // Assert
      expect(newConfig.isLoggingEnabled, true);
      expect(newConfig.logLevel, JSLogLevel.debug);
      expect(newConfig.isMessageInspectionEnabled, true);
      expect(newConfig.isPerformanceMonitoringEnabled, true);
      expect(newConfig.isErrorTrackingEnabled, false);
      
      // Original config should be unchanged
      expect(config.isLoggingEnabled, false);
      expect(config.logLevel, JSLogLevel.info);
      expect(config.isMessageInspectionEnabled, false);
      expect(config.isPerformanceMonitoringEnabled, false);
      expect(config.isErrorTrackingEnabled, true);
    });

    test('should support equality comparison', () {
      // Arrange
      const config1 = JSDebugConfig(
        isLoggingEnabled: true,
        logLevel: JSLogLevel.debug,
      );
      
      const config2 = JSDebugConfig(
        isLoggingEnabled: true,
        logLevel: JSLogLevel.debug,
      );
      
      const config3 = JSDebugConfig(
        isLoggingEnabled: true,
        logLevel: JSLogLevel.warning,
      );
      
      // Assert
      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('should convert to string representation', () {
      // Arrange
      const config = JSDebugConfig(
        isLoggingEnabled: true,
        logLevel: JSLogLevel.debug,
        isMessageInspectionEnabled: true,
      );
      
      // Act
      final string = config.toString();
      
      // Assert
      expect(string, contains('isLoggingEnabled: true'));
      expect(string, contains('logLevel: JSLogLevel.debug'));
      expect(string, contains('isMessageInspectionEnabled: true'));
      expect(string, contains('isPerformanceMonitoringEnabled: false'));
      expect(string, contains('isErrorTrackingEnabled: true'));
    });
  });
}
