import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'app_config_service.dart';

enum LogLevel { debug, info, warn, error }

class DebugLogModel {
  final String content;
  final DateTime datetime;
  final Color? color;
  DebugLogModel(this.datetime, this.content, {this.color});
}

class Log {
  // --- Singleton Setup ---
  static final Log _instance = Log._internal();
  static final RxList<DebugLogModel> debugLogs = <DebugLogModel>[].obs;
  factory Log() => _instance;
  Log._internal();

  // --- Configuration ---
  LogLevel _currentLevel = LogLevel.info;
  late final IOSink _fileSink;
  bool _isInitialized = false;
  String _logPath = '';
  String get logPath => _logPath;

  // ANSI escape codes for colors
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';

  Future<void> initialize() async {
    if (_isInitialized) return;

    final appDocsDir = await getApplicationSupportDirectory();
    _logPath = path.join(appDocsDir.path, 'logs');
    if (!Directory(_logPath).existsSync()) {
      Directory(_logPath).createSync(recursive: true);
    }
    final timestamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final logFile = File(path.join(_logPath, 'log_$timestamp.log'));
    _fileSink = logFile.openWrite(mode: FileMode.writeOnlyAppend);
    _isInitialized = true;
    _currentLevel = AppConfigService.instance.getLogLevel();
    info(
      'Logger initialized. Log level: ${_currentLevel.name}. Saving to: ${logFile.path}',
    );
  }

  void setLevel(LogLevel level) {
    _currentLevel = level;
    info('Log level set to ${_currentLevel.name}');
    AppConfigService.instance.setLogLevel(_currentLevel);
  }

  LogLevel get currentLevel => _currentLevel;

  void d(String message) =>
      _log(level: LogLevel.debug, message: message, color: _blue);
  void info(String message) {
    _log(
      level: LogLevel.info,
      message: message,
      color: _green,
      stackTrace: StackTrace.current,
    );
  }

  void warn(String message, {Object? error, StackTrace? stackTrace}) {
    _log(
      level: LogLevel.warn,
      message: message,
      color: _yellow,
      stackTrace: stackTrace,
    );
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    final fullMessage = error != null ? '$message\nError: $error' : message;
    _log(
      level: LogLevel.error,
      message: fullMessage,
      color: _red,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }

  Color getColor(LogLevel level) {
    switch (level) {
      case LogLevel.error:
        return Colors.red;
      case LogLevel.warn:
        return Colors.yellow;
      case LogLevel.info:
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  void _log({
    required LogLevel level,
    required String message,
    required String color,
    StackTrace? stackTrace,
  }) {
    if (level.index < _currentLevel.index) {
      return;
    }
    if (!kReleaseMode) {
      debugLogs.add(
        DebugLogModel(DateTime.now(), message, color: getColor(level)),
      );
    }
    String callerInfo = '';
    if (stackTrace != null) {
      if (level == LogLevel.error) {
        // For errors, append the full, cleaned stack trace
        final formattedStack = formatStackTrace(stackTrace, 20);
        message += '\nStack Trace:\n$formattedStack';
      } else if (level == LogLevel.info) {
        // For info, extract just the caller's location
        callerInfo = _getCallerInfo(stackTrace) ?? '';
      }
    }

    final timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
    final levelStr = level.name.toUpperCase().padRight(5);

    // Prepare messages
    final plainTextMessage = '$timestamp | $levelStr | $callerInfo$message';
    final coloredConsoleMessage =
        '$timestamp | $color$levelStr$_reset | $callerInfo$message';

    // Print to console
    // ignore: avoid_print
    print(coloredConsoleMessage);

    // Write to file
    _fileSink.writeln(plainTextMessage);
  }

  String? _getCallerInfo(StackTrace stackTrace) {
    final frames = stackTrace.toString().split('\n');
    final loggerFramePattern = RegExp(r'LoggerService\.');

    for (final frame in frames) {
      if (frame.contains('<asynchronous suspension>') ||
          loggerFramePattern.hasMatch(frame)) {
        continue;
      }

      // Instead of regex, find the start of the function call info.
      final openParen = frame.indexOf('(');
      if (openParen != -1) {
        final match = RegExp(r'\(([^\)]+)\)').firstMatch(frame);
        if (match != null) {
          return '[${match.group(1)}] ';
        }
      }
    }
    return null;
  }

  String formatStackTrace(StackTrace stackTrace, int maxLines) {
    var lines = stackTrace.toString().split('\n');
    lines.removeWhere(
      (line) =>
          line.contains('LoggerService.') ||
          line.contains('<asynchronous suspension>'),
    );
    if (lines.length > maxLines) {
      lines = lines.sublist(0, maxLines);
      lines.add('...');
    }
    return lines.map((line) => '  $line').join('\n');
  }

  Future<void> dispose() async {
    await _fileSink.flush();
    await _fileSink.close();
  }
}

class ModelLog {
  final String module;
  final bool enable;
  ModelLog(this.module, {this.enable = false});
  void info(String message) {
    if (enable) {
      logger.info('[$module] $message');
    }
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
      logger.error('[$module] $message', error: error, stackTrace: stackTrace);
  }

  void warn(String message) {
      logger.warn('[$module] $message');
  }

  void debug(String message) {
    if (enable) {
      logger.d('[$module] $message');
    }
  }
}

// Global instance for easy access
final logger = Log();
