import 'package:flutter/material.dart';

class KisanAdminSecurePanel extends StatefulWidget {
  const KisanAdminSecurePanel({super.key});

  @override
  State<KisanAdminSecurePanel> createState() => _KisanAdminSecurePanelState();
}

class _KisanAdminSecurePanelState extends State<KisanAdminSecurePanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Kisan Admin Panel'),
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(),
            tooltip: 'Logout',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
            tooltip: 'Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
            Tab(text: 'Users', icon: Icon(Icons.people)),
            Tab(text: 'Content', icon: Icon(Icons.article)),
            Tab(text: 'Reports', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboard(),
          _buildUsersManagement(),
          _buildContentManagement(),
          _buildReportsAnalytics(),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kisan Admin Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),

          // Statistics Cards
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(
                'Total Farmers',
                '2,458',
                Icons.people,
                Colors.green,
                '+12%',
              ),
              _buildStatCard(
                'Active Doctors',
                '87',
                Icons.medical_services,
                Colors.blue,
                '+5%',
              ),
              _buildStatCard(
                'Market Items',
                '1,203',
                Icons.store,
                Colors.orange,
                '+24%',
              ),
              _buildStatCard(
                'Pending Approvals',
                '34',
                Icons.pending,
                Colors.red,
                ' lessen',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton('Approve Farmers', Icons.check_circle, Colors.green),
              _buildActionButton('Review Products', Icons.store, Colors.blue),
              _buildActionButton('Manage Content', Icons.article, Colors.orange),
              _buildActionButton('Generate Report', Icons.analytics, Colors.purple),
              _buildActionButton('Send Notification', Icons.notifications, Colors.red),
              _buildActionButton('System Health', Icons.health_and_safety, Colors.teal),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityList(),
        ],
      ),
    );
  }

  Widget _buildUsersManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: 'all',
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Users')),
                  DropdownMenuItem(value: 'farmers', child: Text('Farmers')),
                  DropdownMenuItem(value: 'doctors', child: Text('Doctors')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // User List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              final userTypes = ['Farmer', 'Doctor', 'Farmer', 'Farmer', 'Doctor'];
              final statuses = ['active', 'pending', 'active', 'suspended', 'active'];
              final userType = userTypes[index % userTypes.length];
              final status = statuses[index % statuses.length];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(status),
                    child: Icon(
                      userType == 'Doctor' ? Icons.medical_services : Icons.agriculture,
                      color: Colors.white,
                    ),
                  ),
                  title: Text('User ${index + 1}'),
                  subtitle: Text('$userType • Kathmandu'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
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
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showUserActions(context, index),
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

  Widget _buildContentManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Content Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Content categories
          const Text(
            'Content Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildContentCategoryChip('Farm Tips', 45),
              _buildContentCategoryChip('Articles', 23),
              _buildContentCategoryChip('Videos', 15),
              _buildContentCategoryChip('Images', 32),
              _buildContentCategoryChip('Pending Review', 8),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            'Recent Content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Content List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            itemBuilder: (context, index) {
              final titles = [
                'Rice Cultivation Best Practices',
                'Organic Farming Guide',
                'Pesticide Safe Usage',
                'Weather Impact on Crops',
                'New Government Subsidy',
                'Doctor Response to Farmer Query',
                'Market Price Analysis'
              ];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(titles[index % titles.length]),
                  subtitle: Text('Published ${index + 1} days ago • By Dr. Sharma'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () {},
                        tooltip: 'Preview',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {},
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {},
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _addNewContent(context),
              icon: const Icon(Icons.add),
              label: const Text('Add New Content'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reports & Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Key Metrics
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMetricCard('User Registrations', '156', '+22%', Colors.green),
              _buildMetricCard('Queries Answered', '89', '+15%', Colors.blue),
              _buildMetricCard('Products Sold', '234', '+8%', Colors.orange),
              _buildMetricCard('Revenue', '₹45,678', '+12%', Colors.purple),
            ],
          ),

          const SizedBox(height: 24),

          // Report Generation
          const Text(
            'Generate Reports',
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
              _buildReportButton('User Activity Report'),
              _buildReportButton('Doctor Performance Report'),
              _buildReportButton('Marketplace Analytics'),
              _buildReportButton('Content Engagement Report'),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            'System Health',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // System health indicators
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHealthIndicator('Server Status', 'Healthy', Colors.green),
                  _buildHealthIndicator('Database', 'Healthy', Colors.green),
                  _buildHealthIndicator('API Response', '200ms avg', Colors.orange),
                  _buildHealthIndicator('Storage', '85% used', Colors.yellow),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _exportReport(),
              icon: const Icon(Icons.download),
              label: const Text('Export Dashboard Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String change) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
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
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3 - 16,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 18),
        label: Text(title, textAlign: TextAlign.center),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    final activities = [
      'New farmer registration approved',
      'Doctor consultation completed',
      'Market price updated',
      'Content moderation performed',
      'System backup completed',
    ];

    return Column(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(activities[index]),
              const Spacer(),
              Text('${index + 1}h ago'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentCategoryChip(String title, int count) {
    return Chip(
      label: Text('$title ($count)'),
      backgroundColor: Colors.blue.shade100,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildReportButton(String title) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: Colors.grey.shade200,
        foregroundColor: Colors.black87,
      ),
      child: Text(title),
    );
  }

  Widget _buildMetricCard(String title, String value, String change, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  change.contains('+') ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: change.contains('+') ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
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
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(String metric, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(metric),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/admin/login');
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notification Settings'),
            ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text('Security Settings'),
            ),
            ListTile(
              leading: Icon(Icons.backup),
              title: Text('Backup Settings'),
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

  void _showUserActions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('View Profile'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit User'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Suspend User'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete User'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _addNewContent(BuildContext context) {
    // Navigate to content creation screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Content creation functionality coming soon')),
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report export functionality coming soon')),
    );
  }
}
