import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/farm_calendar_task.dart';
import '../providers/auth_provider.dart';
import '../services/farm_calendar_service.dart';

class FarmingCalendarScreen extends StatefulWidget {
  const FarmingCalendarScreen({super.key});

  @override
  State<FarmingCalendarScreen> createState() => _FarmingCalendarScreenState();
}

class _FarmingCalendarScreenState extends State<FarmingCalendarScreen> {
  final FarmCalendarService _calendarService = FarmCalendarService();
  List<FarmCalendarTask> _tasks = [];
  bool _isLoading = true;
  bool _showCompleted = false;
  DateTime? _selectedDate;
  String? _loadError;

  String? get _accountId => context.read<AuthProvider>().currentUser?.id;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final accountId = _accountId;
    if (accountId == null) {
      setState(() {
        _isLoading = false;
        _loadError = 'Sign in to manage your farm calendar.';
      });
      return;
    }
    try {
      final tasks = await _calendarService.getTasks(accountId);
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _isLoading = false;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Could not load your farm calendar: $error';
      });
    }
  }

  Future<void> _saveTasks(List<FarmCalendarTask> tasks) async {
    final accountId = _accountId;
    if (accountId == null) {
      _showMessage('Sign in to save calendar changes.');
      return;
    }
    try {
      await _calendarService.saveTasks(accountId, tasks);
      if (!mounted) return;
      setState(() {
        _tasks = [...tasks]
          ..sort((first, second) =>
              first.scheduledAt.compareTo(second.scheduledAt));
      });
    } catch (error) {
      _showMessage('Calendar changes could not be saved: $error');
    }
  }

  Future<void> _addOrEditTask([FarmCalendarTask? existing]) async {
    final task = await showDialog<FarmCalendarTask>(
      context: context,
      builder: (context) => _FarmTaskEditor(task: existing),
    );
    if (task == null || !mounted) return;
    final updated = [..._tasks];
    final index = updated.indexWhere((item) => item.id == task.id);
    if (index == -1) {
      updated.add(task);
    } else {
      updated[index] = task;
    }
    await _saveTasks(updated);
  }

  Future<void> _toggleCompleted(FarmCalendarTask task) async {
    await _saveTasks(_tasks
        .map((item) => item.id == task.id
            ? item.copyWith(isCompleted: !item.isCompleted)
            : item)
        .toList());
  }

  Future<void> _deleteTask(FarmCalendarTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete farm task?'),
        content: Text('“${task.title}” will be removed from your calendar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _saveTasks(_tasks.where((item) => item.id != task.id).toList());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<FarmCalendarTask> get _visibleTasks {
    return _tasks.where((task) {
      if (_showCompleted != task.isCompleted) return false;
      if (_selectedDate == null) return true;
      return _sameDay(task.scheduledAt, _selectedDate!);
    }).toList();
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null || !user.isFarmer) {
      return Scaffold(
        appBar: AppBar(title: const Text('Farm Calendar')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'The personal farming calendar is available to farmer accounts.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Calendar'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: _selectedDate == null ? 'Filter by date' : 'Clear date filter',
            onPressed: _selectedDate == null
                ? _pickDate
                : () => setState(() => _selectedDate = null),
            icon: Icon(
              _selectedDate == null ? Icons.calendar_month : Icons.event_busy,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? _LoadError(message: _loadError!, onRetry: _loadTasks)
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment(
                                  value: false,
                                  label: Text('Planned'),
                                  icon: Icon(Icons.schedule),
                                ),
                                ButtonSegment(
                                  value: true,
                                  label: Text('Completed'),
                                  icon: Icon(Icons.check_circle_outline),
                                ),
                              ],
                              selected: {_showCompleted},
                              onSelectionChanged: (selection) => setState(
                                () => _showCompleted = selection.first,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedDate != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tasks on ${_formatDate(_selectedDate!)}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ),
                    Expanded(
                      child: _visibleTasks.isEmpty
                          ? _EmptyCalendar(
                              completed: _showCompleted,
                              date: _selectedDate,
                              onAdd: () => _addOrEditTask(),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                              itemCount: _visibleTasks.length,
                              itemBuilder: (context, index) {
                                final task = _visibleTasks[index];
                                return _TaskCard(
                                  task: task,
                                  onEdit: () => _addOrEditTask(task),
                                  onDelete: () => _deleteTask(task),
                                  onToggle: () => _toggleCompleted(task),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: user.isFarmer && !_isLoading && _loadError == null
          ? FloatingActionButton.extended(
              onPressed: () => _addOrEditTask(),
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add farm task'),
            )
          : null,
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}

class _FarmTaskEditor extends StatefulWidget {
  final FarmCalendarTask? task;

  const _FarmTaskEditor({this.task});

  @override
  State<_FarmTaskEditor> createState() => _FarmTaskEditorState();
}

class _FarmTaskEditorState extends State<_FarmTaskEditor> {
  static const _taskTypes = [
    'Planting',
    'Watering',
    'Fertilizing',
    'Pest control',
    'Pruning',
    'Harvesting',
    'Soil preparation',
    'Other',
  ];
  static const _weatherOptions = [
    'Sunny',
    'Cloudy',
    'Rain',
    'Windy',
    'Frost',
    'Hot',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _cropController;
  late final TextEditingController _notesController;
  late String _taskType;
  late DateTime _scheduledAt;
  String? _weather;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _cropController = TextEditingController(text: task?.crop ?? '');
    _notesController = TextEditingController(text: task?.notes ?? '');
    _taskType = task?.taskType ?? _taskTypes.first;
    _scheduledAt = task?.scheduledAt ?? DateTime.now();
    _weather = task?.weather;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cropController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) {
      setState(() {
        _scheduledAt = DateTime(
          date.year,
          date.month,
          date.day,
          _scheduledAt.hour,
          _scheduledAt.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time != null && mounted) {
      setState(() {
        _scheduledAt = DateTime(
          _scheduledAt.year,
          _scheduledAt.month,
          _scheduledAt.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final previousTask = widget.task;
    Navigator.pop(
      context,
      FarmCalendarTask(
        id: previousTask?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        crop: _cropController.text.trim(),
        taskType: _taskType,
        scheduledAt: _scheduledAt,
        weather: _weather,
        notes: _notesController.text.trim(),
        isCompleted: previousTask?.isCompleted ?? false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Plan farm work' : 'Edit farm work'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Task',
                    hintText: 'e.g. Water the tomato field',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a task'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cropController,
                  decoration: const InputDecoration(
                    labelText: 'Crop or field (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _taskType,
                  decoration: const InputDecoration(labelText: 'Work type'),
                  items: _taskTypes
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _taskType = value);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          '${_scheduledAt.day}/${_scheduledAt.month}/${_scheduledAt.year}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectTime,
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          TimeOfDay.fromDateTime(_scheduledAt)
                              .format(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: _weather,
                  decoration: const InputDecoration(
                    labelText: 'Weather note (optional)',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('No weather note'),
                    ),
                    ..._weatherOptions.map(
                      (weather) => DropdownMenuItem<String?>(
                        value: weather,
                        child: Text(weather),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _weather = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.task == null ? 'Add task' : 'Save changes'),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final FarmCalendarTask task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _TaskCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = !task.isCompleted &&
        task.scheduledAt.isBefore(now) &&
        !(task.scheduledAt.year == now.year &&
            task.scheduledAt.month == now.month &&
            task.scheduledAt.day == now.day);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (_) => onToggle(),
              activeColor: const Color(0xFF4CAF50),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${task.taskType}${task.crop.isEmpty ? '' : ' · ${task.crop}'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${task.scheduledAt.day}/${task.scheduledAt.month}/${task.scheduledAt.year} · '
                    '${TimeOfDay.fromDateTime(task.scheduledAt).format(context)}'
                    '${isOverdue ? ' · Overdue' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : Colors.grey[700],
                      fontWeight: isOverdue ? FontWeight.w600 : null,
                    ),
                  ),
                  if (task.weather != null && task.weather!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Weather note: ${task.weather}'),
                    ),
                  if (task.notes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(task.notes),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Task options',
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit or reschedule')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCalendar extends StatelessWidget {
  final bool completed;
  final DateTime? date;
  final VoidCallback onAdd;

  const _EmptyCalendar({
    required this.completed,
    required this.date,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final message = completed
        ? 'Completed farm work will appear here.'
        : date == null
            ? 'Plan your planting, watering, and other farm work.'
            : 'No farm work planned for this date.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              completed ? Icons.task_alt : Icons.event_note,
              size: 52,
              color: Colors.green[400],
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (!completed) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add farm task'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
}
