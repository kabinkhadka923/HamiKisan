import 'package:flutter/material.dart';
import '../utils/logger.dart';

// ==================== ENUMS ====================

enum HealthStatus { healthy, degraded, failed, unknown }

enum HealthAction { healthCheck, adminAction, error, reconnect, toggleService }

// ==================== MODELS ====================

class ServiceStatus {
  final String serviceName;
  final String serviceId;
  final HealthStatus status;
  final int? latencyMs;
  final DateTime lastChecked;
  final DateTime? lastSuccess;
  final String? errorMessage;
  final String endpoint;
  final bool isCritical;
  final int retryCount;
  final Map<String, dynamic> metadata;

  const ServiceStatus({
    required this.serviceName,
    required this.serviceId,
    required this.status,
    this.latencyMs,
    required this.lastChecked,
    this.lastSuccess,
    this.errorMessage,
    required this.endpoint,
    this.isCritical = true,
    this.retryCount = 0,
    this.metadata = const {},
  });

  ServiceStatus copyWith({
    HealthStatus? status,
    int? latencyMs,
    DateTime? lastChecked,
    DateTime? lastSuccess,
    String? errorMessage,
    bool? isCritical,
    int? retryCount,
    Map<String, dynamic>? metadata,
  }) {
    return ServiceStatus(
      serviceName: serviceName,
      serviceId: serviceId,
      status: status ?? this.status,
      latencyMs: latencyMs ?? this.latencyMs,
      lastChecked: lastChecked ?? this.lastChecked,
      lastSuccess: lastSuccess ?? this.lastSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      endpoint: endpoint,
      isCritical: isCritical ?? this.isCritical,
      retryCount: retryCount ?? this.retryCount,
      metadata: metadata ?? this.metadata,
    );
  }
}

class SystemHealthSummary {
  final int totalServices;
  final int healthyServices;
  final int degradedServices;
  final int failedServices;
  final HealthStatus overallStatus;
  final DateTime lastFullCheck;
  final List<ServiceStatus> criticalFailures;

  const SystemHealthSummary({
    required this.totalServices,
    required this.healthyServices,
    required this.degradedServices,
    required this.failedServices,
    required this.overallStatus,
    required this.lastFullCheck,
    required this.criticalFailures,
  });

  double get healthPercentage =>
      totalServices > 0 ? (healthyServices / totalServices) * 100 : 0.0;

  Color get statusColor {
    switch (overallStatus) {
      case HealthStatus.healthy:
        return Colors.green;
      case HealthStatus.degraded:
        return Colors.orange;
      case HealthStatus.failed:
        return Colors.red;
      case HealthStatus.unknown:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (overallStatus) {
      case HealthStatus.healthy:
        return 'ALL SYSTEMS OPERATIONAL';
      case HealthStatus.degraded:
        return 'PARTIAL DEGRADATION';
      case HealthStatus.failed:
        return 'CRITICAL FAILURE';
      case HealthStatus.unknown:
        return 'STATUS UNKNOWN';
    }
  }
}

class HealthLog {
  final DateTime timestamp;
  final String? serviceId;
  final HealthAction action;
  final String message;
  final String? error;
  final String deviceInfo;

  const HealthLog({
    required this.timestamp,
    this.serviceId,
    required this.action,
    required this.message,
    this.error,
    required this.deviceInfo,
  });

  String get actionDisplay {
    switch (action) {
      case HealthAction.healthCheck:
        return 'HEALTH_CHECK';
      case HealthAction.adminAction:
        return 'ADMIN_ACTION';
      case HealthAction.error:
        return 'ERROR';
      case HealthAction.reconnect:
        return 'RECONNECT';
      case HealthAction.toggleService:
        return 'TOGGLE_SERVICE';
    }
  }

  Color get actionColor {
    switch (action) {
      case HealthAction.healthCheck:
        return Colors.blue;
      case HealthAction.adminAction:
        return Colors.purple;
      case HealthAction.error:
        return Colors.red;
      case HealthAction.reconnect:
        return Colors.green;
      case HealthAction.toggleService:
        return Colors.orange;
    }
  }
}

class HealthConfig {
  static const Map<String, String> serviceEndpoints = {
    'weather_api': 'https://api.weatherapi.com/v1',
    'market_api': 'https://kalimati.gov.np/api',
    'firebase_auth': 'Firebase Authentication',
    'firestore_db': 'Cloud Firestore',
    'chat_socket': 'wss://yourdomain.com/chat',
    'notification_socket': 'wss://yourdomain.com/notify',
  };

