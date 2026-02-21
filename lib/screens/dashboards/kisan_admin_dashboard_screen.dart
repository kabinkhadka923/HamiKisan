import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class KisanAdminDashboardScreen extends StatelessWidget {
  const KisanAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kisan-Admin Dashboard'),
        backgroundColor: const Color(0xFF1A237E),
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
            Text(
              'Welcome, ${auth.currentUser?.name ?? "Admin"}!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildActionCard(Icons.people_outline, 'Farmers', '1,234', Colors.green, () => _showFarmersDialog(context)),
            _buildActionCard(Icons.medical_services_outlined, 'Doctors', '56', Colors.blue, () => _showDoctorsDialog(context)),
            _buildActionCard(Icons.inventory_outlined, 'Marketplace', '789', Colors.orange, () => _showMarketplaceDialog(context)),
            _buildActionCard(Icons.article_outlined, 'Posts', '432', Colors.purple, () => _showPostsDialog(context)),
            _buildActionCard(Icons.notifications_outlined, 'Notifications', 'Send', Colors.teal, () => _showNotificationsDialog(context)),
            _buildActionCard(Icons.analytics_outlined, 'Analytics', 'View', Colors.indigo, () => _showAnalyticsDialog(context)),
            _buildActionCard(Icons.palette, 'App Design', 'Limited', Colors.grey, () => _showSnackbar(context, 'Access Denied: Super Admin only')),
            _buildActionCard(Icons.image, 'Media Assets', 'Limited', Colors.grey, () => _showSnackbar(context, 'Access Denied: Super Admin only')),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, String value, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }

  void _showFarmersDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Text('Manage Farmers'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () => setState(() {}),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            height: 400,
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search farmers...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final status = index % 3 == 0 ? 'Pending' : index % 3 == 1 ? 'Approved' : 'Suspended';
                      final color = status == 'Pending' ? Colors.orange : status == 'Approved' ? Colors.green : Colors.red;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.2),
                            child: Icon(Icons.person, color: color),
                          ),
                          title: Text('Farmer ${index + 1}'),
                          subtitle: Text('Phone: 980000000$index • $status'),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility, size: 18), SizedBox(width: 8), Text('View Details')])),
                              const PopupMenuItem(value: 'approve', child: Row(children: [Icon(Icons.check, size: 18, color: Colors.green), SizedBox(width: 8), Text('Approve')])),
                              const PopupMenuItem(value: 'suspend', child: Row(children: [Icon(Icons.block, size: 18, color: Colors.orange), SizedBox(width: 8), Text('Suspend')])),
                              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.grey), SizedBox(width: 8), Text('Delete (Restricted)')])),
                            ],
                            onSelected: (value) {
                              if (value == 'view') {
                                _showFarmerDetails(context, index);
                              } else if (value == 'delete') {
                                _showSnackbar(context, 'Access Denied: Only Super Admin can delete users');
                              } else {
                                setState(() {});
                                _showSnackbar(context, 'Farmer ${index + 1} $value successfully');
                              }
                            },
                          ),
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
              label: const Text('Export CSV'),
              onPressed: () => _showSnackbar(context, 'Exporting farmers data...'),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      ),
    );
  }

  void _showFarmerDetails(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Farmer ${index + 1} Details'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Name', 'Farmer ${index + 1}'),
              _buildDetailRow('Phone', '980000000$index'),
              _buildDetailRow('District', 'Kathmandu'),
              _buildDetailRow('Farming Type', 'Vegetable'),
              _buildDetailRow('Registered', '2024-01-15'),
              _buildDetailRow('Products Listed', '${index + 3}'),
              _buildDetailRow('Total Sales', 'Rs. ${(index + 1) * 5000}'),
            ],
          ),
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
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showDoctorsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Manage Kisan Doctors'),
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
                          hintText: 'Search doctors...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      onPressed: () => _showAddDoctorDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final verified = index % 2 == 0;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: verified ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                            child: Icon(Icons.medical_services, color: verified ? Colors.green : Colors.orange),
                          ),
                          title: Text('Dr. Doctor ${index + 1}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Crop Disease Specialist'),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: Colors.amber),
                                  Text(' 4.${8 - index} • ${20 + index * 5} consultations'),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!verified)
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () {
                                    setState(() {});
                                    _showSnackbar(context, 'Doctor verified');
                                  },
                                ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'view', child: Text('View Profile')),
                                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
                                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                ],
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    _showSnackbar(context, 'Access Denied: Only Super Admin can delete users');
                                  } else {
                                    setState(() {});
                                    _showSnackbar(context, 'Doctor $value');
                                  }
                                },
                              ),
                            ],
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

  void _showAddDoctorDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final specializationController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Kisan Doctor'),
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
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: specializationController,
                decoration: const InputDecoration(labelText: 'Specialization', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackbar(context, 'Doctor added successfully');
            },
            child: const Text('Add Doctor'),
          ),
        ],
      ),
    );
  }

  void _showMarketplaceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Manage Marketplace'),
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
                          hintText: 'Search products...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: 'All',
                      items: ['All', 'Pending', 'Approved', 'Rejected'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() {}),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      final status = index % 3 == 0 ? 'Pending' : index % 3 == 1 ? 'Approved' : 'Rejected';
                      final color = status == 'Pending' ? Colors.orange : status == 'Approved' ? Colors.green : Colors.red;
                      return Card(
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                          title: Text('Product ${index + 1}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Price: Rs. ${(index + 1) * 100}'),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(status, style: TextStyle(color: color, fontSize: 11)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Seller: Farmer ${index + 1}', style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (status == 'Pending') ...[
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green, size: 20),
                                  onPressed: () {
                                    setState(() {});
                                    _showSnackbar(context, 'Product approved');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                                  onPressed: () {
                                    setState(() {});
                                    _showSnackbar(context, 'Product rejected');
                                  },
                                ),
                              ],
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'view', child: Text('View Details')),
                                  const PopupMenuItem(value: 'edit', child: Text('Edit Price')),
                                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                ],
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    _showSnackbar(context, 'Access Denied: Only Super Admin can delete');
                                  } else {
                                    _showSnackbar(context, 'Product $value');
                                  }
                                },
                              ),
                            ],
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
              label: const Text('Export'),
              onPressed: () => _showSnackbar(context, 'Exporting products...'),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      ),
    );
  }

  void _showPostsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Posts'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: ListView.builder(
            itemCount: 6,
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.article, color: Colors.purple),
              title: Text('Post ${index + 1}'),
              subtitle: const Text('Community post content...'),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'approve', child: Text('Approve')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    _showSnackbar(context, 'Access Denied: Only Super Admin can delete');
                  } else {
                    _showSnackbar(context, 'Post $value');
                  }
                },
              ),
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'Info';
    String selectedTarget = 'All Farmers';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Send Notification'),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Notification Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.message),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Info', 'Warning', 'Alert', 'Success'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setState(() => selectedType = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedTarget,
                        decoration: const InputDecoration(
                          labelText: 'Send To',
                          border: OutlineInputBorder(),
                        ),
                        items: ['All Farmers', 'All Doctors', 'All Users', 'Specific District'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setState(() => selectedTarget = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: Text('Send to $selectedTarget'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      if (titleController.text.isEmpty || messageController.text.isEmpty) {
                        _showSnackbar(context, 'Please fill all fields');
                        return;
                      }
                      Navigator.pop(context);
                      _showSnackbar(context, 'Notification sent to $selectedTarget');
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
        ),
      ),
    );
  }

  void _showAnalyticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('District Analytics'),
        content: SizedBox(
          width: 450,
          height: 400,
          child: ListView(
            children: [
              _buildAnalyticItem('Total Revenue', 'Rs. 45,000', Icons.attach_money, Colors.green),
              _buildAnalyticItem('Active Users', '1,290', Icons.people, Colors.blue),
              _buildAnalyticItem('Active Today', '234', Icons.trending_up, Colors.green),
              _buildAnalyticItem('New This Week', '45', Icons.new_releases, Colors.orange),
              _buildAnalyticItem('Products Listed', '789', Icons.inventory, Colors.purple),
              _buildAnalyticItem('Consultations', '156', Icons.chat, Colors.teal),
              _buildAnalyticItem('Growth Rate', '+18%', Icons.trending_up, Colors.teal),
              _buildAnalyticItem('Avg Response Time', '2.5 hrs', Icons.timer, Colors.blue),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
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

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
