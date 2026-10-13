class FarmCalendarTask {
  final String id;
  final String title;
  final String crop;
  final String taskType;
  final DateTime scheduledAt;
  final String? weather;
  final String notes;
  final bool isCompleted;

  const FarmCalendarTask({
    required this.id,
    required this.title,
    required this.crop,
    required this.taskType,
    required this.scheduledAt,
    this.weather,
    this.notes = '',
    this.isCompleted = false,
  });

  factory FarmCalendarTask.fromJson(Map<String, dynamic> json) {
    final scheduledAt =
        DateTime.tryParse(json['scheduledAt']?.toString() ?? '');
    if (scheduledAt == null) {
      throw const FormatException('Calendar task has an invalid schedule time');
    }
    return FarmCalendarTask(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      crop: json['crop']?.toString() ?? '',
      taskType: json['taskType']?.toString() ?? 'Other',
      scheduledAt: scheduledAt,
      weather: json['weather']?.toString(),
      notes: json['notes']?.toString() ?? '',
      isCompleted: json['isCompleted'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'crop': crop,
        'taskType': taskType,
        'scheduledAt': scheduledAt.toIso8601String(),
        'weather': weather,
        'notes': notes,
        'isCompleted': isCompleted,
      };

  FarmCalendarTask copyWith({
    String? title,
    String? crop,
    String? taskType,
    DateTime? scheduledAt,
    String? weather,
    bool clearWeather = false,
    String? notes,
    bool? isCompleted,
  }) {
    return FarmCalendarTask(
      id: id,
      title: title ?? this.title,
      crop: crop ?? this.crop,
      taskType: taskType ?? this.taskType,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      weather: clearWeather ? null : weather ?? this.weather,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