  static const int checkIntervalMinutes = 5;
  static const bool enableAutoChecks = true;
  static const bool sendAlerts = true;
  static const List<String> alertRecipients = ['admin@example.com'];
}

// ==================== PROVIDER ====================

class SystemHealthProvider extends ChangeNotifier {
  static final SystemHealthProvider _instance =
      SystemHealthProvider._internal();
  factory SystemHealthProvider() => _instance;
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
      endpoint: HealthConfig.serviceEndpoints['weather_api']!,
      isCritical: true,
    ),
    'market_api': ServiceStatus(
      serviceName: 'Market API',
      serviceId: 'market_api',
      status: HealthStatus.unknown,
      lastChecked: DateTime.now(),
      endpoint: HealthConfig.serviceEndpoints['market_api']!,
      isCritical: true,
    ),
    'firebase_auth': ServiceStatus(
      serviceName: 'Firebase Auth',
      serviceId: 'firebase_auth',
      status: HealthStatus.unknown,
      lastChecked: DateTime.now(),
      endpoint: HealthConfig.serviceEndpoints['firebase_auth']!,
      isCritical: true,
    ),
    'firestore_db': ServiceStatus(
      serviceName: 'Firestore Database',
      serviceId: 'firestore_db',
      status: HealthStatus.unknown,
      lastChecked: DateTime.now(),
      endpoint: HealthConfig.serviceEndpoints['firestore_db']!,
      isCritical: true,
    ),
    'chat_socket': ServiceStatus(
      serviceName: 'Chat WebSocket',
      serviceId: 'chat_socket',
      status: HealthStatus.unknown,
      lastChecked: DateTime.now(),
      endpoint: HealthConfig.serviceEndpoints['chat_socket']!,
      isCritical: false,
    ),
    'notification_socket': ServiceStatus(
      serviceName: 'Notification Socket',
      serviceId: 'notification_socket',
      status: HealthStatus.unknown,
      lastChecked: DateTime.now(),
      endpoint: HealthConfig.serviceEndpoints['notification_socket']!,
      isCritical: false,
    ),
  };

  final List<HealthLog> _healthLogs = [];
  bool _isLoading = false;
  String? _error;

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
    } else if (degraded > 0) {
      overall = HealthStatus.degraded;
    }

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
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialization
  void _initialize() async {
    await _loadServiceStates();
    _startAutoHealthChecks();
  }

  // Main health check methods
  Future<void> checkAllServices({bool force = false}) async {
    if (_isLoading) return;

    _setLoading(true);
    _logHealthCheck('Starting full system health check',
        action: HealthAction.healthCheck);

    await Future.wait([
      _checkWeatherApi(),
      _checkMarketApi(),
      _checkFirebaseAuth(),
      _checkFirestore(),
      _checkChatSocket(),
      _checkNotificationSocket(),
    ]);

    _saveServiceStates();
    _notifyHealthChange();
    _checkForCriticalFailures();
    _setLoading(false);
  }

  Future<void> checkService(String serviceId) async {
    _logHealthCheck('Manual service check triggered',
        serviceId: serviceId, action: HealthAction.healthCheck);

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

    _saveServiceStates();
    notifyListeners();
  }

  // Service check implementations
  Future<void> _checkWeatherApi() async {
    final stopwatch = Stopwatch()..start();
    try {
      // Simulate API call - replace with actual implementation
      await Future.delayed(const Duration(milliseconds: 300));

      _updateService(
        'weather_api',
        status: HealthStatus.healthy,
        latencyMs: stopwatch.elapsedMilliseconds,
        errorMessage: null,
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
      // Simulate API call - replace with actual implementation
      await Future.delayed(const Duration(milliseconds: 200));

      _updateService(
        'market_api',
        status: HealthStatus.healthy,
        latencyMs: stopwatch.elapsedMilliseconds,
        errorMessage: null,
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

  Future<void> _checkFirebaseAuth() async {
    final stopwatch = Stopwatch()..start();
    try {
      // Simulate Firebase Auth check
      await Future.delayed(const Duration(milliseconds: 150));

      _updateService(
        'firebase_auth',
        status: HealthStatus.healthy,
        latencyMs: stopwatch.elapsedMilliseconds,
        errorMessage: null,
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
      await Future.delayed(const Duration(milliseconds: 250));

      _updateService(
        'firestore_db',
        status: HealthStatus.healthy,
        latencyMs: stopwatch.elapsedMilliseconds,
        errorMessage: null,
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

  Future<void> _checkChatSocket() async {
    try {
      // Simulate socket check
      await Future.delayed(const Duration(milliseconds: 100));

      _updateService(
        'chat_socket',
        status: HealthStatus.healthy,
        latencyMs: 50,
        metadata: {
          'connectionId': 'conn_${DateTime.now().millisecondsSinceEpoch}',
          'lastMessage': DateTime.now().toString(),
          'reconnectCount': 0,
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
      // Simulate notification socket check
      await Future.delayed(const Duration(milliseconds: 80));

      _updateService(
        'notification_socket',
        status: HealthStatus.healthy,
        latencyMs: 40,
        metadata: {
          'connectionId': 'notify_${DateTime.now().millisecondsSinceEpoch}',
          'lastMessage': DateTime.now().toString(),
          'reconnectCount': 0,
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

  // Admin actions
  Future<void> reconnectSocket(String serviceId) async {
    _logAdminAction('Manual socket reconnect triggered', serviceId);

    // Simulate reconnect
    await Future.delayed(const Duration(milliseconds: 500));

    // Re-check after reconnect
    await checkService(serviceId);
  }

  Future<void> toggleService(String serviceId, bool enabled) async {
    final service = _services[serviceId];
    if (service != null) {
      _updateService(
        serviceId,
        status: enabled ? HealthStatus.unknown : HealthStatus.failed,
        metadata: {'maintenanceMode': !enabled},
      );
      _logAdminAction(
        'Service ${enabled ? 'enabled' : 'disabled'}',
        serviceId,
        healthAction: HealthAction.toggleService,
      );
    }
  }

  // Auto-health check scheduler
  void _startAutoHealthChecks() {
    // For now, just do initial check
    // In production, you would use Timer.periodic here
    Future.delayed(const Duration(seconds: 2), () {
      checkAllServices();
    });
  }

  // Logging system
  void _logHealthCheck(
    String message, {
    String? serviceId,
    String? error,
    HealthAction action = HealthAction.healthCheck,
  }) {
    final log = HealthLog(
      timestamp: DateTime.now(),
      serviceId: serviceId,
      action: action,
      message: message,
      error: error,
      deviceInfo: 'Mobile', // Get from device info in production
    );

    _healthLogs.insert(0, log); // Add to beginning
    if (_healthLogs.length > 1000) {
      _healthLogs.removeLast(); // Keep only last 1000 logs
    }
  }

  void _logAdminAction(String action, String serviceId,
      {HealthAction healthAction = HealthAction.adminAction}) {
    _logHealthCheck(action, serviceId: serviceId, action: healthAction);
    // You could also log to server for audit trail
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
        'Service ${service.serviceName}: ${status.toString()}',
        serviceId: serviceId,
        error: errorMessage,
      );
    }
  }

  Future<void> _saveServiceStates() async {
    // Save state for offline viewing
    // Implementation would use SharedPreferences or similar
  }

  Future<void> _loadServiceStates() async {
    // Load previous state
    // Implementation would use SharedPreferences or similar
  }

  void _notifyHealthChange() {
    notifyListeners();
  }

  void _checkForCriticalFailures() {
    final failures = _services.values
        .where((s) => s.status == HealthStatus.failed && s.isCritical)
        .toList();

    if (failures.isNotEmpty) {
      _sendAlertNotification(failures);
    }
  }

  void _sendAlertNotification(List<ServiceStatus> failures) {
    final message =
        'Critical services down: ${failures.map((f) => f.serviceName).join(', ')}';
    // Implement your notification logic
    Logger.critical('ALERT: $message', tag: 'Health');
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
