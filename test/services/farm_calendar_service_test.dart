import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hamikisan/models/farm_calendar_task.dart';
import 'package:hamikisan/services/farm_calendar_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FarmCalendarService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = FarmCalendarService();
  });

  test('saves and reloads tasks for the same farmer account', () async {
    final task = FarmCalendarTask(
      id: 'task-1',
      title: 'Water tomatoes',
      crop: 'Tomatoes',
      taskType: 'Watering',
      scheduledAt: DateTime(2026, 6, 1, 6, 30),
      weather: 'Sunny',
      notes: 'Check soil moisture first',
    );

    await service.saveTasks('farmer-1', [task]);

    final loadedTasks = await service.getTasks('farmer-1');
    expect(loadedTasks, hasLength(1));
    expect(loadedTasks.single.toJson(), task.toJson());
  });

  test('keeps each farmer calendar separate', () async {
    final task = FarmCalendarTask(
      id: 'task-1',
      title: 'Prepare field',
      crop: '',
      taskType: 'Soil preparation',
      scheduledAt: DateTime(2026, 6, 1),
    );

    await service.saveTasks('farmer-1', [task]);

    expect(await service.getTasks('farmer-2'), isEmpty);
  });
}
