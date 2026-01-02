import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RealAdminDashboardScreen extends StatelessWidget {
  const RealAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${auth.currentUser?.name ?? "Super Admin"}!',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const Text(
                          'Full System Access',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.3,
              children: [
                _buildCard('Users', '1,890', Icons.people, Colors.blue),
                _buildCard('Admins', '12', Icons.admin_panel_settings, Colors.red),
                _buildCard('Farmers', '1,234', Icons.agriculture, Colors.green),
                _buildCard('Doctors', '56', Icons.medical_services, Colors.orange),
                _buildCard('Products', '789', Icons.inventory, Colors.purple),
                _buildCard('Posts', '432', Icons.article, Colors.teal),
              ],
            ),
            const SizedBox(height: 12),
            const Text('System Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildActionTile(Icons.admin_panel_settings, 'Admins', Colors.red, () => _showAdminsDialog(context)),
            _buildActionTile(Icons.shield, 'Access Control', Colors.deepOrange, () => _showAccessControlDialog(context)),
            _buildActionTile(Icons.people, 'All Users', Colors.blue, () => _showUsersDialog(context)),
            _buildActionTile(Icons.security, 'Security', Colors.orange, () => _showSecurityDialog(context)),
            _buildActionTile(Icons.backup, 'Backup', Colors.green, () => _showBackupDialog(context)),
            _buildActionTile(Icons.settings, 'Settings', Colors.grey, () => _showSettingsDialog(context)),
            _buildActionTile(Icons.analytics, 'Analytics', Colors.purple, () => _showAnalyticsDialog(context)),
            _buildActionTile(Icons.notifications_active, 'Broadcast', Colors.teal, () => _showBroadcastDialog(context)),
            _buildActionTile(Icons.palette, 'App Design', Colors.pink, () => _showDesignDialog(context)),
            _buildActionTile(Icons.image, 'Media', Colors.indigo, () => _showMediaDialog(context)),
            _buildActionTile(Icons.code, 'API Config', Colors.cyan, () => _showAPIDialog(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(count, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color, size: 20),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 12),
        onTap: onTap,
      ),
    );
  }

  void _showAdminsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Manage Admins'),
          content: SizedBox(
            width: 500,
            height: 400,
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search admins...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => _showAddAdminDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final active = index % 2 == 0;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: active ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                            child: Icon(Icons.admin_panel_settings, color: active ? Colors.green : Colors.grey),
                          ),
                          title: Text('Admin ${index + 1}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('District: Kathmandu'),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: active ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(active ? 'Active' : 'Inactive', style: TextStyle(fontSize: 10, color: active ? Colors.green : Colors.grey)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Last login: ${index + 1}h ago', style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'view', child: Text('View Details')),
                              const PopupMenuItem(value: 'edit', child: Text('Edit Permissions')),
                              const PopupMenuItem(value: 'reset', child: Text('Reset Password')),
                              const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                            onSelected: (value) {
                              setState(() {});
                              _showSnackbar(context, 'Admin $value');
                            },
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        ),
      ),
    );
  }

  void _showAddAdminDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedDistrict = 'Kathmandu';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Admin'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedDistrict,
                  decoration: const InputDecoration(labelText: 'District', border: OutlineInputBorder()),
                  items: ['Kathmandu', 'Pokhara', 'Lalitpur', 'Bhaktapur'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => setState(() => selectedDistrict = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackbar(context, 'Admin added successfully');
              },
              child: const Text('Add Admin'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUsersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('All Users Management'),
          content: SizedBox(
            width: 550,
            height: 450,
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: 'All',
                      items: ['All', 'Farmers', 'Doctors', 'Admins'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() {}),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: 15,
                    itemBuilder: (context, index) {
                      final role = index % 3 == 0 ? 'Farmer' : index % 3 == 1 ? 'Doctor' : 'Admin';
                      final color = role == 'Farmer' ? Colors.green : role == 'Doctor' ? Colors.blue : Colors.red;
                      final active = index % 4 != 0;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.2),
                            child: Icon(
                              role == 'Farmer' ? Icons.agriculture : role == 'Doctor' ? Icons.medical_services : Icons.admin_panel_settings,
                              color: color,
                              size: 20,
                            ),
                          ),
                          title: Text('User ${index + 1}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Phone: 980000000$index'),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(role, style: TextStyle(fontSize: 10, color: color)),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(active ? Icons.check_circle : Icons.cancel, size: 12, color: active ? Colors.green : Colors.red),
                                  Text(active ? ' Active' : ' Inactive', style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'view', child: Text('View Profile')),
                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
                              const PopupMenuItem(value: 'activate', child: Text('Activate')),
                              const PopupMenuItem(value: 'reset', child: Text('Reset Password')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                            onSelected: (value) {
                              setState(() {});
                              _showSnackbar(context, 'User $value');
                            },
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Export All'),
              onPressed: () => _showSnackbar(context, 'Exporting all users...'),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      ),
    );
  }

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Security & Activity Logs'),
          content: SizedBox(
            width: 550,
            height: 450,
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search logs...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: 'All',
                      items: ['All', 'Login', 'Failed', 'Suspicious', 'Admin'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() {}),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      final type = index % 4 == 0 ? 'Failed Login' : index % 4 == 1 ? 'Successful Login' : index % 4 == 2 ? 'Suspicious Activity' : 'Admin Action';
                      final color = type == 'Failed Login' ? Colors.red : type == 'Successful Login' ? Colors.green : type == 'Suspicious Activity' ? Colors.orange : Colors.blue;
                      final icon = type == 'Failed Login' ? Icons.error : type == 'Successful Login' ? Icons.check_circle : type == 'Suspicious Activity' ? Icons.warning : Icons.admin_panel_settings;
                      return Card(
                        child: ListTile(
                          leading: Icon(icon, color: color, size: 20),
                          title: Text(type),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('User: user_${index + 1} • IP: 192.168.1.${index + 1}'),
                              Text('${index + 1} minutes ago', style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.info_outline, size: 18),
                            onPressed: () => _showLogDetails(context, index),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Export Logs'),
              onPressed: () => _showSnackbar(context, 'Exporting security logs...'),
            ),
            TextButton.icon(
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Clear Old'),
              onPressed: () => _showSnackbar(context, 'Clearing old logs...'),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      ),
    );
  }

  void _showLogDetails(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Event ID', 'LOG_${1000 + index}'),
            _buildDetailRow('User', 'user_${index + 1}'),
            _buildDetailRow('IP Address', '192.168.1.${index + 1}'),
            _buildDetailRow('Location', 'Kathmandu, Nepal'),
            _buildDetailRow('Device', 'Chrome on Windows'),
            _buildDetailRow('Timestamp', '2024-01-15 10:${30 + index}:00'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('System Backup & Restore'),
          content: SizedBox(
            width: 500,
            height: 450,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Last Backup', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('2024-01-15 08:30 AM • 2 hours ago'),
                            Text('Size: 245 MB • Status: Success', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.backup),
                        label: const Text('Create Backup'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () {
                          _showSnackbar(context, 'Creating backup...');
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.schedule),
                        label: const Text('Schedule'),
                        onPressed: () => _showScheduleBackupDialog(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Backup History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final success = index % 5 != 0;
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            success ? Icons.check_circle : Icons.error,
                            color: success ? Colors.green : Colors.red,
                          ),
                          title: Text('Backup ${10 - index}'),
                          subtitle: Text('2024-01-${15 - index} • ${200 + index * 10} MB'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.restore, size: 18),
                                onPressed: () => _showRestoreConfirmation(context, index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.download, size: 18),
                                onPressed: () => _showSnackbar(context, 'Downloading backup...'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                onPressed: () {
                                  setState(() {});
                                  _showSnackbar(context, 'Backup deleted');
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        ),
      ),
    );
  }

  void _showScheduleBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Automatic Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Daily at 2:00 AM'),
              leading: Radio(value: 1, groupValue: 1, onChanged: (v) {}),
            ),
            ListTile(
              title: const Text('Weekly on Sunday'),
              leading: Radio(value: 2, groupValue: 1, onChanged: (v) {}),
            ),
            ListTile(
              title: const Text('Monthly on 1st'),
              leading: Radio(value: 3, groupValue: 1, onChanged: (v) {}),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackbar(context, 'Backup schedule saved');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRestoreConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: const Text('This will restore the system to the selected backup point. Current data will be replaced. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(context);
              _showSnackbar(context, 'Restoring backup...');
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Settings'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Maintenance Mode'),
                value: false,
                onChanged: (value) => _showSnackbar(context, 'Maintenance mode: $value'),
              ),
              SwitchListTile(
                title: const Text('User Registration'),
                value: true,
                onChanged: (value) => _showSnackbar(context, 'Registration: $value'),
              ),
              SwitchListTile(
                title: const Text('Email Notifications'),
                value: true,
                onChanged: (value) => _showSnackbar(context, 'Email: $value'),
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showAnalyticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Global Analytics'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: ListView(
            children: [
              _buildAnalyticItem('Total Revenue', 'Rs. 1,25,000', Icons.attach_money, Colors.green),
              _buildAnalyticItem('Active Users', '1,234', Icons.people, Colors.blue),
              _buildAnalyticItem('Transactions', '567', Icons.receipt, Colors.orange),
              _buildAnalyticItem('Growth Rate', '+23%', Icons.trending_up, Colors.teal),
              _buildAnalyticItem('Server Uptime', '99.9%', Icons.cloud_done, Colors.purple),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showBroadcastDialog(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Broadcast Notification'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Send to All Users'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _showSnackbar(context, 'Broadcast sent to all users');
                },
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
      ),
    );
  }

  Widget _buildAnalyticItem(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }

  void _showDesignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Design & Branding'),
        content: SizedBox(
          width: 450,
          height: 400,
          child: ListView(
            children: [
              const Text('Theme Colors', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildColorButton('Primary', Colors.green, context),
                  _buildColorButton('Secondary', Colors.blue, context),
                  _buildColorButton('Accent', Colors.orange, context),
                  _buildColorButton('Error', Colors.red, context),
                ],
              ),
              const Divider(height: 24),
              const Text('Button Styles', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('Rounded'))),
                  const SizedBox(width: 8),
                  Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder()), child: const Text('Square'))),
                ],
              ),
              const Divider(height: 24),
              const Text('Typography', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Font Family', border: OutlineInputBorder()),
                items: ['Roboto', 'Open Sans', 'Lato'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (v) {},
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Apply Design Changes'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  Navigator.pop(context);
                  _showSnackbar(context, 'Design changes applied');
                },
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildColorButton(String label, Color color, BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showSnackbar(context, '$label color changed'),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  void _showMediaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Media & Assets Management'),
        content: SizedBox(
          width: 450,
          height: 400,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload'),
                      onPressed: () => _showSnackbar(context, 'Upload media'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.folder),
                      label: const Text('Browse'),
                      onPressed: () => _showSnackbar(context, 'Browse media'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildMediaItem('App Logo', 'logo.png', '250 KB', Icons.image, context),
                    _buildMediaItem('Background', 'bg.jpg', '1.2 MB', Icons.wallpaper, context),
                    _buildMediaItem('App Icon', 'icon.png', '45 KB', Icons.apps, context),
                    _buildMediaItem('Splash Screen', 'splash.png', '890 KB', Icons.phone_android, context),
                    _buildMediaItem('Banner Image', 'banner.jpg', '650 KB', Icons.panorama, context),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildMediaItem(String title, String filename, String size, IconData icon, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: Text('$filename • $size', style: const TextStyle(fontSize: 11)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, size: 18),
              onPressed: () => _showSnackbar(context, 'Preview $title'),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () => _showSnackbar(context, 'Edit $title'),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
              onPressed: () => _showSnackbar(context, 'Delete $title'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAPIDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Configuration'),
        content: SizedBox(
          width: 450,
          height: 350,
          child: ListView(
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'API Base URL',
                  border: OutlineInputBorder(),
                  hintText: 'https://api.hamikisan.com',
                ),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'API Key',
                  border: OutlineInputBorder(),
                  hintText: 'Enter API key',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Weather API Key',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Market Data API',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Test Connection'),
                      onPressed: () => _showSnackbar(context, 'Testing API connection...'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        Navigator.pop(context);
                        _showSnackbar(context, 'API configuration saved');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showAccessControlDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Admin Access Control'),
          content: SizedBox(
            width: 550,
            height: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Configure permissions for Kisan Admin role. Super Admin always has full access.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search admins...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: 'All Admins',
                      items: ['All Admins', 'Active', 'Restricted'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() {}),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.withOpacity(0.2),
                            child: const Icon(Icons.admin_panel_settings, color: Colors.red, size: 20),
                          ),
                          title: Text('Kisan Admin ${index + 1}'),
                          subtitle: Text('District: ${['Kathmandu', 'Pokhara', 'Lalitpur', 'Bhaktapur', 'Chitwan'][index]}'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  _buildPermissionRow('View Users', true, (v) => setState(() {})),
                                  _buildPermissionRow('Edit Users', true, (v) => setState(() {})),
                                  _buildPermissionRow('Delete Users', false, (v) => setState(() {})),
                                  _buildPermissionRow('Approve Users', true, (v) => setState(() {})),
                                  const Divider(),
                                  _buildPermissionRow('View Products', true, (v) => setState(() {})),
                                  _buildPermissionRow('Edit Products', true, (v) => setState(() {})),
                                  _buildPermissionRow('Delete Products', false, (v) => setState(() {})),
                                  const Divider(),
                                  _buildPermissionRow('View Posts', true, (v) => setState(() {})),
                                  _buildPermissionRow('Edit Posts', true, (v) => setState(() {})),
                                  _buildPermissionRow('Delete Posts', false, (v) => setState(() {})),
                                  const Divider(),
                                  _buildPermissionRow('App Design Access', false, (v) => setState(() {})),
                                  _buildPermissionRow('Media Management', false, (v) => setState(() {})),
                                  _buildPermissionRow('System Settings', false, (v) => setState(() {})),
                                  _buildPermissionRow('Backup/Restore', false, (v) => setState(() {})),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.save, size: 16),
                                          label: const Text('Save'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                          onPressed: () => _showSnackbar(context, 'Permissions saved for Admin ${index + 1}'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          icon: const Icon(Icons.restore, size: 16),
                                          label: const Text('Reset'),
                                          onPressed: () {
                                            setState(() {});
                                            _showSnackbar(context, 'Permissions reset to default');
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text('Global Settings'),
              onPressed: () => _showGlobalPermissionsDialog(context),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.green,
          ),
        ],
      ),
    );
  }

  void _showGlobalPermissionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Global Admin Permissions'),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Apply these permissions to all Kisan Admins',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text('User Management', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildPermissionRow('Allow Delete Users', false, (v) => setState(() {})),
                _buildPermissionRow('Allow Suspend Users', true, (v) => setState(() {})),
                const Divider(),
                const Text('Content Management', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildPermissionRow('Allow Delete Products', false, (v) => setState(() {})),
                _buildPermissionRow('Allow Delete Posts', false, (v) => setState(() {})),
                const Divider(),
                const Text('System Access', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildPermissionRow('App Design Access', false, (v) => setState(() {})),
                _buildPermissionRow('Media Management', false, (v) => setState(() {})),
                _buildPermissionRow('System Settings', false, (v) => setState(() {})),
                _buildPermissionRow('Backup/Restore', false, (v) => setState(() {})),
                _buildPermissionRow('Security Logs', true, (v) => setState(() {})),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Apply to All'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                _showSnackbar(context, 'Global permissions applied to all Kisan Admins');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
