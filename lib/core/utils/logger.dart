import 'package:logger/logger.dart';

/// App-wide logger. Use `appLog.d(...)`, `appLog.e(...)`, etc.
final appLog = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 100,
    colors: true,
    printEmojis: true,
  ),
  filter: ProductionFilter(),
);
