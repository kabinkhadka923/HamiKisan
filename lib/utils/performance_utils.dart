import 'logger.dart';

class PerformanceUtils {
  static Future<T> measure<T>(
      String operation, Future<T> Function() function) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await function();
      stopwatch.stop();
      Logger.performance(operation, stopwatch.elapsedMilliseconds);
      return result;
    } catch (error) {
      stopwatch.stop();
      Logger.error('Performance measurement failed',
          tag: 'Performance', error: error);
      rethrow;
    }
  }

  static T measureSync<T>(String operation, T Function() function) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = function();
      stopwatch.stop();
      Logger.performance(operation, stopwatch.elapsedMilliseconds);
      return result;
    } catch (error) {
      stopwatch.stop();
      Logger.error('Performance measurement failed',
          tag: 'Performance', error: error);
      rethrow;
    }
  }
}