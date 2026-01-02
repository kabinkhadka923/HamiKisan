import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/localized_text.dart';
import '../../providers/localization_provider.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const LocalizedText('kisan_doctor_dashboard'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context
                  .tr('welcome_doctor')
                  .replaceAll('{name}', auth.currentUser?.name ?? "Doctor"),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildCard(
                    context.tr('consultations'), '45', Icons.chat, Colors.blue),
                _buildCard(
                    context.tr('pending'), '12', Icons.pending, Colors.orange),
                _buildCard(context.tr('resolved'), '33', Icons.check_circle,
                    Colors.green),
                _buildCard(
                    context.tr('rating'), '4.8', Icons.star, Colors.amber),
              ],
            ),
            const SizedBox(height: 24),
            const LocalizedText('doctor_actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildActionTile(
                Icons.chat_outlined, context.tr('view_consultations'), () {}),
            _buildActionTile(
                Icons.pending_actions, context.tr('pending_queries'), () {}),
            _buildActionTile(
                Icons.article_outlined, context.tr('write_article'), () {}),
            _buildActionTile(
                Icons.analytics_outlined, context.tr('my_statistics'), () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String count, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(count,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E7D32)),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
