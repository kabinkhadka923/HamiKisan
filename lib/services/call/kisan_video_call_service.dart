import 'dart:async';
import 'package:flutter/widgets.dart';
import '../audio_service.dart';

enum CallState { idle, ringingIncoming, ringingOutgoing, connected, ending, error }
enum CallType { video, voice, audio }

class KisanVideoCallService {
  final AudioService _audioService = AudioService();

  // Call state machine
  CallState _callState = CallState.idle;
  Timer? _ringTimeoutTimer;
  Timer? _callDurationTimer;
  Duration _callDuration = Duration.zero;

  // Call tracking
  String? _currentCallId;
  String? _myUserId;
  String? _peerUserId;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isCallEstablished = false;

  // Streams for UI communication
  final _callConnectedController = StreamController<void>.broadcast();
  final _callEndedController = StreamController<void>.broadcast();
  final _callStateController = StreamController<CallState>.broadcast();
  final _callDurationController = StreamController<Duration>.broadcast();

  // Socket.IO client reference (set from outside)
  dynamic _socket;

  // Getter for call state
  CallState get callState => _callState;
  String? get currentCallId => _currentCallId;
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isCallEstablished => _isCallEstablished;

  // Socket getter for WebRTC signaling
  dynamic get socket => _socket;

  // Streams
  Stream<void> get onCallConnected => _callConnectedController.stream;
  Stream<void> get onCallEnded => _callEndedController.stream;
  Stream<CallState> get onStateChanged => _callStateController.stream;
  Stream<Duration> get onDurationChanged => _callDurationController.stream;

  KisanVideoCallService();

  /// Set the socket.io connection (call from initState)
  void setSocket(dynamic socket) {
    _socket = socket;
  }

  /// Initialize call service with socket connection
  Future<void> init({required dynamic socket}) async {
    setSocket(socket);
    // Listen for incoming calls via socket.io
    _listenForIncomingCalls();
  }

  /// Listen for incoming calls via socket.io
  void _listenForIncomingCalls() {
    _socket?.on('call_incoming', (data) {
      if (_callState != CallState.idle) return; // Already in a call
      final callerName = data['fromName'] ?? 'Doctor';
      final callType = data['callType'] ?? 'video';
      final callId = data['callId'] ?? '';
      _peerUserId = data['from']?.toString();

      _currentCallId = callId;
      _callState = CallState.ringingIncoming;
      _callStateController.add(_callState);

      // Play ringtone
      _audioService.playIncomingCall(
        customRingtone: 'incomming_call_ringtone.mp3',
        vibrate: true,
        callerType: 'doctor',
      );

      // Set ring timeout
      _ringTimeoutTimer?.cancel();
      _ringTimeoutTimer = Timer(const Duration(seconds: 30), () async {
        if (_callState == CallState.ringingIncoming) {
          declineCall();
          _audioService.playError();
        }
      });
    });

    _socket?.on('call_accepted', (data) {
      final callId = data['callId'] ?? '';
      if (_currentCallId == callId) {
        _callState = CallState.connected;
        _callStateController.add(_callState);
        _ringTimeoutTimer?.cancel();
        _audioService.stopCallSound();
        _audioService.playCallConnected();
        _startCallDurationTimer();
        _callConnectedController.add(null);
        _isCallEstablished = true;
      }
    });

    _socket?.on('call_declined', (data) {
      final callId = data['callId'] ?? '';
      if (_currentCallId == callId) {
        _callState = CallState.idle;
        _callStateController.add(_callState);
        _ringTimeoutTimer?.cancel();
        _audioService.stopCallSound();
        _audioService.playNotification();
        _callEndedController.add(null);
        _isCallEstablished = false;
      }
    });

    _socket?.on('call_ended', (data) {
      final callId = data['callId'] ?? '';
      if (_currentCallId == callId || _callState != CallState.idle) {
        _callState = CallState.idle;
        _callStateController.add(_callState);
        _ringTimeoutTimer?.cancel();
        _callDurationTimer?.cancel();
        _callDuration = Duration.zero;
        _currentCallId = null;
        _isMuted = false;
        _isVideoEnabled = true;
        _isCallEstablished = false;
        _callEndedController.add(null);
      }
    });

    _socket?.on('call_sdp', (data) {
      // Handle SDP exchange for WebRTC
      final callId = data['callId'] ?? '';
      final sdp = data['sdp'] ?? '';
      final sdpType = data['sdpType'] ?? '';
      if (_currentCallId == callId) {
        // Apply remote SDP - in real implementation, this would be
        // applied to the WebRTC peer connection
        print('Received SDP for call $callId: $sdpType');
      }
    });

    _socket?.on('call_ice', (data) {
      // Handle ICE candidate exchange
      final callId = data['callId'] ?? '';
      final candidate = data['candidate'] ?? '';
      if (_currentCallId == callId) {
        print('Received ICE candidate for call $callId');
      }
    });
  }

