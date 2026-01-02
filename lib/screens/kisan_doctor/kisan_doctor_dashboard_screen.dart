import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/kisan_doctor_provider.dart';
import '../../utils/app_colors.dart';
import 'consultation_screen.dart';
import 'appointments_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class KisanDoctorDashboardScreen extends StatefulWidget {
  final User doctor;

  const KisanDoctorDashboardScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<KisanDoctorDashboardScreen> createState() => _KisanDoctorDashboardScreenState();
}

class _KisanDoctorDashboardScreenState extends State<KisanDoctorDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KisanDoctorProvider>().initialize(widget.doctor.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('नमस्ते ${widget.doctor.name}', style: const TextStyle(fontSize: 16)),
            Text(widget.doctor.specialization ?? 'Agriculture Expert', style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          Consumer<KisanDoctorProvider>(
            builder: (context, provider, _) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () => _navigateTo(3),
                ),
                if (provider.unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${provider.unreadCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _navigateTo(4),
          ),
        ],
      ),
      body: Consumer<KisanDoctorProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return IndexedStack(
            index: _selectedIndex,
            children: [
              _buildDashboardView(provider),
              ConsultationScreen(doctor: widget.doctor),
              AppointmentsScreen(doctor: widget.doctor),
              NotificationsScreen(doctor: widget.doctor),
              ProfileScreen(doctor: widget.doctor),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateTo,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Consultation'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _navigateTo(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildDashboardView(KisanDoctorProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          if (provider.stats != null) ...[
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildStatCard('Cases Solved', '${provider.stats!.totalCasesSolved}', Icons.check_circle),
                _buildStatCard('Pending', '${provider.stats!.pendingCases}', Icons.pending_actions),
                _buildStatCard('Rating', '${provider.stats!.averageRating.toStringAsFixed(1)}⭐', Icons.star),
                _buildStatCard('Today', '${provider.stats!.todayAppointments}', Icons.today),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // New Cases Section
          Text('New Cases', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (provider.newCases.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No new cases'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.newCases.length,
              itemBuilder: (context, index) {
                final case_ = provider.newCases[index];
                return _buildCaseCard(case_, provider);
              },
            ),
          const SizedBox(height: 24),

          // Pending Cases Section
          Text('Pending Cases', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (provider.pendingCases.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No pending cases'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.pendingCases.length,
              itemBuilder: (context, index) {
                final case_ = provider.pendingCases[index];
                return _buildCaseCard(case_, provider);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 32),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseCard(dynamic case_, KisanDoctorProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.agriculture, color: AppColors.primaryGreen),
        ),
        title: Text(case_.cropType),
        subtitle: Text(case_.problemDescription, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Chip(
          label: Text(case_.status.name),
          backgroundColor: case_.status.name == 'new' ? Colors.orange : Colors.blue,
        ),
        onTap: () => provider.selectCase(case_.caseId),
      ),
    );
  }
}
