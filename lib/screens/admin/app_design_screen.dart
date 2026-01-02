import 'package:flutter/material.dart';

class AppDesignScreen extends StatelessWidget {
  const AppDesignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Design'),
        backgroundColor: Colors.pink,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.color_lens, color: Colors.pink),
              title: const Text('Primary Color'),
              subtitle: const Text('#4CAF50 (Green)'),
              trailing: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.image, color: Colors.blue),
              title: const Text('App Logo'),
              subtitle: const Text('Upload new logo'),
              trailing: const Icon(Icons.upload),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.wallpaper, color: Colors.purple),
              title: const Text('Background Image'),
              subtitle: const Text('Change background'),
              trailing: const Icon(Icons.upload),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.font_download, color: Colors.orange),
              title: const Text('Font Style'),
              subtitle: const Text('Roboto (Default)'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.dashboard_customize, color: Colors.teal),
              title: const Text('Layout Settings'),
              subtitle: const Text('Customize app layout'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
