import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/localization_provider.dart';
import '../models/user.dart';
import '../widgets/localized_text.dart';
import 'edit_profile_screen.dart';
import 'my_posts_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool hasScaffold;
  const ProfileScreen({super.key, this.hasScaffold = true});

  @override
  Widget build(BuildContext context) {
    // Assuming AuthProvider holds the current user's data.
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // Fallback for when user is not logged in or data is not available.
    final bodyContent = _buildBody(context, user);

    if (!hasScaffold) return bodyContent;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const LocalizedText('profile'),
          backgroundColor: const Color(0xFF4CAF50),
        ),
        body: const Center(
          child: LocalizedText('please_login'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: LocalizedText('profile'),
        backgroundColor: const Color(0xFF4CAF50),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Implement logout functionality
              Provider.of<AuthProvider>(context, listen: false).logout();
              // Maybe navigate to login screen
            },
            tooltip: context.tr('logout'),
          ),
        ],
      ),
      body: bodyContent,
    );
  }

  Widget _buildBody(BuildContext context, User? user) {
    if (user == null) {
      return const Center(
        child: LocalizedText('please_login'),
      );
    }
    return ListView(
      children: [
        const SizedBox(height: 20),
        _buildProfileHeader(context, user),
        const SizedBox(height: 30),
        _buildProfileOption(
          context,
          icon: Icons.edit,
          title: context.tr('edit_profile'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const EditProfileScreen(),
            ));
          },
        ),
        _buildProfileOption(
          context,
          icon: Icons.language,
          title: context.tr('select_language'),
          onTap: () => _showLanguageDialog(context),
        ),
        _buildProfileOption(
          context,
          icon: Icons.article,
          title: context.tr('my_posts'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const MyPostsScreen(),
            ));
          },
        ),
        _buildProfileOption(
          context,
          icon: Icons.settings,
          title: context.tr('settings'),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            ));
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileCompletion = authProvider.profileCompletion;

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: user.profilePicture != null
              ? NetworkImage(user.profilePicture!)
              : null,
          child: user.profilePicture == null
              ? const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (user.isVerified) ...[
              const SizedBox(width: 8),
              const Icon(Icons.verified, color: Colors.blue, size: 20),
            ]
          ],
        ),
        const SizedBox(height: 4),
        Text(
          user.role.displayName,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.tr('profile_completion'),
                      style: const TextStyle(fontSize: 14)),
                  Text('$profileCompletion%',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: profileCompletion / 100,
                backgroundColor: Colors.grey.shade300,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4CAF50)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localizationProvider =
        Provider.of<LocalizationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('choose_language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Radio<String>(
                  value: 'English',
                  groupValue: localizationProvider.currentLanguage,
                  onChanged: (value) {},
                  activeColor: const Color(0xFF4CAF50),
                ),
                title: const Text('English'),
                onTap: () async {
                  await localizationProvider.setLanguage('English');
                  await authProvider.updateLanguage('English');
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Radio<String>(
                  value: 'Nepali',
                  groupValue: localizationProvider.currentLanguage,
                  onChanged: (value) {},
                  activeColor: const Color(0xFF4CAF50),
                ),
                title: const Text('नेपाली (Nepali)'),
                onTap: () async {
                  await localizationProvider.setLanguage('Nepali');
                  await authProvider.updateLanguage('Nepali');
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('cancel')),
            ),
          ],
        );
      },
    );
  }
}
