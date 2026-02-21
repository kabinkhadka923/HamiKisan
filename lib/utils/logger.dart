import 'dart:developer' as developer;
import '../core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum LogLevel { verbose, debug, info, warning, error, critical }

class Logger {
  static LogLevel _minLogLevel =
      (kReleaseMode && !AppConstants.enableDebugLogging)
          ? LogLevel.warning
          : LogLevel.verbose;
  static final List<LogEntry> _logHistory = [];
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss.SSS');

  static void setMinLogLevel(LogLevel level) => _minLogLevel = level;

  static Future<void> initialize() async {
    if (kDebugMode || AppConstants.enableDebugLogging) {
      setMinLogLevel(LogLevel.verbose);
      info('Logger initialized in debug mode', tag: 'System');
    } else {
      setMinLogLevel(LogLevel.warning);
      info('Logger initialized in release mode', tag: 'System');
    }
  }

  static void verbose(String message, {String? tag, Object? data}) {
    _log(LogLevel.verbose, message, tag: tag, data: data);
  }

  static void debug(String message, {String? tag, Object? data}) {
    _log(LogLevel.debug, message, tag: tag, data: data);
  }

  static void info(String message, {String? tag, Object? data}) {
    _log(LogLevel.info, message, tag: tag, data: data);
  }

  static void warning(String message,
      {String? tag, Object? data, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message,
        tag: tag, data: data, stackTrace: stackTrace);
  }

  static void error(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message,
        tag: tag, data: error, stackTrace: stackTrace);
  }

  static void critical(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.critical, message,
        tag: tag, data: error, stackTrace: stackTrace);
    if (kReleaseMode) _reportToCrashlytics(message, error, stackTrace);
  }

  static void performance(String operation, int durationMs) {
    _log(LogLevel.info, 'PERFORMANCE: $operation took ${durationMs}ms',
        tag: 'Performance');
  }

  static void _log(LogLevel level, String message,
      {String? tag, Object? data, StackTrace? stackTrace}) {
    if (level.index < _minLogLevel.index) return;

    final entry = LogEntry(
      level: level,
      message: message,
      tag: tag,
      data: data,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );

    _logHistory.add(entry);
    if (_logHistory.length > 1000) _logHistory.removeAt(0);

    _printToConsole(entry);

    if (kDebugMode && level.index >= LogLevel.warning.index) {
      developer.log(entry.toString(),
          name: tag ?? 'HamiKisan', error: data, stackTrace: stackTrace);
    }
  }

  static void _printToConsole(LogEntry entry) {
    if (!kDebugMode) return;

    final time = _timeFormat.format(entry.timestamp);
    final levelStr = _getLevelString(entry.level);
    final tagStr = entry.tag != null ? '[${entry.tag}] ' : '';
    final text =
        '${_getLevelEmoji(entry.level)} $time $levelStr $tagStr${entry.message}';

    debugPrint(text);
    if (entry.stackTrace != null &&
        entry.level.index >= LogLevel.error.index) {
      debugPrint(entry.stackTrace.toString());
    }
  }

  static String _getLevelString(LogLevel level) {
    return level.toString().split('.').last.toUpperCase();
  }

  static String _getLevelEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return '📋';
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return '✅';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🚨';
    }
  }

  static void _reportToCrashlytics(
      String message, Object? error, StackTrace? stackTrace) {
    // Integrate with your crash reporting service

  }

  static List<LogEntry> getLogHistory({int? limit}) {
    final logs = List<LogEntry>.from(_logHistory);
    return limit != null && limit < logs.length ? logs.sublist(0, limit) : logs;
  }

  static String exportLogs({int lastLines = 100}) {
    return getLogHistory(limit: lastLines).map((e) => e.toString()).join('\n');
  }
}

class LogEntry {
  final LogLevel level;
  final String message;
  final String? tag;
  final Object? data;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  LogEntry({
    required this.level,
    required this.message,
    this.tag,
    this.data,
    this.stackTrace,
    required this.timestamp,
  });

  @override
  String toString() {
    return '${DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(timestamp)} ${Logger._getLevelString(level)} ${tag != null ? '[$tag] ' : ''}$message';
  }
}