  Future<void> makeCall({
    required String recipientId,
    required String recipientName,
    required String myUserId,
    CallType callType = CallType.video,
    String? callId,
  }) async {
    if (_callState != CallState.idle) return;

    _myUserId = myUserId;
    _peerUserId = recipientId;
    _currentCallId = callId ?? recipientId;
    _callState = CallState.ringingOutgoing;
    _callStateController.add(_callState);

    // Play outgoing call sound
    await _audioService.playOutgoingCall();

    // Emit socket.io call_invite to signaling server
    _socket?.emit('call_invite', {
      'toUserId': recipientId,
      'callType': callType.name,
      'callerName': 'Farmer', // Would come from auth
      'callId': _currentCallId,
    });

    // Set ring timeout
    _ringTimeoutTimer = Timer(const Duration(seconds: 30), () async {
      if (_callState == CallState.ringingOutgoing) {
        await declineCall();
        _audioService.playError();
      }
    });
  }

  /// Accept incoming call
  Future<void> answerCall() async {
    if (_callState == CallState.ringingIncoming && _currentCallId != null) {
      _ringTimeoutTimer?.cancel();
      _callState = CallState.connected;
      _callStateController.add(_callState);
      _audioService.stopCallSound();
      _audioService.playCallConnected();
      _startCallDurationTimer();
      _callConnectedController.add(null);
      _isCallEstablished = true;

      // Emit socket.io call_accepted
      _socket?.emit('call_accept', {
        'callId': _currentCallId,
        'toUserId': _peerUserId,
      });
    }
  }

  /// Decline incoming call
  Future<void> declineCall() async {
    if (_callState == CallState.ringingIncoming || _callState == CallState.ringingOutgoing) {
      _ringTimeoutTimer?.cancel();
      _callState = CallState.idle;
      _callStateController.add(_callState);
      _audioService.stopCallSound();
      _audioService.playNotification();

      // Emit socket.io call_decline
      _socket?.emit('call_decline', {
        'callId': _currentCallId,
        'toUserId': _peerUserId,
      });
    }
  }

  /// End active call
  Future<void> endCall() async {
    _callState = CallState.ending;
    _callStateController.add(_callState);

    // Emit socket.io call_end
    _socket?.emit('call_end', {
      'callId': _currentCallId,
      'toUserId': _peerUserId,
    });

    try {
      await _audioService.playCallEnded();
    } catch (e) {
      print('Error playing call ended sound: $e');
    }

    // Cleanup
    _callDurationTimer?.cancel();
    _ringTimeoutTimer?.cancel();
    _callDuration = Duration.zero;
    _currentCallId = null;
    _isMuted = false;
    _isVideoEnabled = true;
    _isCallEstablished = false;
    _callEndedController.add(null);
  }

  /// Toggle mute
  Future<void> muteCall(bool muted) async {
    _isMuted = muted;
    try {
      await _audioService.toggleMute();
    } catch (e) {
      print('Error toggling mute: $e');
    }
  }

  /// Switch camera
  Future<void> switchCamera() async {
    _isVideoEnabled = !_isVideoEnabled;
    try {
      await _audioService.playNotification();
    } catch (e) {
      print('Error playing notification: $e');
    }
  }

  /// Start call duration timer
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

  /// Update call state (for WebRTC connection state changes)
  void updateCallState(CallState newState) {
    if (_callState != newState) {
      _callState = newState;
      _callStateController.add(_callState);
    }
  }

  /// Dispose and clean up
  void dispose() {
    _ringTimeoutTimer?.cancel();
    _callDurationTimer?.cancel();
    _callStateController.close();
    _callEndedController.close();
    _callConnectedController.close();
    _callDurationController.close();
    _socket = null;
  }
}
