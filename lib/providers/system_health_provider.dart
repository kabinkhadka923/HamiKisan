import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/system_health_models.dart';

class SystemHealthProvider extends ChangeNotifier {
  static SystemHealthProvider? _instance;

  factory SystemHealthProvider() {
    _instance ??= SystemHealthProvider._internal();
    return _instance!;
  }

  SystemHealthProvider._internal() {
    _initialize();
  }

  // Services to monitor
  final Map<String, ServiceStatus> _services = {
    'weather_api': ServiceStatus(
      serviceName: 'Weather API',
      serviceId: 'weather_api',
      status: HealthStatus.unknown,
      lastChecked: DateTime.now(),
      endpoint: 'https://api.weatherapi.com/v1/current.json',
      isCritical: true,
    ),
    'market_api': ServiceStatus(
      serviceName: 'Market API',
      serviceId: 'market_api',
      status: HealthStatus.unknown,
      lastChecked: DateTime.now(),
      endpoint: 'https://kalimati.gov.np/api',
      isCritical: true,
    ),
    'firebase_auth': ServiceStatus(
      serviceName: 'Firebase Auth',
      serviceId: 'firebase_auth',
      status: HealthStatus.unknown,
      lastChecked: DateTime.now(),
      endpoint: 'Firebase Authentication',
      isCritical: true,
    ),
    'firestore_db': ServiceStatus(
      serviceName: 'Firestore Database',
      serviceId: 'firestore_db',
      status: HealthStatus.unknown,
      lastChecked: DateTime.now(),
      endpoint: 'Cloud Firestore',
      isCritical: true,
    ),
    'chat_socket': ServiceStatus(
      serviceName: 'Chat WebSocket',
      serviceId: 'chat_socket',
      status: HealthStatus.unknown,
      lastChecked: DateTime.now(),
      endpoint: 'wss://yourdomain.com/chat',
      isCritical: false,
    ),
    'notification_socket': ServiceStatus(
      serviceName: 'Notification Socket',
      serviceId: 'notification_socket',
      status: HealthStatus.unknown,
      lastChecked: DateTime.now(),
      endpoint: 'wss://yourdomain.com/notify',
      isCritical: false,
    ),
  };

  final List<HealthLog> _healthLogs = [];
  Timer? _autoCheckTimer;
  bool _isInitialized = false;

  // Getters
  SystemHealthSummary get summary {
    final servicesList = _services.values.toList();
    final healthy =
        servicesList.where((s) => s.status == HealthStatus.healthy).length;
    final degraded =
        servicesList.where((s) => s.status == HealthStatus.degraded).length;
    final failed =
        servicesList.where((s) => s.status == HealthStatus.failed).length;
    final criticalFailures = servicesList
        .where((s) => s.status == HealthStatus.failed && s.isCritical)
        .toList();

    HealthStatus overall = HealthStatus.healthy;
    if (failed > 0) {
      overall = HealthStatus.failed;
    } else if (degraded > 0) overall = HealthStatus.degraded;

    return SystemHealthSummary(
      totalServices: _services.length,
      healthyServices: healthy,
      degradedServices: degraded,
      failedServices: failed,
      overallStatus: overall,
      lastFullCheck: DateTime.now(),
      criticalFailures: criticalFailures,
    );
  }

  List<ServiceStatus> get services => _services.values.toList();
  List<HealthLog> get logs => List.unmodifiable(_healthLogs);

  Future<void> _initialize() async {
    if (_isInitialized) return;

    await _loadServiceStates();
    _startAutoHealthChecks();
    _isInitialized = true;
  }

  // Public Methods
  Future<void> checkAllServices({bool force = false}) async {
    _logHealthCheck('Starting full system health check');

    try {
      await Future.wait([
        _checkWeatherApi(),
        _checkMarketApi(),
        _checkFirebaseAuth(),
        _checkFirestore(),
        _checkChatSocket(),
        _checkNotificationSocket(),
      ], eagerError: false);
    } catch (e) {
      _logHealthCheck('Error during full check: $e');
    }

    await _saveServiceStates();
    notifyListeners();
    _checkForCriticalFailures();
  }

