import 'dart:async';

/// Statistics for a specific operation
class JSOperationStats {
  /// The name of the operation
  final String operationName;
  
  /// The number of times the operation was executed
  final int count;
  
  /// The total duration of all executions
  final Duration totalDuration;
  
  /// The minimum duration of any execution
  final Duration minDuration;
  
  /// The maximum duration of any execution
  final Duration maxDuration;
  
  /// The average duration of all executions
  final Duration averageDuration;

  /// Creates new operation statistics
  JSOperationStats({
    required this.operationName,
    required this.count,
    required this.totalDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.averageDuration,
  });

  @override
  String toString() {
    return 'JSOperationStats('
        'operationName: $operationName, '
        'count: $count, '
        'totalDuration: ${totalDuration.inMicroseconds}μs, '
        'minDuration: ${minDuration.inMicroseconds}μs, '
        'maxDuration: ${maxDuration.inMicroseconds}μs, '
        'averageDuration: ${averageDuration.inMicroseconds}μs)';
  }
}

/// A component that monitors the performance of operations in the JS Bridge
class JSPerformanceMonitor {
  /// Map of operation names to their durations
  final Map<String, List<Duration>> _operationDurations = {};

  /// Creates a new performance monitor
  JSPerformanceMonitor();

  /// Tracks the duration of an asynchronous operation and returns the operation result
  ///
  /// [operationName] The name of the operation to track
  /// [operation] The operation to track
  /// Returns the result of the operation
  Future<T> trackOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await operation();
      _recordDuration(operationName, stopwatch.elapsed);
      return result;
    } finally {
      stopwatch.stop();
    }
  }

  /// Tracks the duration of a synchronous operation and returns the operation result
  ///
  /// [operationName] The name of the operation to track
  /// [operation] The operation to track
  /// Returns the result of the operation
  T trackSyncOperation<T>(
    String operationName,
    T Function() operation,
  ) {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = operation();
      _recordDuration(operationName, stopwatch.elapsed);
      return result;
    } finally {
      stopwatch.stop();
    }
  }

  /// Records a duration for an operation
  void _recordDuration(String operationName, Duration duration) {
    _operationDurations.putIfAbsent(operationName, () => []).add(duration);
  }

  /// Gets statistics for a specific operation
  ///
  /// [operationName] The name of the operation to get statistics for
  /// Returns the statistics for the operation, or null if the operation has not been tracked
  JSOperationStats? getOperationStats(String operationName) {
    final durations = _operationDurations[operationName];
    
    if (durations == null || durations.isEmpty) {
      return null;
    }
    
    final count = durations.length;
    final totalDuration = durations.fold<Duration>(
      Duration.zero,
      (total, duration) => total + duration,
    );
    
    final minDuration = durations.reduce(
      (min, duration) => duration < min ? duration : min,
    );
    
    final maxDuration = durations.reduce(
      (max, duration) => duration > max ? duration : max,
    );
    
    final averageMicroseconds = totalDuration.inMicroseconds ~/ count;
    final averageDuration = Duration(microseconds: averageMicroseconds);
    
    return JSOperationStats(
      operationName: operationName,
      count: count,
      totalDuration: totalDuration,
      minDuration: minDuration,
      maxDuration: maxDuration,
      averageDuration: averageDuration,
    );
  }

  /// Gets the names of all tracked operations
  List<String> getAllOperationNames() {
    return List.unmodifiable(_operationDurations.keys);
  }

  /// Gets statistics for all tracked operations
  Map<String, JSOperationStats> getAllOperationStats() {
    final result = <String, JSOperationStats>{};
    
    for (final operationName in _operationDurations.keys) {
      final stats = getOperationStats(operationName);
      if (stats != null) {
        result[operationName] = stats;
      }
    }
    
    return result;
  }

  /// Resets all statistics
  void resetStats() {
    _operationDurations.clear();
  }
}
