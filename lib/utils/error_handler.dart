import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'logger.dart';

class ErrorHandler {
  static bool _isInitialized = false;
  static final List<ErrorListener> _listeners = [];
  static final StreamController<AppError> _errorStream =
      StreamController<AppError>.broadcast();

  static Future<void> initialize() async {
    if (_isInitialized) return;

    FlutterError.onError = (details) => _handleFlutterError(details);
    PlatformDispatcher.instance.onError = (error, stack) {
      _handleDartError(error, stack);
      return true;
    };

    runZonedGuarded(() {}, (error, stack) => _handleZoneError(error, stack));

    _isInitialized = true;
  }

  static void _handleFlutterError(FlutterErrorDetails details) {
    final error = AppError(
      type: ErrorType.flutter,
      message: details.exceptionAsString(),
      exception: details.exception,
      stackTrace: details.stack,
      context: details.context?.toString(),
      library: details.library,
      silent: false,
    );
    _processError(error);
    if (kDebugMode) FlutterError.presentError(details);
  }

  static void _handleDartError(Object error, StackTrace stack) {
    _processError(AppError(
      type: ErrorType.dart,
      message: error.toString(),
      exception: error,
      stackTrace: stack,
      silent: false,
    ));
  }

  static void _handleZoneError(Object error, StackTrace stack) {
    _processError(AppError(
      type: ErrorType.zone,
      message: error.toString(),
      exception: error,
      stackTrace: stack,
      silent: false,
    ));
  }

  static void _processError(AppError error) {
    _logError(error);
    for (final listener in _listeners) {
      try {
        listener(error);
      } catch (e) {
        // Ignore listener errors
      }
    }
    _errorStream.add(error);
    if (!kDebugMode && !error.silent) _sendToCrashReporting(error);
  }

  static void _logError(AppError error) {
    switch (error.severity) {
      case ErrorSeverity.info:
        Logger.info(error.message);
      case ErrorSeverity.warning:
        Logger.warning(error.message,
            data: error.exception, stackTrace: error.stackTrace);
      case ErrorSeverity.error:
        Logger.error(error.message,
            error: error.exception, stackTrace: error.stackTrace);
      case ErrorSeverity.critical:
        Logger.critical(error.message,
            error: error.exception, stackTrace: error.stackTrace);
    }
  }

  static void _sendToCrashReporting(AppError error) {
    if (kDebugMode) {
      // Don't send in debug mode
    }
    // Integrate with Firebase Crashlytics, Sentry, etc.
  }

  static void addListener(ErrorListener listener) {
    if (!_listeners.contains(listener)) _listeners.add(listener);
  }

  static void removeListener(ErrorListener listener) {
    _listeners.remove(listener);
  }

  static Stream<AppError> get errorStream => _errorStream.stream;

  static void recordError(Object error, StackTrace stack, {String? context}) {
    _processError(AppError(
      type: ErrorType.manual,
      message: error.toString(),
      exception: error,
      stackTrace: stack,
      context: context,
      silent: false,
    ));
  }
}

enum ErrorType { flutter, dart, zone, manual }

enum ErrorSeverity { info, warning, error, critical }

typedef ErrorListener = void Function(AppError error);

class AppError {
  final ErrorType type;
  final String message;
  final Object? exception;
  final StackTrace? stackTrace;
  final String? context;
  final String? library;
  final bool silent;

  AppError({
    required this.type,
    required this.message,
    this.exception,
    this.stackTrace,
    this.context,
    this.library,
    this.silent = false,
  });

  ErrorSeverity get severity {
    if (exception is! Exception) return ErrorSeverity.info;
    final msg = message.toLowerCase();
    if (msg.contains('network') || msg.contains('timeout')) {
      return ErrorSeverity.warning;
    }
    if (msg.contains('auth') || msg.contains('permission')) {
      return ErrorSeverity.error;
    }
    return ErrorSeverity.critical;
  }

  Map<String, dynamic> toJson() => {
        'type': type.toString(),
        'message': message,
        'exception': exception?.toString(),
        'context': context,
        'library': library,
        'timestamp': DateTime.now().toIso8601String(),
      };

  @override
  String toString() =>
      'AppError(type: $type, message: $message, severity: $severity)';
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final WidgetBuilder? errorBuilder;

  const ErrorBoundary({super.key, required this.child, this.errorBuilder});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(context) ?? _buildDefaultError();
    }
    return widget.child;
  }

  Widget _buildDefaultError() => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Something went wrong',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(_error.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() {
                  _error = null;
                }),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      setState(() {
        _error = details.exception;
      });
      Logger.error('Flutter Error',
          error: details.exception, stackTrace: details.stack);
    };
  }
}
