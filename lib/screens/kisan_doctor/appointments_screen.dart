import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../providers/kisan_doctor_provider.dart';
import '../../utils/app_colors.dart';

class AppointmentsScreen extends StatelessWidget {
  final User doctor;

  const AppointmentsScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('Appointments'),
      ),
      body: Consumer<KisanDoctorProvider>(
        builder: (context, provider, _) {
          if (provider.appointments.isEmpty) {
            return const Center(child: Text('No appointments'));
          }

          final pending = provider.appointments
              .where((a) => a.status.name == 'pending')
              .toList();
          final accepted = provider.appointments
              .where((a) => a.status.name == 'accepted')
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pending.isNotEmpty) ...[
                  Text('Pending Requests', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pending.length,
                    itemBuilder: (context, index) {
                      final appointment = pending[index];
                      return _buildAppointmentCard(context, appointment, provider, isPending: true);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                if (accepted.isNotEmpty) ...[
                  Text('Accepted Appointments', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: accepted.length,
                    itemBuilder: (context, index) {
                      final appointment = accepted[index];
                      return _buildAppointmentCard(context, appointment, provider, isPending: false);
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    dynamic appointment,
    KisanDoctorProvider provider, {
    required bool isPending,
  }) {
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
    final dateStr = dateFormat.format(appointment.dateTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person, color: AppColors.primaryGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Farmer ID: ${appointment.farmerId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (appointment.notes != null) ...[
              Text('Notes: ${appointment.notes}', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 12),
            ],
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        provider.approveAppointment(appointment.appointmentId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Appointment approved')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                      child: const Text('Accept', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        provider.rejectAppointment(appointment.appointmentId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Appointment rejected')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Reject', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            else
              Chip(
                label: const Text('Accepted'),
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.2),
              ),
          ],
        ),
      ),
    );
  }
}
