import 'package:flutter/material.dart';
import '../admin/api_settings_screen.dart';
import '../admin/kalimati_items_screen.dart';
import '../admin/farmer_listings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final bool isSuperAdmin;

  const AdminDashboardScreen({
    super.key,
    this.isSuperAdmin = false,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _menuItems = [
    'Dashboard',
    'Farmers',
    'Doctors',
    'Marketplace',
    'Weather & Prices',
    'Community',
    'Notifications',
    'Security',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSuperAdmin ? 'Super Admin Panel' : 'Kisan Admin Panel'),
        backgroundColor: widget.isSuperAdmin ? Colors.red.shade900 : Colors.blue.shade700,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(),
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(),
            tooltip: 'Search',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleProfileMenu(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.selected,
            destinations: List.generate(
              _menuItems.length,
              (index) => NavigationRailDestination(
                icon: Icon(_getMenuIcon(index)),
                label: Text(_menuItems[index]),
              ),
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildFarmersManagement();
      case 2:
        return _buildDoctorsManagement();
      case 3:
        return _buildMarketplaceManagement();
      case 4:
        return _buildWeatherAndPrices();
      case 5:
        return _buildCommunityManagement();
      case 6:
        return _buildNotificationsPanel();
      case 7:
        return _buildSecurityPanel();
      case 8:
        return _buildSettings();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dashboard Overview', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              _buildMetricCard('Total Farmers', '2,458', Icons.people, Colors.green, '+12%'),
              _buildMetricCard('Active Today', '1,234', Icons.person_add, Colors.blue, '+8%'),
              _buildMetricCard('Kisan Doctors', '87', Icons.medical_services, Colors.orange, '+5%'),
              _buildMetricCard('Marketplace Items', '1,203', Icons.store, Colors.purple, '+24%'),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Recent Activities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildActivityList(),
          const SizedBox(height: 32),
          const Text('System Alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAlertsList(),
        ],
      ),
    );
  }

  Widget _buildFarmersManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Farmers Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showFarmerDetails(),
                icon: const Icon(Icons.add),
                label: const Text('Add Farmer'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search farmers...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: 'all',
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFarmersTable(),
        ],
      ),
    );
  }

  Widget _buildDoctorsManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kisan Doctors Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showDoctorForm(),
                icon: const Icon(Icons.add),
                label: const Text('Add Doctor'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDoctorsGrid(),
        ],
      ),
    );
  }

  Widget _buildMarketplaceManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Marketplace Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FarmerListingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.people),
                    label: const Text('Farmer Listings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KalimatiItemsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Kalimati Items'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: 'all',
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending Review')),
                  DropdownMenuItem(value: 'approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProductsGrid(),
        ],
      ),
    );
  }

  Widget _buildWeatherAndPrices() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weather & Market Prices', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FarmerListingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.people),
                    label: const Text('Farmer Listings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KalimatiItemsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Kalimati Items'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Weather API Status', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('✓ Connected', style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Last Updated', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(DateTime.now().toString().substring(0, 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Today\'s Market Prices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPricesTable(),
        ],
      ),
    );
  }

  Widget _buildCommunityManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Community & Posts Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildPostsList(),
        ],
      ),
    );
  }

  Widget _buildNotificationsPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notifications Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showNotificationForm(),
                icon: const Icon(Icons.add),
                label: const Text('Send Notification'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildNotificationsList(),
        ],
      ),
    );
  }

  Widget _buildSecurityPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Security & Logs', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('System Status', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('✓ Secure', style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Failed Attempts', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('23 (Last 24h)'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Recent Security Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSecurityLogsList(),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Admin Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Language Management', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Manage Languages'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Manage Translations'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('System Configuration', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Database Settings'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ApiSettingsScreen(),
                              ),
                            );
                          },
                          child: const Text('API Configuration'),
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

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String change) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(change, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
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
        (index) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(activities[index]),
            subtitle: Text('${index + 1}h ago'),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsList() {
    final alerts = [
      'High CPU usage detected',
      'Database backup due in 2 hours',
      'New security update available',
    ];

    return Column(
      children: List.generate(
        alerts.length,
        (index) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: Colors.red.shade50,
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: Text(alerts[index]),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFarmersTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('District')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: List.generate(
          10,
          (index) => DataRow(
            cells: [
              DataCell(Text('Farmer ${index + 1}')),
              DataCell(Text('98${index}1234567')),
              const DataCell(Text('Kathmandu')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Active', style: TextStyle(color: Colors.green)),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorsGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: List.generate(
        6,
        (index) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text('Dr. ${String.fromCharCode(65 + index)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Rating: ${4.5 + (index * 0.1)}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                        child: const Text('Edit', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: List.generate(
        8,
        (index) => Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 80,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image),
                ),
                const SizedBox(height: 8),
                Text('Product ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Text('₹${(index + 1) * 500}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        child: const Text('✓', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        child: const Text('✕', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPricesTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Item')),
          DataColumn(label: Text('Today\'s Price')),
          DataColumn(label: Text('Last Week')),
          DataColumn(label: Text('Trend')),
          DataColumn(label: Text('District')),
        ],
        rows: List.generate(
          7,
          (index) => DataRow(
            cells: [
              DataCell(Text(['Rice', 'Wheat', 'Maize', 'Potato', 'Tomato', 'Onion', 'Garlic'][index])),
              DataCell(Text('₹${(index + 1) * 50}')),
              DataCell(Text('₹${(index + 1) * 45}')),
              DataCell(
                Text(
                  index % 2 == 0 ? '↑ +5%' : '↓ -3%',
                  style: TextStyle(color: index % 2 == 0 ? Colors.green : Colors.red),
                ),
              ),
              const DataCell(Text('Kathmandu')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    return Column(
      children: List.generate(
        5,
        (index) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Post ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Pending', style: TextStyle(color: Colors.blue, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Post content preview...', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Approve'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Column(
      children: List.generate(
        5,
        (index) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.notifications),
            title: Text('Notification ${index + 1}'),
            subtitle: Text('Sent ${index + 1}h ago'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityLogsList() {
    return Column(
      children: List.generate(
        10,
        (index) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: index % 3 == 0 ? Colors.red : Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            title: Text(['Login attempt', 'Data access', 'Settings change', 'User deletion'][index % 4]),
            subtitle: Text(DateTime.now().subtract(Duration(hours: index)).toString().substring(11, 16)),
          ),
        ),
      ),
    );
  }

  IconData _getMenuIcon(int index) {
    const icons = [
      Icons.dashboard,
      Icons.people,
      Icons.medical_services,
      Icons.store,
      Icons.cloud,
      Icons.forum,
      Icons.notifications,
      Icons.security,
      Icons.settings,
    ];
    return icons[index];
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications panel')),
    );
  }

  void _showSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search functionality')),
    );
  }

  void _handleProfileMenu(String value) {
    if (value == 'logout') {
      Navigator.pushReplacementNamed(context, '/admin/login');
    }
  }

  void _showFarmerDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add farmer form')),
    );
  }

  void _showDoctorForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add doctor form')),
    );
  }

  void _showNotificationForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Send notification form')),
    );
  }
}
