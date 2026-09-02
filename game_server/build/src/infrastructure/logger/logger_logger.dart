import 'package:logger/logger.dart';

import 'logger_provider.dart';

class LoggerLogger extends LoggerProvider {
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Should each log print contain a timestamp
    ),
  );
  @override
  void i(dynamic message) {
    _logger.i(message);
  }

  @override
  void d(dynamic message) {
    _logger.d(message);
  }

  @override
  void e(dynamic message) {
    _logger.e(message);
  }
}
