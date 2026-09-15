import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../models/kisan_doctor_models.dart';
import '../../providers/kisan_doctor_provider.dart';
import '../../utils/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  final User doctor;

  const NotificationsScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('Notifications'),
      ),
      body: Consumer<KisanDoctorProvider>(
        builder: (context, provider, _) {
          if (provider.notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          final unread = provider.unreadNotifications;
          final read = provider.notifications.where((n) => n.isRead).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (unread.isNotEmpty) ...[
                  Text('Unread', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: unread.length,
                    itemBuilder: (context, index) {
                      final notification = unread[index];
                      return _buildNotificationCard(context, notification, provider, isUnread: true);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                if (read.isNotEmpty) ...[
                  Text('Earlier', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: read.length,
                    itemBuilder: (context, index) {
                      final notification = read[index];
                      return _buildNotificationCard(context, notification, provider, isUnread: false);
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    DoctorNotification notification,
    KisanDoctorProvider provider, {
    required bool isUnread,
  }) {
    final timeFormat = DateFormat('hh:mm a');
    final timeStr = timeFormat.format(notification.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isUnread ? AppColors.primaryGreen.withOpacity(0.1) : Colors.white,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getNotificationIcon(notification.type), color: _getNotificationColor(notification.type)),
        ),
        title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        trailing: isUnread
            ? Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
              )
            : null,
        onTap: () {
          if (isUnread) {
            provider.markNotificationAsRead(notification.notificationId);
          }
        },
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newCase:
        return Colors.orange;
      case NotificationType.appointmentRequest:
        return Colors.blue;
      case NotificationType.feedbackReceived:
        return Colors.green;
      case NotificationType.adminAlert:
        return Colors.red;
      case NotificationType.systemAlert:
        return Colors.purple;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newCase:
        return Icons.agriculture;
      case NotificationType.appointmentRequest:
        return Icons.calendar_today;
      case NotificationType.feedbackReceived:
        return Icons.star;
      case NotificationType.adminAlert:
        return Icons.warning;
      case NotificationType.systemAlert:
        return Icons.info;
    }
  }
}
