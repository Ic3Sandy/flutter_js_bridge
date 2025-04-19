import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_js_bridge/src/debug/js_performance_monitor.dart';

void main() {
  group('JSPerformanceMonitor', () {
    late JSPerformanceMonitor monitor;

    setUp(() {
      monitor = JSPerformanceMonitor();
    });

    test('should track operation durations', () async {
      // Act
      final duration1 = await monitor.trackOperation('test-operation', () async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 'result';
      });
      
      final duration2 = await monitor.trackOperation('test-operation', () async {
        await Future.delayed(const Duration(milliseconds: 20));
        return 'result2';
      });

      // Assert
      expect(duration1, greaterThanOrEqualTo(const Duration(milliseconds: 10)));
      expect(duration2, greaterThanOrEqualTo(const Duration(milliseconds: 20)));
      
      final stats = monitor.getOperationStats('test-operation');
      expect(stats, isNotNull);
      expect(stats!.count, 2);
      expect(stats.totalDuration, duration1 + duration2);
      expect(stats.averageDuration, (duration1 + duration2) ~/ 2);
      expect(stats.minDuration, duration1);
      expect(stats.maxDuration, duration2);
    });

    test('should track sync operation durations', () {
      // Act
      final duration = monitor.trackSyncOperation('sync-operation', () {
        // Simulate work
        int sum = 0;
        for (int i = 0; i < 1000000; i++) {
          sum += i;
        }
        return sum;
      });

      // Assert
      expect(duration, greaterThan(Duration.zero));
      
      final stats = monitor.getOperationStats('sync-operation');
      expect(stats, isNotNull);
      expect(stats!.count, 1);
      expect(stats.totalDuration, duration);
      expect(stats.averageDuration, duration);
      expect(stats.minDuration, duration);
      expect(stats.maxDuration, duration);
    });

    test('should return null stats for unknown operations', () {
      // Act
      final stats = monitor.getOperationStats('unknown-operation');
      
      // Assert
      expect(stats, isNull);
    });

    test('should reset statistics', () async {
      // Arrange
      await monitor.trackOperation('test-operation', () async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 'result';
      });
      
      // Act
      monitor.resetStats();
      
      // Assert
      final stats = monitor.getOperationStats('test-operation');
      expect(stats, isNull);
    });

    test('should get all operation names', () async {
      // Arrange
      await monitor.trackOperation('operation1', () async {
        await Future.delayed(const Duration(milliseconds: 5));
        return 'result1';
      });
      
      await monitor.trackOperation('operation2', () async {
        await Future.delayed(const Duration(milliseconds: 5));
        return 'result2';
      });
      
      // Act
      final operations = monitor.getAllOperationNames();
      
      // Assert
      expect(operations, containsAll(['operation1', 'operation2']));
      expect(operations.length, 2);
    });

    test('should get all operation stats', () async {
      // Arrange
      await monitor.trackOperation('operation1', () async {
        await Future.delayed(const Duration(milliseconds: 5));
        return 'result1';
      });
      
      await monitor.trackOperation('operation2', () async {
        await Future.delayed(const Duration(milliseconds: 5));
        return 'result2';
      });
      
      // Act
      final allStats = monitor.getAllOperationStats();
      
      // Assert
      expect(allStats.keys, containsAll(['operation1', 'operation2']));
      expect(allStats.length, 2);
      expect(allStats['operation1']?.count, 1);
      expect(allStats['operation2']?.count, 1);
    });
  });
}
