import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/appearance_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/kisan_doctor_provider.dart';
import '../providers/localization_provider.dart';
import '../widgets/localized_text.dart';
import 'admin/api_settings_screen.dart';
import 'edit_profile_screen.dart';
import 'kisan_doctor/appointments_screen.dart';
import 'my_posts_screen.dart';
import 'notifications_screen.dart';
import 'system_health_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const LocalizedText('settings')),
        body: const Center(child: LocalizedText('please_login')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const LocalizedText('settings'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _AccountCard(user: user),
          _section(
            context.tr('general'),
            [
              _SettingsTile(
                icon: Icons.language,
                title: context.tr('language'),
                subtitle: context.watch<LocalizationProvider>().currentLanguage,
                onTap: () => _showLanguageDialog(context),
              ),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: context.tr('appearance'),
                subtitle: _themeModeLabel(
                  context,
                  context.watch<AppearanceProvider>().themeMode,
                ),
                onTap: () => _showAppearanceDialog(context),
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: context.tr('notifications'),
                subtitle: context.tr('manage_notifications'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
              ),
            ],
          ),
          _roleSection(context, user),
          _section(
            context.tr('account'),
            [
              _SettingsTile(
                icon: Icons.lock_outline,
                title: context.tr('change_password'),
                subtitle: 'Update your sign-in password',
                onTap: () => _showChangePasswordDialog(context),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: context.tr('privacy_policy'),
                subtitle: 'Account data and privacy information',
                onTap: () => _showPrivacyInformation(context),
              ),
            ],
          ),
          _section(
            context.tr('about'),
            [
              _SettingsTile(
                icon: Icons.info_outline,
                title: context.tr('about_app'),
                subtitle: 'HamiKisan • Version 1.0.0',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'HamiKisan',
                  applicationVersion: '1.0.0',
                  applicationLegalese: 'Together We Farm',
                  children: [
                    const SizedBox(height: 12),
                    Text(context.tr('about_description')),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutConfirmation(context, auth),
              icon: const Icon(Icons.logout),
              label: Text(context.tr('logout')),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.red.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleSection(BuildContext context, User user) {
    switch (user.role) {
      case UserRole.farmer:
        return _section(
          context.tr('farmer_settings'),
          [
            _SettingsTile(
              icon: Icons.edit_outlined,
              title: context.tr('edit_profile'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              ),
            ),
            _SettingsTile(
              icon: Icons.article_outlined,
              title: context.tr('my_posts'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyPostsScreen()),
              ),
            ),
          ],
        );
      case UserRole.kisanDoctor:
        return _section(
          context.tr('doctor_settings'),
          [
            _SettingsTile(
              icon: Icons.edit_outlined,
              title: context.tr('edit_profile'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              ),
            ),
            _SettingsTile(
              icon: Icons.event_available_outlined,
              title: context.tr('appointments'),
              subtitle: context.tr('manage_appointments'),
              onTap: () => _openAppointments(context, user),
            ),
          ],
        );
      case UserRole.kisanAdmin:
        return _section(
          context.tr('administrator_settings'),
          [
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: Text(context.tr('administrator_settings')),
              subtitle: Text(
                context.tr('admin_dashboard_hint'),
              ),
            ),
          ],
        );
      case UserRole.superAdmin:
        return _section(
          context.tr('super_admin_settings'),
          [
            _SettingsTile(
              icon: Icons.api_outlined,
              title: context.tr('api_configuration'),
              subtitle: context.tr('api_configuration_hint'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ApiSettingsScreen()),
              ),
            ),
            _SettingsTile(
              icon: Icons.monitor_heart_outlined,
              title: context.tr('system_health'),
              subtitle: context.tr('system_health_hint'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SystemHealthScreen()),
              ),
            ),
          ],
        );
    }
  }

  Future<void> _openAppointments(BuildContext context, User doctor) async {
    final provider = context.read<KisanDoctorProvider>();
    try {
      await provider.initialize(doctor.id);
      if (!context.mounted) return;
      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not load appointments: ${provider.error}')),
        );
        return;
      }
      provider.clearSelection();
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AppointmentsScreen(doctor: doctor),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load appointments: $error')),
      );
    }
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    final localization = context.read<LocalizationProvider>();
    final auth = context.read<AuthProvider>();
    final selectedLanguage = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(context.tr('choose_language')),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'English'),
            child: const Text('English'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'Nepali'),
            child: const Text('नेपाली (Nepali)'),
          ),
        ],
      ),
    );

    if (selectedLanguage == null || !context.mounted) return;
    try {
      await localization.setLanguage(selectedLanguage);
      await auth.updateLanguage(selectedLanguage);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save language preference: $error')),
      );
    }

    Future<void> showAppearanceDialog(BuildContext context) async {
      final appearance = context.read<AppearanceProvider>();
      final selectedMode = await showDialog<ThemeMode>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: Text(context.tr('appearance')),
          children: [
            themeModeOption(
              dialogContext,
              ThemeMode.system,
              context.tr('theme_system'),
              appearance.themeMode,
            ),
            themeModeOption(
              dialogContext,
              ThemeMode.light,
              context.tr('theme_light'),
              appearance.themeMode,
            ),
            themeModeOption(
              dialogContext,
              ThemeMode.dark,
              context.tr('theme_dark'),
              appearance.themeMode,
            ),
          ],
        ),
      );

      if (selectedMode == null || !context.mounted) return;
      try {
        await appearance.setThemeMode(selectedMode);
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save appearance setting: $error')),
        );
      }
    }

    Widget themeModeOption(
      BuildContext context,
      ThemeMode mode,
      String label,
      ThemeMode currentMode,
    ) {
      return SimpleDialogOption(
        onPressed: () => Navigator.pop(context, mode),
        child: Row(
          children: [
            Icon(
              currentMode == mode
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      );
    }

    String themeModeLabel(BuildContext context, ThemeMode mode) {
      return switch (mode) {
        ThemeMode.system => context.tr('theme_system'),
        ThemeMode.light => context.tr('theme_light'),
        ThemeMode.dark => context.tr('theme_dark'),
      };
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    var isSaving = false;
    var isObscured = true;
    final auth = context.read<AuthProvider>();

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: Text(context.tr('change_password')),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _passwordField(
                      controller: currentController,
                      label: context.tr('current_password'),
                      obscureText: isObscured,
                      toggleObscured: () =>
                          setDialogState(() => isObscured = !isObscured),
                    ),
                    const SizedBox(height: 12),
                    _passwordField(
                      controller: newController,
                      label: context.tr('new_password'),
                      obscureText: isObscured,
                      validator: (value) {
                        if (value == null || value.length < 8) {
                          return 'Use at least 8 characters';
                        }
                        if (value == currentController.text) {
                          return 'Choose a password different from the current one';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _passwordField(
                      controller: confirmController,
                      label: context.tr('confirm_password'),
                      obscureText: isObscured,
                      validator: (value) => value != newController.text
                          ? 'Passwords do not match'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                child: Text(context.tr('cancel')),
              ),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        setDialogState(() => isSaving = true);
                        final success = await auth.changePassword(
                          currentPassword: currentController.text,
                          newPassword: newController.text,
                        );
                        if (!dialogContext.mounted) return;
                        if (success) {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.tr('password_changed')),
                            ),
                          );
                        } else {
                          setDialogState(() => isSaving = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                auth.error ??
                                    'Password could not be changed. Contact support or use account recovery.',
                              ),
                            ),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.tr('save')),
              ),
            ],
          ),
        ),
      );
    } finally {
      currentController.dispose();
      newController.dispose();
      confirmController.dispose();
    }
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    String? Function(String?)? validator,
    VoidCallback? toggleObscured,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator ??
          (value) => value == null || value.isEmpty
              ? 'Enter your current password'
              : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: toggleObscured == null
            ? null
            : IconButton(
                onPressed: toggleObscured,
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                ),
              ),
      ),
    );
  }

  void _showPrivacyInformation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('privacy_policy')),
        content: SingleChildScrollView(
          child: Text(context.tr('account_privacy_message')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tr('close')),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutConfirmation(
    BuildContext context,
    AuthProvider auth,
  ) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('logout')),
        content: Text(context.tr('logout_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('logout')),
          ),
        ],
      ),
    );

    if (shouldLogout == true) await auth.logout();
  }
}

class _AccountCard extends StatelessWidget {
  final User user;

  const _AccountCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final secondary =
        user.phoneNumber?.isNotEmpty == true ? user.phoneNumber! : user.email;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.12),
          foregroundColor: const Color(0xFF2E7D32),
          child: Text(
            user.name.isNotEmpty
                ? user.name.characters.first.toUpperCase()
                : '?',
          ),
        ),
        title: Text(
          user.name.isEmpty ? 'HamiKisan account' : user.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle:
            Text('$secondary\n${user.role.displayName} • ${user.status.name}'),
        isThreeLine: true,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4CAF50)),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