  Future<void> checkService(String serviceId) async {
    try {
      switch (serviceId) {
        case 'weather_api':
          await _checkWeatherApi();
          break;
        case 'market_api':
          await _checkMarketApi();
          break;
        case 'firebase_auth':
          await _checkFirebaseAuth();
          break;
        case 'firestore_db':
          await _checkFirestore();
          break;
        case 'chat_socket':
          await _checkChatSocket();
          break;
        case 'notification_socket':
          await _checkNotificationSocket();
          break;
      }
    } catch (e) {
      _logHealthCheck('Error checking $serviceId: $e',
          serviceId: serviceId, error: e.toString());
    }

    await _saveServiceStates();
    notifyListeners();
  }

  Future<void> reconnectSocket(String serviceId) async {
    _logHealthCheck('Manual socket reconnect triggered', serviceId: serviceId);

    try {
      if (serviceId == 'chat_socket') {
        // Implement socket reconnection
        // await SocketService.instance.reconnect();
      } else if (serviceId == 'notification_socket') {
        // await NotificationSocketService.instance.reconnect();
      }

      // Re-check after reconnect
      await Future.delayed(const Duration(seconds: 2));
      await checkService(serviceId);
    } catch (e) {
      _logHealthCheck('Socket reconnect failed: $e',
          serviceId: serviceId, error: e.toString());
    }
  }

  Future<void> toggleService(String serviceId, bool enabled) async {
    final service = _services[serviceId];
    if (service != null) {
      _updateService(
        serviceId,
        status: enabled ? HealthStatus.unknown : HealthStatus.failed,
        metadata: {'maintenanceMode': !enabled},
      );
      _logHealthCheck(
        'Service ${enabled ? 'enabled' : 'disabled'}',
        serviceId: serviceId,
      );
      await _saveServiceStates();
      notifyListeners();
    }
  }

