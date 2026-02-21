import 'dart:async';
import 'kisan_video_call_service.dart';

/// 📞 Global Call State Manager - Manages active calls and call history
class CallStateManager {
  static final CallStateManager _instance = CallStateManager._internal();
  factory CallStateManager() => _instance;
  CallStateManager._internal();

  // Active call tracking
  String? _activeCallId;
  String? _activeCaller;
  String? _activeRecipient;
  CallType? _activeCallType;
  DateTime? _callStartTime;

  // Call history
  final List<CallRecord> _callHistory = [];

  // Streams
  final _activeCallController = StreamController<String?>.broadcast();
  final _callHistoryController = StreamController<List<CallRecord>>.broadcast();

  Stream<String?> get onActiveCallChanged => _activeCallController.stream;
  Stream<List<CallRecord>> get onCallHistoryChanged =>
      _callHistoryController.stream;

  // Getters
  String? get activeCallId => _activeCallId;
  String? get activeCaller => _activeCaller;
  String? get activeRecipient => _activeRecipient;
  CallType? get activeCallType => _activeCallType;
  bool get isCallActive => _activeCallId != null;
  List<CallRecord> get callHistory => _callHistory;

  /// Initialize a new call
  Future<void> initializeCall({
    required String callId,
    required String caller,
    required String recipient,
    required CallType callType,
    required DateTime startTime,
  }) async {
    _activeCallId = callId;
    _activeCaller = caller;
    _activeRecipient = recipient;
    _activeCallType = callType;
    _callStartTime = startTime;

    _activeCallController.add(_activeCallId);
    print('📞 Call initialized: $caller -> $recipient');
  }

  /// End the active call and log it to history
  Future<void> endCall({
    required DateTime endTime,
    required String status, // 'completed', 'missed', 'declined', 'failed'
    String? notes,
  }) async {
    if (_activeCallId == null || _callStartTime == null) {
      print('❌ No active call to end');
      return;
    }

    final duration = endTime.difference(_callStartTime!);

    // Create call record
    final record = CallRecord(
      callId: _activeCallId!,
      caller: _activeCaller ?? 'Unknown',
      recipient: _activeRecipient ?? 'Unknown',
      callType: _activeCallType ?? CallType.audio,
      startTime: _callStartTime!,
      endTime: endTime,
      duration: duration,
      status: status,
      notes: notes,
    );

    _callHistory.add(record);
    _callHistoryController.add(_callHistory);

    // Reset active call
    _activeCallId = null;
    _activeCaller = null;
    _activeRecipient = null;
    _activeCallType = null;
    _callStartTime = null;

    _activeCallController.add(null);

    print('📞 Call ended: ${record.caller} -> ${record.recipient}');
    print('   Duration: ${_formatDuration(duration)}');
    print('   Status: $status');
  }

  /// Get total call time for a contact
  Duration getTotalCallTime(String contact) {
    return _callHistory
        .where((r) => r.caller == contact || r.recipient == contact)
        .fold(Duration.zero, (sum, record) => sum + record.duration);
  }

  /// Get call history for a specific contact
  List<CallRecord> getCallHistory(String contact) {
    return _callHistory
        .where((r) => r.caller == contact || r.recipient == contact)
        .toList()
        .reversed
        .toList();
  }

  /// Get missed calls
  List<CallRecord> getMissedCalls() {
    return _callHistory
        .where((r) => r.status == 'missed')
        .toList()
        .reversed
        .toList();
  }

  /// Clear call history
  void clearCallHistory() {
    _callHistory.clear();
    _callHistoryController.add(_callHistory);
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  void dispose() {
    _activeCallController.close();
    _callHistoryController.close();
  }
}

/// Call record for history tracking
class CallRecord {
  final String callId;
  final String caller;
  final String recipient;
  final CallType callType;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final String status; // 'completed', 'missed', 'declined', 'failed'
  final String? notes;

  CallRecord({
    required this.callId,
    required this.caller,
    required this.recipient,
    required this.callType,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.status,
    this.notes,
  });

  bool get isMissed => status == 'missed';
  bool get isCompleted => status == 'completed';

  @override
  String toString() {
    return 'CallRecord($caller -> $recipient, ${duration.inSeconds}s, $status)';
  }
}
