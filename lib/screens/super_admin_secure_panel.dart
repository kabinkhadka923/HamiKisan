import 'package:flutter/material.dart';
import 'admin/api_settings_screen.dart';
import 'admin/kalimati_items_screen.dart';
import 'admin/farmer_listings_screen.dart';
import 'admin/all_users_screen.dart';
import 'admin/security_panel_screen.dart';
import 'admin/backup_screen.dart';
import 'admin/settings_panel_screen.dart';
import 'admin/analytics_panel_screen.dart';
import 'admin/broadcast_screen.dart';
import 'admin/app_design_screen.dart';
import 'admin/media_screen.dart';

class SuperAdminSecurePanel extends StatefulWidget {
  const SuperAdminSecurePanel({super.key});

  @override
  State<SuperAdminSecurePanel> createState() => _SuperAdminSecurePanelState();
}

class _SuperAdminSecurePanelState extends State<SuperAdminSecurePanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Panel'),
        backgroundColor: Colors.red.shade900,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.security),
          onPressed: () {},
          tooltip: 'Security Mode',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(),
            tooltip: 'Logout',
          ),
          IconButton(
            icon: const Icon(Icons.settings_applications),
            onPressed: () => _showSystemSettings(context),
            tooltip: 'System Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
            Tab(text: 'Admin Control', icon: Icon(Icons.admin_panel_settings)),
            Tab(text: 'Analytics', icon: Icon(Icons.trending_up)),
            Tab(text: 'Security', icon: Icon(Icons.security)),
            Tab(text: 'Settings', icon: Icon(Icons.settings)),
            Tab(text: 'System', icon: Icon(Icons.settings_system_daydream)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSystemOverview(),
          _buildAdminControl(),
          _buildGlobalAnalytics(),
          _buildSecurityAudit(),
          _buildSettings(),
          _buildSystemControl(),
        ],
      ),
    );
  }

  Widget _buildSystemOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Global System Overview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last updated: ${DateTime.now().toString()}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Critical System Metrics
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildCriticalMetricCard(
                'Total Active Users',
                '12,583',
                Icons.people_alt,
                Colors.blue,
                '↑ 8.5%',
              ),
              _buildCriticalMetricCard(
                'Daily Active Sessions',
                '8,742',
                Icons.people_outline,
                Colors.green,
                '↑ 12.3%',
              ),
              _buildCriticalMetricCard(
                'System Uptime',
                '99.9%',
                Icons.system_security_update_good,
                Colors.green,
                '↑ 0.1%',
              ),
              _buildCriticalMetricCard(
                'Revenue Generated',
                '₹2,45,678',
                Icons.attach_money,
                Colors.orange,
                '↑ 18.7%',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Regional Performance
          const Text(
            'Regional Performance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildRegionCard('Kathmandu', '3,241', '+15%'),
              _buildRegionCard('Pokhara', '1,892', '+22%'),
              _buildRegionCard('Lalitpur', '1,567', '+8%'),
              _buildRegionCard('Biratnagar', '987', '+12%'),
              _buildRegionCard('Chitwan', '1,234', '+19%'),
              _buildRegionCard('Butwal', '756', '+7%'),
            ],
          ),

          const SizedBox(height: 24),

          // Critical Alerts
          const Text(
            'System Alerts (Critical)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          _buildAlertsSection(),
        ],
      ),
    );
  }

  Widget _buildAdminControl() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kisan Admins Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search admins...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _addNewAdmin(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Admin List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            itemBuilder: (context, index) {
              final regions = [
                'Kathmandu Valley',
                'Western Nepal',
                'Eastern Nepal',
                'Central Nepal',
                'Tarai Region',
                'Northern Region',
                'All Nepal'
              ];

              final statuses = [
                'Active',
                'Suspended',
                'On Leave',
                'Active',
                'Active',
                'Suspended',
                'Active',
                'On Leave'
              ];

              final region = regions[index % regions.length];
              final status = statuses[index % statuses.length];
              final isActive = status == 'Active';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: isActive ? Colors.white : Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isActive ? Colors.blue : Colors.grey,
                            child: const Icon(Icons.admin_panel_settings, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('Region: $region'),
                                const Text('Last active: 2h ago'),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(status),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              PopupMenuButton<String>(
                                onSelected: (action) => _handleAdminAction(action, index),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit Permissions'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'suspend',
                                    child: Text('Suspend Access'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'reset_pass',
                                    child: Text('Reset Password'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Text('Remove Admin'),
                                  ),
                                ],
                                child: const Row(
                                  children: [
                                    Text('Actions'),
                                    Icon(Icons.keyboard_arrow_down, size: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Statistics: ${index * 45 + 120} users managed',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          Text(
                            'Issues: ${index * 2 + 5}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Global Analytics Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 24),

          // Global Statistics
          Row(
            children: [
              Expanded(child: _buildGlobalStatCard('Total Revenue', '₹34,56,789', Colors.green)),
              Expanded(child: _buildGlobalStatCard('User Growth', '+23%', Colors.blue)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildGlobalStatCard('Platform Health', '98.7%', Colors.orange)),
              Expanded(child: _buildGlobalStatCard('Active Markets', '87', Colors.purple)),
            ],
          ),

          const SizedBox(height: 24),

          // Charts Placeholder
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Global Trends Chart'),
                  Text('(Chart implementation pending)', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Export Options
          const Text(
            'Data Export Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildExportButton('Financial Report', Icons.attach_money),
              _buildExportButton('User Analytics', Icons.people),
              _buildExportButton('Market Performance', Icons.store),
              _buildExportButton('Regional Insights', Icons.location_on),
              _buildExportButton('Security Logs', Icons.security),
              _buildExportButton('Complete Database', Icons.storage),
            ],
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _generateComprehensiveReport(),
              icon: const Icon(Icons.document_scanner),
              label: const Text('Generate Comprehensive Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemControl() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Control Panel',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Text(
              '⚠️ WARNING: These controls affect the entire system. Use with extreme caution.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // System Controls
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildSystemControlCard('All Users', Icons.people, Colors.blue, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AllUsersScreen()));
              }),
              _buildSystemControlCard('Security', Icons.security, Colors.red, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityPanelScreen()));
              }),
              _buildSystemControlCard('Backup', Icons.backup, Colors.green, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BackupScreen()));
              }),
              _buildSystemControlCard('Settings', Icons.settings, Colors.grey, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPanelScreen()));
              }),
              _buildSystemControlCard('Analytics', Icons.analytics, Colors.purple, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticsPanelScreen()));
              }),
              _buildSystemControlCard('Broadcast', Icons.broadcast_on_home, Colors.orange, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BroadcastScreen()));
              }),
              _buildSystemControlCard('App Design', Icons.design_services, Colors.pink, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AppDesignScreen()));
              }),
              _buildSystemControlCard('Media', Icons.perm_media, Colors.teal, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MediaScreen()));
              }),
              _buildSystemControlCard('Market Items', Icons.store, const Color(0xFF4CAF50), () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const KalimatiItemsScreen()));
              }),
              _buildSystemControlCard('Farmer Listings', Icons.agriculture, Colors.brown, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FarmerListingsScreen()));
              }),
              _buildSystemControlCard('API Config', Icons.api, Colors.indigo, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ApiSettingsScreen()));
              }),
            ],
          ),

          const SizedBox(height: 24),

          // Server Monitoring
          const Text(
            'Server Monitoring',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildServerMetric('CPU Usage', '23%', Colors.green),
                const SizedBox(height: 12),
                _buildServerMetric('Memory Usage', '67%', Colors.orange),
                const SizedBox(height: 12),
                _buildServerMetric('Disk Usage', '45%', Colors.yellow),
                const SizedBox(height: 12),
                _buildServerMetric('Network I/O', '156 MB/s', Colors.blue),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Maintenance Mode
          Card(
            color: Colors.yellow.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Maintenance Mode',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Temporarily disable the app for maintenance'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _toggleMaintenanceMode(false),
                          icon: const Icon(Icons.build),
                          label: const Text('Enable Maintenance'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _toggleMaintenanceMode(true),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Disable Maintenance'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityAudit() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security Audit & Monitoring',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),

          // Security Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.security, color: Colors.green, size: 32),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Security Status: SECURE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Last scan: ${DateTime.now().subtract(const Duration(minutes: 30)).toString().substring(11, 16)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _runSecurityScan(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Scan Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Security Metrics
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildSecurityMetric('Failed Login Attempts', '23', Colors.red),
              _buildSecurityMetric('Blocked IPs', '156', Colors.red),
              _buildSecurityMetric('Active Sessions', '1,247', Colors.green),
              _buildSecurityMetric('Encryption Strength', 'AES-256', Colors.blue),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Security Events
          const Text(
            'Recent Security Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              final events = [
                'Admin login from secure IP',
                'Database backup completed',
                'New admin user created',
                'Security patch applied',
                'Failed login attempt blocked',
                'API rate limiting triggered',
                'SSL certificate renewed',
                'File upload scanning enabled',
                'Password reset requested',
                'System integrity check passed',
              ];

              final eventTypes = [
                'info', 'info', 'info', 'info', 'warning', 'warning', 'info', 'info', 'info', 'info'
              ];

              final event = events[index % events.length];
              final eventType = eventTypes[index % eventTypes.length];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: eventType == 'warning' ? Colors.red : Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(event),
                  subtitle: Text('2${index + 1}h ago'),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _viewSecurityEventDetails(index),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Security Controls
          const Text(
            'Security Controls',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSecurityControlButton('Enable 2FA', Icons.lock),
              _buildSecurityControlButton('Block IP', Icons.block),
              _buildSecurityControlButton('Audit Logs', Icons.history),
              _buildSecurityControlButton('Certificate Manager', Icons.security),
              _buildSecurityControlButton('Backdoor Scanner', Icons.search),
              _buildSecurityControlButton('Incident Response', Icons.emergency),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalMetricCard(String title, String value, IconData icon, Color color, String change) {
    return Card(
      elevation: 6,
      shadowColor: color.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const Spacer(),
                Text(
                  change,
                  style: TextStyle(
                    color: change.contains('+') ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionCard(String region, String users, String growth) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              region,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              users,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              growth,
              style: TextStyle(
                fontSize: 12,
                color: growth.contains('+') ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection() {
    final alerts = [
      'High CPU usage on server #2',
      'Security update available',
      'Database backup due in 2 hours',
      'New version deployment pending',
    ];

    return Column(
      children: List.generate(
        alerts.length,
        (index) => Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(child: Text(alerts[index])),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {},
                iconSize: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalStatCard(String title, String value, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(String title, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.grey.shade200,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
    );
  }

  Widget _buildSystemControlCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerMetric(String metric, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          metric,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityMetric(String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityControlButton(String title, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16),
      label: Text(title, textAlign: TextAlign.center),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Suspended':
        return Colors.red;
      case 'On Leave':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout from Super Admin Panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/admin/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showSystemSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.security),
              title: Text('Security Configuration'),
            ),
            ListTile(
              leading: Icon(Icons.storage),
              title: Text('Database Settings'),
            ),
            ListTile(
              leading: Icon(Icons.backup),
              title: Text('Backup Configuration'),
            ),
            ListTile(
              leading: Icon(Icons.monitor),
              title: Text('Monitoring Setup'),
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

  void _addNewAdmin(BuildContext context) {
    // Implementation for adding new admin
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add new admin functionality coming soon')),
    );
  }

  void _handleAdminAction(String action, int index) {
    // Handle admin actions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Admin action: $action')),
    );
  }

  void _generateComprehensiveReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating comprehensive report...')),
    );
  }

  void _toggleMaintenanceMode(bool enable) {
    String message = enable ? 'Maintenance mode disabled' : 'Maintenance mode enabled';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: enable ? Colors.green : Colors.orange,
      ),
    );
  }

  void _runSecurityScan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Security scan initiated...')),
    );
  }

  void _viewSecurityEventDetails(int index) {
    // Show security event details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Security event $index details')),
    );
  }

  Widget _buildSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language Settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Theme Settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
