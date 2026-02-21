import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Debug utility to check stored credentials
Future<void> debugStoredCredentials() async {
  final prefs = await SharedPreferences.getInstance();
  const String usersKey = 'local_users_db_v4';

  final usersStr = prefs.getString(usersKey);

  if (usersStr == null) {
    print('========================================');
    print('NO USERS FOUND IN DATABASE');
    print('Database needs to be initialized');
    print('========================================');
    return;
  }

  final users = json.decode(usersStr) as Map<String, dynamic>;

  print('========================================');
  print('STORED USER CREDENTIALS DEBUG');
  print('Total users: ${users.length}');
  print('========================================\n');

  for (final userId in users.keys) {
    final user = users[userId] as Map<String, dynamic>;
    final role = user['role'];

    if (role == 'superAdmin' || role == 'kisanAdmin') {
      print('USER ID: $userId');
      print('Username: ${user['username']}');
      print('Email: ${user['email']}');
      print('Role: ${user['role']}');
      print('Name: ${user['name']}');
      print('Status: ${user['status']}');
      print(
          'Password Hash: ${user['password_hash']?.toString().substring(0, 30)}...');
      print('---');
    }
  }

  print('\n========================================');
  print('DEBUG: Testing password verification');
  print('========================================\n');

  // Test Super Admin
  final superAdminUser = users.values.firstWhere(
    (u) => u['role'] == 'superAdmin',
    orElse: () => null,
  );

  if (superAdminUser != null) {
    print('Super Admin Test:');
    print('Username: ${superAdminUser['username']}');
    print('Expected Password: @PhulasiPokhari.');
    print('Stored Hash: ${superAdminUser['password_hash']}');
    print('---\n');
  }

  // Test Kisan Admin
  final kisanAdminUser = users.values.firstWhere(
    (u) => u['role'] == 'kisanAdmin',
    orElse: () => null,
  );

  if (kisanAdminUser != null) {
    print('Kisan Admin Test:');
    print('Username: ${kisanAdminUser['username']}');
    print('Expected Password: @NepaliKisan923.');
    print('Stored Hash: ${kisanAdminUser['password_hash']}');
    print('---\n');
  }
}

/// Clear all stored users (will be re-initialized on next login attempt)
Future<void> clearStoredUsers() async {
  final prefs = await SharedPreferences.getInstance();
  const String usersKey = 'local_users_db_v4';
  await prefs.remove(usersKey);
  print('========================================');
  print('ALL USERS CLEARED FROM DATABASE');
  print('Users will be re-initialized on next app start');
  print('========================================');
}
