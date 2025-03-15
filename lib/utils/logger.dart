import 'package:logger/logger.dart';

final logger = Logger(
  level: Level.info,
  printer: PrefixPrinter(
    PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
    debug: '[APP DEBUG]',
    info: '[APP INFO]',
    warning: '[APP WARN]',
    error: '[APP ERROR]',
  ),
);