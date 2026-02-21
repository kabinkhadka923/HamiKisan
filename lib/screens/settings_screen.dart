import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/localization_provider.dart';
import '../widgets/localized_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final localizationProvider = context.watch<LocalizationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const LocalizedText('settings'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            title: context.tr('general'),
            children: [
              _buildLanguageTile(context, localizationProvider, authProvider),
              _buildNotificationTile(context),
            ],
          ),
          _buildSection(
            context,
            title: context.tr('account'),
            children: [
              _buildChangePasswordTile(context),
              _buildPrivacyTile(context),
            ],
          ),
          _buildSection(
            context,
            title: context.tr('about'),
            children: [
              _buildAboutTile(context),
              _buildVersionTile(context),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                _showLogoutConfirmation(context, authProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(context.tr('logout')),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildLanguageTile(BuildContext context,
      LocalizationProvider localizationProvider, AuthProvider authProvider) {
    return ListTile(
      leading: const Icon(Icons.language, color: Color(0xFF4CAF50)),
      title: Text(context.tr('language')),
      subtitle: Text(localizationProvider.currentLanguage),
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          _showLanguageDialog(context, localizationProvider, authProvider),
    );
  }

  Widget _buildNotificationTile(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications, color: Color(0xFF4CAF50)),
      title: Text(context.tr('notifications')),
      subtitle: Text(context.tr('receive_updates')),
      value: true,
      onChanged: (bool value) {
        // TODO: Implement notification toggle
      },
      activeThumbColor: const Color(0xFF4CAF50),
    );
  }

  Widget _buildChangePasswordTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.lock, color: Color(0xFF4CAF50)),
      title: Text(context.tr('change_password')),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showChangePasswordDialog(context);
      },
    );
  }

  Widget _buildPrivacyTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.privacy_tip, color: Color(0xFF4CAF50)),
      title: Text(context.tr('privacy_policy')),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: Show privacy policy
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('coming_soon'))),
        );
      },
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info, color: Color(0xFF4CAF50)),
      title: Text(context.tr('about_app')),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showAboutDialog(context);
      },
    );
  }

  Widget _buildVersionTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.update, color: Color(0xFF4CAF50)),
      title: Text(context.tr('version')),
      subtitle: const Text('1.0.0'),
    );
  }

  void _showLanguageDialog(BuildContext context,
      LocalizationProvider localizationProvider, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.tr('choose_language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                value: 'English',
                groupValue: localizationProvider.currentLanguage,
                onChanged: (value) async {
                  await localizationProvider.setLanguage('English');
                  await authProvider.updateLanguage('English');
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                activeColor: const Color(0xFF4CAF50),
              ),
              RadioListTile<String>(
                title: const Text('नेपाली (Nepali)'),
                value: 'Nepali',
                groupValue: localizationProvider.currentLanguage,
                onChanged: (value) async {
                  await localizationProvider.setLanguage('Nepali');
                  await authProvider.updateLanguage('Nepali');
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                activeColor: const Color(0xFF4CAF50),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.tr('cancel')),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.tr('change_password')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelText: context.tr('current_password'),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: context.tr('new_password'),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: context.tr('confirm_password'),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement password change
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('password_changed'))),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: Text(context.tr('save')),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.tr('about_app')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'HamiKisan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('app_tagline'),
                style:
                    const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              Text(context.tr('about_description')),
              const SizedBox(height: 16),
              const Text('Version: 1.0.0'),
              const Text('© 2025 HamiKisan Team'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.tr('close')),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmation(
      BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.tr('logout')),
          content: Text(context.tr('logout_confirmation')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                authProvider.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(context.tr('logout')),
            ),
          ],
        );
      },
    );
  }
}
