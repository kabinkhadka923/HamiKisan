import 'package:flutter/material.dart';

class SecurityPanelScreen extends StatelessWidget {
  const SecurityPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Panel'),
        backgroundColor: Colors.red,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock, color: Colors.red),
              title: const Text('Two-Factor Authentication'),
              subtitle: const Text('Enable 2FA for all admins'),
              trailing: Switch(value: true, onChanged: (v) {}),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.vpn_key, color: Colors.orange),
              title: const Text('Password Policy'),
              subtitle: const Text('Minimum 8 characters required'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Blocked IPs'),
              subtitle: const Text('156 IPs blocked'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history, color: Colors.blue),
              title: const Text('Login History'),
              subtitle: const Text('View all login attempts'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
