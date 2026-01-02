import 'package:flutter/material.dart';

class BroadcastScreen extends StatelessWidget {
  const BroadcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast System'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Send Broadcast Message', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Target Audience'),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Users')),
                        DropdownMenuItem(value: 'farmers', child: Text('Farmers Only')),
                        DropdownMenuItem(value: 'doctors', child: Text('Doctors Only')),
                        DropdownMenuItem(value: 'admins', child: Text('Admins Only')),
                      ],
                      onChanged: (v) {},
                    ),
                    const SizedBox(height: 16),
                    const TextField(
                      decoration: InputDecoration(labelText: 'Message Title'),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 16),
                    const TextField(
                      decoration: InputDecoration(labelText: 'Message Content'),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.send),
                      label: const Text('Send Broadcast'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Recent Broadcasts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.broadcast_on_home, color: Colors.orange),
                    title: Text('Broadcast ${index + 1}'),
                    subtitle: Text('Sent to All Users - ${DateTime.now().subtract(Duration(hours: index + 1)).toString().substring(0, 16)}'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
