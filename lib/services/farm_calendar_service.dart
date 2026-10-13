import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/farm_calendar_task.dart';

class FarmCalendarService {
  String _storageKey(String accountId) => 'farm_calendar_tasks_$accountId';

  Future<List<FarmCalendarTask>> getTasks(String accountId) async {
    final preferences = await SharedPreferences.getInstance();
    final storedTasks = preferences.getString(_storageKey(accountId));
    if (storedTasks == null || storedTasks.isEmpty) return [];

    final decoded = jsonDecode(storedTasks);
    if (decoded is! List) {
      throw const FormatException('Stored farm calendar data is invalid');
    }
    return decoded
        .map((task) => FarmCalendarTask.fromJson(
              Map<String, dynamic>.from(task as Map),
            ))
        .toList()
      ..sort((first, second) => first.scheduledAt.compareTo(second.scheduledAt));
  }

  Future<void> saveTasks(
    String accountId,
    List<FarmCalendarTask> tasks,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey(accountId),
      jsonEncode(tasks.map((task) => task.toJson()).toList()),
    );
    if (!saved) {
      throw StateError('The farm calendar could not be saved on this device');
    }
  }
}
