import 'package:flutter/material.dart';

class AnalyticsPanelScreen extends StatelessWidget {
  const AnalyticsPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: Colors.purple,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _buildMetricCard('Total Users', '12,583', Icons.people, Colors.blue),
          _buildMetricCard('Active Today', '8,742', Icons.people_outline, Colors.green),
          _buildMetricCard('Revenue', '₹2,45,678', Icons.attach_money, Colors.orange),
          _buildMetricCard('Transactions', '1,234', Icons.receipt, Colors.purple),
          _buildMetricCard('New Farmers', '456', Icons.agriculture, Colors.brown),
          _buildMetricCard('Consultations', '789', Icons.chat, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
