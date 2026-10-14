import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../edit_profile_screen.dart';
import '../settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final User doctor;

  const ProfileScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundImage: doctor.profilePicture?.isNotEmpty == true
                        ? NetworkImage(doctor.profilePicture!)
                        : null,
                    child: doctor.profilePicture?.isNotEmpty == true
                        ? null
                        : const Icon(Icons.person, size: 44),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    doctor.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (doctor.specialization?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialization!,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (doctor.email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      doctor.email,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (doctor.phoneNumber?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      doctor.phoneNumber!,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('App settings'),
                  subtitle: const Text(
                    'Language, appearance, notifications, and account security',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
