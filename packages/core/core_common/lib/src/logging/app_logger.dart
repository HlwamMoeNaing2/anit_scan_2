abstract interface class AppLogger {
  void debug(String message);

  void warn(String message, {Object? error, StackTrace? stackTrace});

  void error(String message, {Object? error, StackTrace? stackTrace});
}

final class SilentLogger implements AppLogger {
  const SilentLogger();

  @override
  void debug(String message) {}

  @override
  void warn(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}
