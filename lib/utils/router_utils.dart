import 'navigation_service.dart';

class RouterUtils {
  static String getCurrentRoute() {
    final uri = Uri.base;
    return uri.path.isEmpty ? '/' : uri.path;
  }

  static bool isAdminRoute() {
    final route = getCurrentRoute();
    return route.contains('admin') ||
        route.contains('kisan-admin') ||
        route.contains('real-admin');
  }

  static Map<String, String> getQueryParameters() {
    final uri = Uri.base;
    return uri.queryParameters;
  }

  static String? getQueryParameter(String key) {
    final uri = Uri.base;
    return uri.queryParameters[key];
  }

  static void navigateTo(String route, {Map<String, String>? queryParams}) {
    final uri = Uri(path: route, queryParameters: queryParams);
    NavigationService.pushNamed(uri.toString());
  }
}
