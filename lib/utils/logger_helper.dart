import 'package:logger/logger.dart';

/// Custom Logger Helper for the application
/// Uses the Logger package for better logging in development and production
class TLoggerHelper {
  // Private constructor to prevent instantiation
  TLoggerHelper._();

  // Logger instance with custom configuration
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // No stack trace for cleaner logs
      errorMethodCount: 5, // Stack trace for errors
      lineLength: 80, // Line length
      colors: true, // Colored output
      printEmojis: true, // Print emojis for log levels
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log an informational message
  static void info(String message) {
    _logger.i(message);
  }

  /// Log a debug message
  static void debug(String message) {
    _logger.d(message);
  }

  /// Log a warning message
  static void warning(String message) {
    _logger.w(message);
  }

  /// Log an error message with optional error object and stack trace
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log a verbose/trace message
  static void trace(String message) {
    _logger.t(message);
  }

  /// Log a fatal error message
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
