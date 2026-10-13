import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [];
  NotificationFilter _currentFilter = NotificationFilter.all;
  bool _isLoading = true;
  bool _enableVibration = true;
  bool _enableSound = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Sample notifications - in real app, fetch from API
    final sampleNotifications = [
      NotificationItem(
        title: 'New Expert Available',
        message: 'Dr. Sharma is now available for consultation in your area',
        icon: Icons.medical_services,
        color: Colors.blue,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: NotificationType.expert,
        isRead: false,
      ),
      NotificationItem(
        title: 'Weather Alert',
        message: 'Heavy rain expected in your region tomorrow. Plan accordingly.',
        icon: Icons.cloud,
        color: Colors.orange,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.weather,
        isRead: true,
      ),
      NotificationItem(
        title: 'Crop Health Update',
        message: 'Your rice crop shows signs of improved growth this week',
        icon: Icons.eco,
        color: Colors.green,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: NotificationType.crop,
        isRead: false,
      ),
      NotificationItem(
        title: 'Market Price Alert',
        message: 'Wheat prices have increased by 15% in your local market',
        icon: Icons.attach_money,
        color: Colors.purple,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.market,
        isRead: true,
      ),
      NotificationItem(
        title: 'Government Scheme',
        message: 'New farming subsidy scheme announced. Check eligibility now.',
        icon: Icons.account_balance,
        color: Colors.red,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.government,
        isRead: false,
      ),
      NotificationItem(
        title: 'Community Event',
        message: 'Farming workshop this Saturday at 10 AM in your village',
        icon: Icons.event,
        color: Colors.teal,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        type: NotificationType.community,
        isRead: true,
      ),
    ];

    setState(() {
      _notifications.addAll(sampleNotifications);
      _isLoading = false;
    });
  }

  List<NotificationItem> get _filteredNotifications {
    if (_currentFilter == NotificationFilter.all) return _notifications;
    return _notifications
        .where((notification) =>
            notification.type.name == _currentFilter.name)
        .toList();
  }

  int get _unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notifications'),
          if (_unreadCount > 0)
            Text(
              '$_unreadCount unread',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      actions: [
        badges.Badge(
          showBadge: _unreadCount > 0,
          badgeContent: Text(
            _unreadCount > 99 ? '99+' : _unreadCount.toString(),
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
            ),
          ),
          position: badges.BadgePosition.topEnd(top: -5, end: 5),
          child: IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterMenu,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _showNotificationSettings,
        ),
        if (_filteredNotifications.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _showClearConfirmation,
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading notifications...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredNotifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _currentFilter == NotificationFilter.all
                    ? Icons.notifications_none
                    : Icons.filter_alt_outlined,
                size: 100,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 24),
              Text(
                _getEmptyStateTitle(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _getEmptyStateSubtitle(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_currentFilter != NotificationFilter.all)
                ElevatedButton.icon(
                  onPressed: () => setState(() => _currentFilter = NotificationFilter.all),
                  icon: const Icon(Icons.filter_alt_off, size: 18),
                  label: const Text('Clear Filter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_currentFilter != NotificationFilter.all)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.green.withValues(alpha: 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 16,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filter: ${_currentFilter.name.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => setState(() => _currentFilter = NotificationFilter.all),
                  child: const Text(
                    'Clear',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshNotifications,
            color: Colors.green,
            backgroundColor: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredNotifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notification = _filteredNotifications[index];
                return _buildNotificationCard(notification, index);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, int index) {
    return Dismissible(
      key: Key('notification_${notification.timestamp.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.red,
          size: 30,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Notification'),
            content: const Text('Are you sure you want to delete this notification?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        final removedNotification = notification;
        setState(() {
          _notifications.remove(removedNotification);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  _notifications.insert(index, removedNotification);
                });
              },
            ),
          ),
        );
      },
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : Colors.green.withValues(alpha: 0.05),
            border: Border(
              left: BorderSide(
                color: notification.color,
                width: 4,
              ),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _markAsRead(notification),
            onLongPress: () => _showNotificationActions(notification),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationIcon(notification),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(notification.timestamp),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  _getTypeIcon(notification.type),
                                  size: 12,
                                  color: notification.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  notification.type.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: notification.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 18),
                    onPressed: () => _showNotificationActions(notification),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationItem notification) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: notification.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        notification.icon,
        color: notification.color,
        size: 20,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _markAllAsRead,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      icon: const Icon(Icons.mark_email_read, size: 22),
      label: const Text('Mark All Read'),
    );
  }

  Future<void> _refreshNotifications() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.weather:
        return Icons.cloud;
      case NotificationType.market:
        return Icons.attach_money;
      case NotificationType.expert:
        return Icons.medical_services;
      case NotificationType.crop:
        return Icons.eco;
      case NotificationType.government:
        return Icons.account_balance;
      case NotificationType.community:
        return Icons.group;
    }
  }

  String _getEmptyStateTitle() {
    switch (_currentFilter) {
      case NotificationFilter.weather:
        return 'No Weather Alerts';
      case NotificationFilter.market:
        return 'No Market Updates';
      case NotificationFilter.expert:
        return 'No Expert Notifications';
      case NotificationFilter.crop:
        return 'No Crop Updates';
      case NotificationFilter.government:
        return 'No Government Updates';
      case NotificationFilter.community:
        return 'No Community Notifications';
      default:
        return 'No Notifications';
    }
  }

  String _getEmptyStateSubtitle() {
    switch (_currentFilter) {
      case NotificationFilter.weather:
        return 'Weather alerts will appear here when there are important weather changes in your area.';
      case NotificationFilter.market:
        return 'Market price updates will be shown here to help you get the best prices for your produce.';
      case NotificationFilter.expert:
        return 'Expert availability and consultation updates will appear here.';
      case NotificationFilter.crop:
        return 'Crop health and farming advice notifications will be shown here.';
      case NotificationFilter.government:
        return 'Government schemes and subsidy updates will appear here.';
      case NotificationFilter.community:
        return 'Community events and farmer meetup notifications will be shown here.';
      default:
        return 'You\'re all caught up! Check back later for new updates.';
    }
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Filter Notifications',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...NotificationFilter.values.map((filter) {
              final count = filter == NotificationFilter.all
                  ? _notifications.length
                  : _notifications.where((n) => n.type.name == filter.name).length;
              
              return ListTile(
                leading: Icon(
                  filter == NotificationFilter.all
                      ? Icons.all_inbox
                      : _getTypeIcon(NotificationType.values.firstWhere(
                          (t) => t.name == filter.name,
                        )),
                  color: filter == _currentFilter
                      ? Colors.green
                      : Colors.grey[600],
                ),
                title: Text(
                  filter.name[0].toUpperCase() + filter.name.substring(1),
                  style: TextStyle(
                    fontWeight: filter == _currentFilter
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                trailing: Text(
                  count.toString(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  setState(() => _currentFilter = filter);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Notification Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Enable Vibrations'),
                  subtitle: const Text('Vibrate when new notification arrives'),
                  value: _enableVibration,
                  onChanged: (value) {
                    setState(() => _enableVibration = value);
                  },
                  activeThumbColor: Colors.green,
                ),
                SwitchListTile(
                  title: const Text('Enable Sounds'),
                  subtitle: const Text('Play sound for new notifications'),
                  value: _enableSound,
                  onChanged: (value) {
                    setState(() => _enableSound = value);
                  },
                  activeThumbColor: Colors.green,
                ),
                const Divider(),
                const Text(
                  'Notification Categories',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...NotificationType.values.map((type) {
                  return CheckboxListTile(
                    title: Text(
                      type.name[0].toUpperCase() + type.name.substring(1),
                      style: const TextStyle(fontSize: 14),
                    ),
                    value: true, // In real app, store this in preferences
                    onChanged: (value) {},
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Save settings
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings saved')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showNotificationActions(NotificationItem notification) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                notification.isRead ? Icons.markunread : Icons.mark_email_read,
                color: Colors.green,
              ),
              title: Text(
                notification.isRead ? 'Mark as Unread' : 'Mark as Read',
              ),
              onTap: () {
                _markAsRead(notification);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteNotification(notification);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _shareNotification(notification);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.purple),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                _copyNotification(notification);
              },
            ),
          ],
        );
      },
    );
  }

  void _markAsRead(NotificationItem notification) {
    setState(() {
      final index = _notifications.indexOf(notification);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    if (_notifications.isEmpty) return;

    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllNotifications();
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllNotifications() {
    if (_notifications.isEmpty) return;

    final clearedNotifications = List<NotificationItem>.from(_notifications);
    
    setState(() {
      _notifications.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All notifications cleared'),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _notifications.addAll(clearedNotifications);
            });
          },
        ),
      ),
    );
  }

  void _deleteNotification(NotificationItem notification) {
    setState(() {
      _notifications.remove(notification);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification deleted')),
    );
  }

  void _shareNotification(NotificationItem notification) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing notification...')),
    );
  }

  void _copyNotification(NotificationItem notification) {
    // Implement copy functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification copied to clipboard')),
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  NotificationItem copyWith({
    String? title,
    String? message,
    IconData? icon,
    Color? color,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
  }) {
    return NotificationItem(
      title: title ?? this.title,
      message: message ?? this.message,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum NotificationType {
  weather,
  market,
  expert,
  crop,
  government,
  community,
}

enum NotificationFilter {
  all,
  weather,
  market,
  expert,
  crop,
  government,
  community,
}
