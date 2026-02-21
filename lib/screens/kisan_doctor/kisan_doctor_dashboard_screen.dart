import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/kisan_doctor_models.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kisan_doctor_provider.dart';
import '../../utils/app_colors.dart';
import '../consultation_chat_screen.dart';
import '../consultation_contacts_screen.dart';
import '../video_call_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class KisanDoctorDashboardScreen extends StatefulWidget {
  final User doctor;

  const KisanDoctorDashboardScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<KisanDoctorDashboardScreen> createState() =>
      _KisanDoctorDashboardScreenState();
}

class _KisanDoctorDashboardScreenState
    extends State<KisanDoctorDashboardScreen> {
  int _selectedIndex = 0;
  CaseStatus _selectedFilter = CaseStatus.new_;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KisanDoctorProvider>().initialize(widget.doctor.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KisanDoctorProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: _buildGradientHeader(provider),
          backgroundColor: const Color(0xFFF6F8F6),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildCurrentTab(provider),
          floatingActionButton: _selectedIndex == 0
              ? FloatingActionButton.extended(
                  backgroundColor: _isOnline
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade500,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.video_call),
                  label: const Text('Start Live Consultation'),
                  onPressed: _isOnline
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ConsultationContactsScreen(),
                            ),
                          );
                        }
                      : null,
                )
              : null,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF2E7D32),
            unselectedItemColor: Colors.grey.shade600,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.agriculture_outlined),
                activeIcon: Icon(Icons.agriculture),
                label: 'Cases',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Appointments',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildGradientHeader(KisanDoctorProvider provider) {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'नमस्ते ${widget.doctor.name}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            widget.doctor.specialization?.isNotEmpty == true
                ? widget.doctor.specialization!
                : 'Agriculture Specialist',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        _buildAvailabilityToggle(),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsScreen(doctor: widget.doctor),
                  ),
                );
              },
            ),
            if (provider.unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    provider.unreadCount > 99
                        ? '99+'
                        : '${provider.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailabilityToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _isOnline ? 'Online' : 'Offline',
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
        Transform.scale(
          scale: 0.75,
          child: Switch(
            value: _isOnline,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha: 0.4),
            inactiveThumbColor: Colors.grey.shade200,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
            onChanged: (value) {
              setState(() => _isOnline = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTab(KisanDoctorProvider provider) {
    switch (_selectedIndex) {
      case 0:
        return _buildCasesTab(provider);
      case 1:
        return _buildAppointmentsTab(provider);
      case 2:
        return _buildProfileTab();
      default:
        return _buildCasesTab(provider);
    }
  }

  Widget _buildCasesTab(KisanDoctorProvider provider) {
    final filteredCases = provider.cases
        .where((case_) => case_.status == _selectedFilter)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Failed to load cases: ${provider.error}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _buildFilterChip(CaseStatus.new_, 'New'),
              const SizedBox(width: 8),
              _buildFilterChip(CaseStatus.ongoing, 'Pending'),
              const SizedBox(width: 8),
              _buildFilterChip(CaseStatus.resolved, 'Resolved'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: filteredCases.isEmpty
              ? Center(
                  child: Text(
                    _selectedFilter == CaseStatus.new_
                        ? 'No new cases'
                        : _selectedFilter == CaseStatus.ongoing
                            ? 'No pending cases'
                            : 'No resolved cases',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                  itemCount: filteredCases.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final case_ = filteredCases[index];
                    return _buildCaseCard(case_, provider);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(CaseStatus status, String label) {
    final selected = _selectedFilter == status;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: const Color(0xFF2E7D32).withValues(alpha: 0.16),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF1B5E20) : Colors.grey.shade700,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: selected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
      ),
      onSelected: (_) => setState(() => _selectedFilter = status),
    );
  }

  Widget _buildCaseCard(Case case_, KisanDoctorProvider provider) {
    final farmer = _farmerFromCase(case_);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.eco, color: Color(0xFF2E7D32), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        case_.cropType,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        case_.problemDescription,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _statusPill(case_.status),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM, HH:mm').format(case_.updatedAt),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConsultationChatScreen(peer: farmer),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: const Text('Chat'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoCallScreen(
                          doctorName: farmer.name,
                          doctorSpecialty: 'Farmer Consultation',
                          callId:
                              'call_${DateTime.now().millisecondsSinceEpoch}',
                          recipientId: farmer.id,
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2E7D32).withValues(alpha: 0.14),
                    foregroundColor: const Color(0xFF1B5E20),
                  ),
                  icon: const Icon(Icons.video_call, size: 16),
                  label: const Text('Live'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(CaseStatus status) {
    final (label, color) = switch (status) {
      CaseStatus.new_ => ('New', Colors.orange),
      CaseStatus.ongoing => ('Pending', Colors.blue),
      CaseStatus.resolved => ('Resolved', Colors.green),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAppointmentsTab(KisanDoctorProvider provider) {
    final appointments = [...provider.appointments]
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    if (appointments.isEmpty) {
      return const Center(child: Text('No appointments'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final isPending = appointment.status == AppointmentStatus.pending;

        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farmer: ${appointment.farmerId}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a')
                      .format(appointment.dateTime),
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                if (appointment.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 6),
                  Text(
                    appointment.notes!,
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    _appointmentStatusChip(appointment.status),
                    const Spacer(),
                    if (isPending) ...[
                      TextButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await provider
                              .rejectAppointment(appointment.appointmentId);
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(
                                content: Text('Appointment rejected')),
                          );
                        },
                        child: const Text('Reject'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await provider
                              .approveAppointment(appointment.appointmentId);
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(
                                content: Text('Appointment accepted')),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                        ),
                        child: const Text('Accept'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _appointmentStatusChip(AppointmentStatus status) {
    final (label, color) = switch (status) {
      AppointmentStatus.pending => ('Pending', Colors.orange),
      AppointmentStatus.accepted => ('Accepted', Colors.green),
      AppointmentStatus.rejected => ('Rejected', Colors.red),
      AppointmentStatus.completed => ('Completed', Colors.blueGrey),
    };

    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide.none,
      labelStyle: TextStyle(
        color: color.shade700,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildProfileTab() {
    final doctor = widget.doctor;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.18),
                backgroundImage: doctor.profilePicture != null
                    ? NetworkImage(doctor.profilePicture!)
                    : null,
                child: doctor.profilePicture == null
                    ? const Icon(Icons.person, color: Color(0xFF2E7D32))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      doctor.specialization ?? 'Agriculture Specialist',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      doctor.email,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(doctor: doctor),
              ),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit Full Profile'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {
            context.read<AuthProvider>().logout();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade700,
            side: BorderSide(color: Colors.red.shade300),
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }

  User _farmerFromCase(Case case_) {
    final id = case_.farmerId;
    final suffix = id.length <= 4 ? id : id.substring(id.length - 4);

    return User(
      id: id,
      email: '$id@farm.local',
      name: 'Farmer $suffix',
      role: UserRole.farmer,
      status: UserStatus.approved,
      createdAt: DateTime.now(),
    );
  }
}
