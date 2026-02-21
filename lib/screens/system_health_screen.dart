import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/system_health_models.dart';
import '../widgets/system_health_service_card.dart';
import '../widgets/system_health_log_viewer.dart';
import '../models/user.dart';
import '../providers/system_health_provider.dart' as health_provider;

class SystemHealthScreen extends StatefulWidget {
  const SystemHealthScreen({super.key});

  @override
  _SystemHealthScreenState createState() => _SystemHealthScreenState();
}

class _SystemHealthScreenState extends State<SystemHealthScreen> {
  bool _isCheckingAll = false;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    // Verify Super Admin access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifyAdminAccess(context);
    });
  }

  Future<void> _checkAllServices() async {
    setState(() => _isCheckingAll = true);
    await context.read<health_provider.SystemHealthProvider>().checkAllServices();
    setState(() => _isCheckingAll = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<health_provider.SystemHealthProvider>();
    final summary = provider.summary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔌 System Health Monitor'),
        actions: [
          IconButton(
            icon: Icon(_showDetails ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _showDetails = !_showDetails),
            tooltip: 'Toggle Details',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SystemHealthLogViewer(
                  logs: provider.logs,
                  onClearLogs: () {
                    // Clear logs implementation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logs cleared')),
                    );
                  },
                  onExportLogs: () {
                    // Export logs implementation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logs exported')),
                    );
                  },
                ),
              ),
            ),
            tooltip: 'View Logs',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _checkAllServices,
        child: ListView(
          children: [
            // Overall Status Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: summary.statusColor.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _getOverallIcon(summary.overallStatus),
                          const SizedBox(width: 12),
                          Text(
                            summary.statusText,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: summary.statusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: summary.healthPercentage / 100,
                        backgroundColor: Colors.grey[300],
                        color: _getProgressColor(summary.healthPercentage),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMetricTile(
                            '🟢 Healthy',
                            summary.healthyServices.toString(),
                            Colors.green,
                          ),
                          _buildMetricTile(
                            '🟡 Degraded',
                            summary.degradedServices.toString(),
                            Colors.orange,
                          ),
                          _buildMetricTile(
                            '🔴 Failed',
                            summary.failedServices.toString(),
                            Colors.red,
                          ),
                        ],
                      ),
                      if (summary.criticalFailures.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Critical Services Down',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: summary.criticalFailures
                                    .map((s) => Chip(
                                          label: Text(s.serviceName),
                                          backgroundColor: Colors.red,
                                          labelStyle: const TextStyle(color: Colors.white),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: _isCheckingAll
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(_isCheckingAll ? 'Checking...' : 'Test All Services'),
                      onPressed: _isCheckingAll ? null : _checkAllServices,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => _showSettings(context),
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ),

            // Service Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: provider.services.map((service) {
                  return Column(
                    children: [
                      SystemHealthServiceCard(
                        service: service,
                        onTest: () => provider.checkService(service.serviceId),
                        onReconnect: service.serviceId.contains('socket')
                            ? () => provider.reconnectSocket(service.serviceId)
                            : null,
                        onToggle: () => provider.toggleService(
                          service.serviceId,
                          service.status == HealthStatus.failed,
                        ),
                        showDetails: _showDetails,
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              ),
            ),

            // Last Check Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Last full check: ${summary.lastFullCheck.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _getOverallIcon(HealthStatus status) {
    switch (status) {
      case HealthStatus.healthy:
        return const Icon(Icons.check_circle, color: Colors.green, size: 36);
      case HealthStatus.degraded:
        return const Icon(Icons.warning, color: Colors.orange, size: 36);
      case HealthStatus.failed:
        return const Icon(Icons.error, color: Colors.red, size: 36);
      case HealthStatus.unknown:
        return const Icon(Icons.help, color: Colors.grey, size: 36);
    }
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.orange;
    return Colors.red;
  }

  void _verifyAdminAccess(BuildContext context) {
    // Check if user is Super Admin
    // For now, we'll assume the user is authenticated as Super Admin
    // In a real implementation, you would check the user's role from auth provider
    final user = Provider.of<User?>(context, listen: false);
    
    if (user == null || user.role != UserRole.superAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access denied. Super Admin privileges required.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context); // Go back to previous screen
      return;
    }
    
    // If access is granted, proceed with initial check
    _checkAllServices();
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Monitor Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add settings options here
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Alert Notifications'),
              trailing: Switch(value: true, onChanged: (_) {}),
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Auto-check Interval'),
              subtitle: const Text('5 minutes'),
              onTap: () {
                // Show interval selector
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
