import 'package:flutter/material.dart';
import '../models/system_health_models.dart';

class SystemHealthLogViewer extends StatelessWidget {
  final List<HealthLog> logs;
  final VoidCallback onClearLogs;
  final VoidCallback onExportLogs;

  const SystemHealthLogViewer({
    super.key,
    required this.logs,
    required this.onClearLogs,
    required this.onExportLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Health Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: onClearLogs,
            tooltip: 'Clear Logs',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: onExportLogs,
            tooltip: 'Export Logs',
          ),
        ],
      ),
      body: logs.isEmpty
          ? const Center(child: Text('No logs available'))
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return _buildLogItem(log);
              },
            ),
    );
  }

  Widget _buildLogItem(HealthLog log) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: _getLogIcon(log.action),
        title: Text(
          log.message,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${_formatTime(log.timestamp)} • ${log.serviceId ?? "System"}',
          style: const TextStyle(fontSize: 12),
        ),
        children: [
          if (log.error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                log.error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Chip(
                  label: Text(
                    log.actionDisplay,
                    style: TextStyle(
                      fontSize: 10,
                      color: log.actionColor,
                    ),
                  ),
                  backgroundColor: log.actionColor.withValues(alpha: 0.1),
                ),
                const Spacer(),
                Text(
                  'Device: ${log.deviceInfo}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getLogIcon(HealthAction action) {
    switch (action) {
      case HealthAction.healthCheck:
        return const Icon(Icons.health_and_safety, color: Colors.blue);
      case HealthAction.adminAction:
        return const Icon(Icons.admin_panel_settings, color: Colors.purple);
      case HealthAction.error:
        return const Icon(Icons.error, color: Colors.red);
      case HealthAction.reconnect:
        return const Icon(Icons.sync, color: Colors.green);
      case HealthAction.toggleService:
        return const Icon(Icons.toggle_on, color: Colors.orange);
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}