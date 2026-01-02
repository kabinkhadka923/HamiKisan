import 'package:flutter/material.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Backup'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Last Backup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Date: ${DateTime.now().toString().substring(0, 16)}'),
                  const Text('Size: 2.4 GB'),
                  const Text('Status: Success'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.backup),
                    label: const Text('Create Backup Now'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Backup History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...List.generate(5, (index) => Card(
            child: ListTile(
              leading: const Icon(Icons.folder, color: Colors.green),
              title: Text('Backup ${index + 1}'),
              subtitle: Text('${DateTime.now().subtract(Duration(days: index + 1)).toString().substring(0, 10)} - 2.${index}GB'),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {},
              ),
            ),
          )),
        ],
      ),
    );
  }
}
