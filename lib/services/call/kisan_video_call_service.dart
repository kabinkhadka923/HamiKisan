import 'dart:async';
import '../audio_service.dart';

class KisanVideoCallService {
  final AudioService _audioService = AudioService();

  // Call state machine
  CallState _callState = CallState.idle;
  Timer? _ringTimeoutTimer;
  Timer? _callDurationTimer;
  Duration _callDuration = Duration.zero;

  // Call tracking
  String? _currentCallId;
  bool _isMuted = false;
  bool _isVideoEnabled = true;

  // Streams for UI communication
  final _callConnectedController = StreamController<void>.broadcast();
  final _callEndedController = StreamController<void>.broadcast();
  final _callStateController = StreamController<CallState>.broadcast();
  final _callDurationController = StreamController<Duration>.broadcast();

  Stream<void> get onCallConnected => _callConnectedController.stream;
  Stream<void> get onCallEnded => _callEndedController.stream;
  Stream<CallState> get onStateChanged => _callStateController.stream;
  Stream<Duration> get onDurationChanged => _callDurationController.stream;

  // Handle incoming call with enhanced audio
  Future<void> handleIncomingCall({
    required String callerId,
    required String callerType, // 'doctor' or 'farmer'
    Map<String, dynamic>? context, // Additional context
  }) async {
    if (_callState != CallState.idle) {
      // Already in a call, send busy signal
      await _sendBusySignal(callerId);
      return;
    }

    _currentCallId = callerId;
    _callState = CallState.ringingIncoming;
    _callStateController.add(_callState);

    // Play appropriate ringtone based on caller
    final ringtone = _getRingtoneForCaller(callerType, context);

    try {
      await _audioService.playIncomingCall(
        customRingtone: ringtone,
        vibrate: true,
        callerType: callerType,
      );
    } catch (e) {
      print('Error playing incoming call sound: $e');
    }

    // Set ring timeout (30 seconds)
    _ringTimeoutTimer = Timer(const Duration(seconds: 30), () async {
      if (_callState == CallState.ringingIncoming) {
        await declineCall();
        try {
          await _audioService.playError();
        } catch (e) {
          print('Error playing error sound: $e');
        }
      }
    });
  }

  // Handle outgoing call
  Future<void> handleOutgoingCall({
    required String recipientId,
    CallType callType = CallType.video,
  }) async {
    _currentCallId = recipientId;
    _callState = CallState.ringingOutgoing;
    _callStateController.add(_callState);

    try {
      await _audioService.playOutgoingCall();

      // Start connection process
      final connectionResult = await _establishConnection(
        recipientId,
        callType,
      );

      if (connectionResult) {
        _callState = CallState.connected;
        _callStateController.add(_callState);
        await _audioService.stopCallSound();
        try {
          await _audioService.playCallConnected();
        } catch (e) {
          print('Error playing connected sound: $e');
        }
        _startCallDurationTimer();
        _callConnectedController.add(null);
      } else {
        _callState = CallState.idle;
        _callStateController.add(_callState);
        await _audioService.stopCallSound();
        try {
          await _audioService.playError();
        } catch (e) {
          print('Error playing error sound: $e');
        }
        _callEndedController.add(null);
      }
    } catch (e) {
      print('Error during outgoing call: $e');
      _callState = CallState.error;
      _callStateController.add(_callState);
      _callEndedController.add(null);
    }
  }

  Future<void> acceptCall() async {
    if (_callState == CallState.ringingIncoming) {
      _ringTimeoutTimer?.cancel();
      _callState = CallState.connected;
      _callStateController.add(_callState);
      await _audioService.stopCallSound();
      try {
        await _audioService.playCallConnected();
      } catch (e) {
        print('Error playing connected sound: $e');
      }
      _startCallDurationTimer();
      _callConnectedController.add(null);
    }
  }

  // Call controls with audio feedback
  Future<void> muteCall(bool muted) async {
    _isMuted = muted;
    try {
      if (muted) {
        await _audioService.toggleMute();
      } else {
        await _audioService.playNotification();
      }
    } catch (e) {
      print('Error toggling mute: $e');
    }
  }

  Future<void> switchCamera() async {
    _isVideoEnabled = !_isVideoEnabled;
    try {
      await _audioService.playNotification();
    } catch (e) {
      print('Error playing notification: $e');
    }
  }

  Future<void> endCall() async {
    _callState = CallState.ending;
    _callStateController.add(_callState);
    _callDurationTimer?.cancel();

    try {
      await _audioService.playCallEnded();
    } catch (e) {
      print('Error playing call ended sound: $e');
    }

    // Add fade out effect
    await Future.delayed(const Duration(milliseconds: 300));

    _callState = CallState.idle;
    _callStateController.add(_callState);
    _ringTimeoutTimer?.cancel();
    _callDurationTimer?.cancel();
    _callDuration = Duration.zero;
    _currentCallId = null;
    _isMuted = false;
    _isVideoEnabled = true;
    _callEndedController.add(null);
  }

  Future<void> declineCall() async {
    _callState = CallState.idle;
    _callStateController.add(_callState);
    _ringTimeoutTimer?.cancel();
    await _audioService.stopCallSound();
    try {
      await _audioService.playNotification();
    } catch (e) {
      print('Error playing notification: $e');
    }
    _callEndedController.add(null);
  }

  // Helper methods
  String _getRingtoneForCaller(
      String callerType, Map<String, dynamic>? context) {
    // Keep ringtone names aligned with existing assets used by AudioService.
    final normalizedType = callerType.toLowerCase();
    final isUrgent = context != null && context['urgency'] == 'high';

    if (isUrgent) return 'incomming_call_ringtone.mp3';
    if (normalizedType.contains('doctor')) return 'incomming_call_ringtone.mp3';
    if (normalizedType.contains('farmer')) return 'incomming_call_ringtone.mp3';
    return 'incomming_call_ringtone.mp3';
  }

  Future<void> _sendBusySignal(String callerId) async {
    // Placeholder for sending busy signal via socket/api
    print('Sending busy signal to $callerId');
  }

  Future<bool> _establishConnection(
      String recipientId, CallType callType) async {
    // Simulate connection with actual network simulation
    print('Establishing connection to $recipientId (${callType.name})...');
    await Future.delayed(const Duration(seconds: 2));
    // In real implementation, this would establish WebRTC connection
    return true; // Simulate successful connection
  }

  void _startCallDurationTimer() {
    _callDuration = Duration.zero;
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _callDuration = _callDuration + const Duration(seconds: 1);
      _callDurationController.add(_callDuration);
    });
  }

  String getCallDurationString() {
    final hours = _callDuration.inHours;
    final minutes = _callDuration.inMinutes.remainder(60);
    final seconds = _callDuration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  CallState get currentState => _callState;
  String? get currentCallId => _currentCallId;

  void dispose() {
    _ringTimeoutTimer?.cancel();
    _callDurationTimer?.cancel();
    _callConnectedController.close();
    _callEndedController.close();
    _callStateController.close();
    _callDurationController.close();
  }
}

enum CallState {
  idle,
  ringingIncoming,
  ringingOutgoing,
  connected,
  ending,
  error,
}

enum CallType {
  audio,
  video,
}
