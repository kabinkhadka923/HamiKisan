import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  static Future<T?> push<T>(Route<T> route) {
    return navigator?.push(route) ?? Future.value();
  }

  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigator?.pushNamed(routeName, arguments: arguments) ??
        Future.value();
  }

  static void pop<T>([T? result]) {
    navigator?.pop(result);
  }

  static Future<T?> pushReplacement<T>(Route<T> route) {
    return navigator?.pushReplacement(route) ?? Future.value();
  }

  static Future<T?> pushReplacementNamed<T>(String routeName,
      {Object? arguments}) {
    return navigator?.pushReplacementNamed(routeName, arguments: arguments) ??
        Future.value();
  }

  static Future<bool> maybePop<T>([T? result]) {
    return navigator?.maybePop(result) ?? Future.value(false);
  }

  static void popUntil(RoutePredicate predicate) {
    navigator?.popUntil(predicate);
  }
}
