import 'package:flutter/material.dart';
import '../models/system_health_models.dart';

class SystemHealthServiceCard extends StatelessWidget {
  final ServiceStatus service;
  final VoidCallback onTest;
  final VoidCallback? onReconnect;
  final VoidCallback? onToggle;
  final bool showDetails;

  const SystemHealthServiceCard({
    super.key,
    required this.service,
    required this.onTest,
    this.onReconnect,
    this.onToggle,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _statusIcon(service.status),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          service.serviceName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (service.isCritical)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'CRITICAL',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: onTest,
                  tooltip: 'Test Now',
                ),
              ],
            ),

            // Status & Latency
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  _statusChip(service.status),
                  if (service.latencyMs != null) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('${service.latencyMs}ms'),
                      backgroundColor: _getLatencyColor(service.latencyMs!),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    'Last: ${_timeAgo(service.lastChecked)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Details (Expanded)
            if (showDetails) ...[
              const Divider(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Endpoint:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    service.endpoint,
                    style: const TextStyle(fontSize: 12, fontFamily: 'Monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (service.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${service.errorMessage}',
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ],
                  if (service.metadata.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: service.metadata.entries.map((e) => Chip(
                        label: Text('${e.key}: ${e.value}'),
                        labelStyle: const TextStyle(fontSize: 10),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ],

            // Action Buttons
            if (onReconnect != null || onToggle != null) ...[
              const Divider(height: 16),
              Row(
                children: [
                  if (onReconnect != null)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.sync, size: 16),
                      label: const Text('Reconnect'),
                      onPressed: onReconnect,
                    ),
                  const Spacer(),
                  if (onToggle != null)
                    Switch(
                      value: service.status != HealthStatus.failed,
                      onChanged: (_) => onToggle!(),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(HealthStatus status) {
    switch (status) {
      case HealthStatus.healthy:
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case HealthStatus.degraded:
        return const Icon(Icons.warning, color: Colors.orange, size: 20);
      case HealthStatus.failed:
        return const Icon(Icons.error, color: Colors.red, size: 20);
      case HealthStatus.unknown:
        return const Icon(Icons.help, color: Colors.grey, size: 20);
    }
  }

  Widget _statusChip(HealthStatus status) {
    final Map<HealthStatus, (String, Color)> statusInfo = {
      HealthStatus.healthy: ('CONNECTED', Colors.green),
      HealthStatus.degraded: ('DEGRADED', Colors.orange),
      HealthStatus.failed: ('FAILED', Colors.red),
      HealthStatus.unknown: ('UNKNOWN', Colors.grey),
    };

    final info = statusInfo[status]!;
    return Chip(
      label: Text(info.$1),
      backgroundColor: info.$2.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: info.$2,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color _getLatencyColor(int latencyMs) {
    if (latencyMs < 200) return Colors.green.withValues(alpha: 0.1);
    if (latencyMs < 500) return Colors.orange.withValues(alpha: 0.1);
    return Colors.red.withValues(alpha: 0.1);
  }

  String _timeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inSeconds < 60) return '${difference.inSeconds}s ago';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}