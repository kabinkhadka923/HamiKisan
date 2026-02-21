import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/kisan_doctor_models.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kisan_doctor_provider.dart';
import '../../widgets/localized_text.dart';
import '../consultation_contacts_screen.dart';
import '../kisan_doctor/appointments_screen.dart';
import '../kisan_doctor/consultation_screen.dart';
import '../kisan_doctor/feedback_screen.dart';
import '../notifications_screen.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  Future<void> _ensureDoctorDataLoaded(
      BuildContext context, User doctor) async {
    final provider = context.read<KisanDoctorProvider>();
    await provider.initialize(doctor.id);
  }

  Future<void> _openDoctorSection({
    required BuildContext context,
    required User doctor,
    required WidgetBuilder builder,
  }) async {
    await _ensureDoctorDataLoaded(context, doctor);
    if (!context.mounted) return;

    final provider = context.read<KisanDoctorProvider>();
    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: ${provider.error}')),
      );
      return;
    }
    provider.clearSelection();

    await Navigator.push(
      context,
      MaterialPageRoute(builder: builder),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final doctor = auth.currentUser;

    if (doctor == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const LocalizedText('kisan_doctor_dashboard'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: auth.logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('welcome_doctor').replaceAll(
                  '{name}', doctor.name.isNotEmpty ? doctor.name : 'Doctor'),
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
            const LocalizedText(
              'doctor_actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActionTile(
                Icons.chat_outlined, context.tr('view_consultations'), () {
              _openDoctorSection(
                context: context,
                doctor: doctor,
                builder: (_) => ConsultationScreen(doctor: doctor),
              );
            }),
            _buildActionTile(
                Icons.pending_actions, context.tr('pending_queries'), () {
              _openDoctorSection(
                context: context,
                doctor: doctor,
                builder: (_) => ConsultationScreen(
                  doctor: doctor,
                  initialStatusFilter: CaseStatus.ongoing,
                ),
              );
            }),
            _buildActionTile(Icons.chat_bubble, context.tr('chat_with_users'),
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ConsultationContactsScreen(),
                ),
              );
            }),
            _buildActionTile(
                Icons.article_outlined, context.tr('write_article'), () {
              _showInfoDialog(
                context: context,
                title: 'Write Article',
                content:
                    'This feature is under development. You can write articles to help farmers with farming tips and advice.',
              );
            }),
            _buildActionTile(
                Icons.analytics_outlined, context.tr('my_statistics'), () {
              _showInfoDialog(
                context: context,
                title: 'My Statistics',
                content:
                    'Total Consultations: 1,234\nPending Cases: 12\nResolved Cases: 1,222\nAverage Rating: 4.8',
              );
            }),
            const SizedBox(height: 16),
            _buildActionTile(
                Icons.calendar_today, context.tr('manage_appointments'), () {
              _openDoctorSection(
                context: context,
                doctor: doctor,
                builder: (_) => AppointmentsScreen(doctor: doctor),
              );
            }),
            _buildActionTile(Icons.feedback, context.tr('view_feedback'), () {
              _openDoctorSection(
                context: context,
                doctor: doctor,
                builder: (_) => FeedbackScreen(doctor: doctor),
              );
            }),
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
            Text(
              count,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
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

  void _showInfoDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