  // Service-specific check implementations
  Future<void> _checkWeatherApi() async {
    final stopwatch = Stopwatch()..start();
    try {
      // Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate API call

      _updateService(
        'weather_api',
        status: HealthStatus.healthy,
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      _updateService(
        'weather_api',
        status: HealthStatus.failed,
        latencyMs: stopwatch.elapsedMilliseconds,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _checkMarketApi() async {
    final stopwatch = Stopwatch()..start();
    try {
      // Simulate market API check
      await Future.delayed(const Duration(milliseconds: 500));

      _updateService(
        'market_api',
        status: HealthStatus.healthy,
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      _updateService(
        'market_api',
        status: HealthStatus.failed,
        latencyMs: stopwatch.elapsedMilliseconds,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _checkChatSocket() async {
    try {
      final stopwatch = Stopwatch()..start();

       // Check socket connection
      // final isConnected = SocketService.instance.isConnected;

       _updateService(
         'chat_socket',
         status: HealthStatus.failed,
         latencyMs: stopwatch.elapsedMilliseconds,
         metadata: {
           'lastCheck': DateTime.now().toString(),
        },
      );
    } catch (e) {
      _updateService(
        'chat_socket',
        status: HealthStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _checkNotificationSocket() async {
    try {
      final stopwatch = Stopwatch()..start();

      // Check notification socket connection
      _updateService(
        'notification_socket',
        status: HealthStatus.failed,
        latencyMs: stopwatch.elapsedMilliseconds,
        metadata: {
          'lastCheck': DateTime.now().toString(),
        },
      );
    } catch (e) {
      _updateService(
        'notification_socket',
        status: HealthStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _checkFirebaseAuth() async {
    final stopwatch = Stopwatch()..start();
    try {
      // Simulate Firebase Auth check
      await Future.delayed(const Duration(milliseconds: 200));

      _updateService(
        'firebase_auth',
        status: HealthStatus.healthy,
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      _updateService(
        'firebase_auth',
        status: HealthStatus.failed,
        latencyMs: stopwatch.elapsedMilliseconds,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _checkFirestore() async {
    final stopwatch = Stopwatch()..start();
    try {
      // Simulate Firestore check
      await Future.delayed(const Duration(milliseconds: 400));

      _updateService(
        'firestore_db',
        status: HealthStatus.healthy,
        latencyMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      _updateService(
        'firestore_db',
        status: HealthStatus.failed,
        latencyMs: stopwatch.elapsedMilliseconds,
        errorMessage: e.toString(),
      );
    }
  }

  // Helper methods
  void _updateService(
    String serviceId, {
    required HealthStatus status,
    int? latencyMs,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    final service = _services[serviceId];
    if (service != null) {
      _services[serviceId] = ServiceStatus(
        serviceName: service.serviceName,
        serviceId: service.serviceId,
        status: status,
        latencyMs: latencyMs ?? service.latencyMs,
        lastChecked: DateTime.now(),
        lastSuccess: status == HealthStatus.healthy
            ? DateTime.now()
            : service.lastSuccess,
        errorMessage: errorMessage,
        endpoint: service.endpoint,
        isCritical: service.isCritical,
        retryCount: status == HealthStatus.failed ? service.retryCount + 1 : 0,
        metadata: {...service.metadata, ...?metadata},
      );

      _logHealthCheck(
        '${service.serviceName}: ${status.toString()}',
        serviceId: serviceId,
        error: errorMessage,
      );
    }
  }

  void _logHealthCheck(String message, {String? serviceId, String? error}) {
    final log = HealthLog(
      timestamp: DateTime.now(),
      serviceId: serviceId,
      action: HealthAction.healthCheck,
      message: message,
      error: error,
      deviceInfo: 'Mobile', // Get from device info
    );

    _healthLogs.insert(0, log);
    if (_healthLogs.length > 1000) {
      _healthLogs.removeLast();
    }
  }

  Future<void> _saveServiceStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final servicesJson = _services.values
          .map((s) => json.encode({
                'serviceId': s.serviceId,
                'status': s.status.index,
                'latencyMs': s.latencyMs,
                'lastChecked': s.lastChecked.toIso8601String(),
                'lastSuccess': s.lastSuccess?.toIso8601String(),
                'retryCount': s.retryCount,
              }))
          .toList();

      await prefs.setStringList('system_health_services', servicesJson);
    } catch (e) {
      print('Error saving service states: $e');
    }
  }

  Future<void> _loadServiceStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final servicesJson = prefs.getStringList('system_health_services') ?? [];

      for (final jsonString in servicesJson) {
        final data = json.decode(jsonString);
        final serviceId = data['serviceId'] as String;
        if (_services.containsKey(serviceId)) {
          final service = _services[serviceId]!;
          _services[serviceId] = ServiceStatus(
            serviceName: service.serviceName,
            serviceId: service.serviceId,
            status: HealthStatus.values[data['status'] as int],
            latencyMs: data['latencyMs'],
            lastChecked: DateTime.parse(data['lastChecked']),
            lastSuccess: data['lastSuccess'] != null
                ? DateTime.parse(data['lastSuccess'])
                : null,
            endpoint: service.endpoint,
            isCritical: service.isCritical,
            retryCount: data['retryCount'] ?? 0,
          );
        }
      }
    } catch (e) {
      print('Error loading service states: $e');
    }
  }

  void _startAutoHealthChecks() {
    _autoCheckTimer?.cancel();

    _autoCheckTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      await checkAllServices();

      // Check for critical failures
      final summary = this.summary;
      if (summary.criticalFailures.isNotEmpty) {
        _sendAlertNotification(summary.criticalFailures);
      }
    });
  }

  void _sendAlertNotification(List<ServiceStatus> failures) {
    final message =
        'Critical services down: ${failures.map((f) => f.serviceName).join(', ')}';
    print('🔴 SYSTEM ALERT: $message');
    // Implement notification logic here
  }

  void _checkForCriticalFailures() {
    final failures = _services.values
        .where((s) => s.status == HealthStatus.failed && s.isCritical)
        .toList();

    if (failures.isNotEmpty) {
      // You could trigger additional actions here
      print('⚠️ Critical failures detected: ${failures.length}');
    }
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    super.dispose();
  }
}
