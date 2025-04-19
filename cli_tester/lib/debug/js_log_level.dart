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
