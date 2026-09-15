import 'dart:async';
import 'dart:html' as html if (dart.library.html) 'dart-html';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/kisan_video_call_service.dart';
import '../services/audio_service.dart';
import 'video_call_screen.dart';

enum CallRole { caller, callee }

class VideoCallScreen extends StatefulWidget {
  final String callId;
  final String peerName;
  final String callerName;
  final String? callerSpecialty;
  final CallRole role;
  final String callerId;
  final String calleeId;
  final bool isOutgoing;
  final CallType callType;
  final Map<String, dynamic>? callContext;

  const VideoCallScreen({
    required this.callId,
    required this.peerName,
    required this.callerName,
    this.callerSpecialty,
    required this.role,
    required this.callerId,
    required this.calleeId,
    required this.isOutgoing,
    required this.callType,
    this.callContext,
    super.key,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with TickerProviderStateMixin {
  late KisanVideoCallService _callService;
  late AudioService _audioService;

  late StreamSubscription<CallState>? _stateSubscription;
  late StreamSubscription<void>? _callConnectedSubscription;
  late StreamSubscription<void>? _callEndedSubscription;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _callConnectedSubscription?.cancel();
    _callEndedSubscription?.cancel();
    _callService.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    _callService = KisanVideoCallService();
    _audioService = AudioService();

    // Set socket.io connection from auth provider
    final authProvider = context.read<AuthProvider>();
    _callService.setSocket(authProvider.socket);

    // Initialize with socket connection
    await _callService.init(socket: authProvider.socket);

    // Subscribe to call state changes
    _stateSubscription = _callService.onStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        // Update UI based on state
      });
      _handleCallStateChange(state);
    });

    _callConnectedSubscription = _callService.onCallConnected.listen((_) {
      if (!mounted) return;
      setState(() {
        // Call connected
      });
    });

    _callEndedSubscription = _callService.onCallEnded.listen((_) {
      if (!mounted) return;
      setState(() {
        // Call ended
      });
      _navigateBack();
    });
  }

  void _handleCallStateChange(CallState state) {
    setState(() {
      // Update UI based on state
    });
    switch (state) {
      case CallState.connected:
        _audioService.playCallConnected();
        break;
      case CallState.ending:
        _audioService.playCallEnded();
        break;
      case CallState.ringingIncoming:
      case CallState.ringingOutgoing:
        _audioService.playIncomingCall(
          customRingtone: 'incomming_call_ringtone.mp3',
          vibrate: true,
          callerType: 'doctor',
        );
        break;
    }
  }

  /// Show incoming call dialog
  void _showIncomingCallDialog(dynamic callData) {
    final callerName = callData['fromName'] ?? widget.callerName ?? 'Doctor';
    final callType = callData['callType'] ?? 'video';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Incoming Call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.call, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              '$callerName is calling',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Call Type: $callType',
              style: const TextStyle(fontSize: 14, color: Colors.green),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _declineCall();
            },
            child: const Text('Decline'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _answerCall();
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  Future<void> _answerCall() async {
    if (_callService.currentCallId != null) {
      await _callService.answerCall();
      // Socket.io answer already emitted in answerCall()
    }
  }

  Future<void> _endCall() async {
    await _callService.endCall();
    _navigateBack();
  }

  void _navigateBack() {
    // Add delay to let the end animation play
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Widget _buildVideoArea() {
    // Placeholder for local/remote video streams
    return Container(
      color: Colors.black,
      child: Center(
        child: _buildCallStateWidget(),
      ),
    );
  }

  Widget _buildCallStateWidget() {
    switch (_callService.callState) {
      case CallState.idle:
        return const Text(
          'Ready for call',
          style: TextStyle(color: Colors.white, fontSize: 18),
        );
      case CallState.ringingIncoming:
      case CallState.ringingOutgoing:
        return const Text(
          'Ringling...',
          style: TextStyle(color: Colors.orange, fontSize: 18),
        );
      case CallState.connected:
        return const Text(
          'Connected',
          style: TextStyle(color: Colors.green, fontSize: 18),
        );
      case CallState.ending:
        return const Text(
          'Ending call...',
          style: TextStyle(color: Colors.orange, fontSize: 18),
        );
      case CallState.error:
        return const Text(
          'Call error',
          style: TextStyle(color: Colors.red, fontSize: 18),
        );
    }
  }

  Widget _buildCallControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mute button
            _buildMuteButton(),
            const SizedBox(height: 16),
            // End call button
            _buildEndCallButton(),
            const SizedBox(height: 16),
            // Video toggle (only for caller)
            if (widget.isOutgoing && widget.role == CallRole.caller) ...[
              _buildVideoToggle(),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMuteButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        await _callService.muteCall(!_callService.isMuted);
        setState(() {});
      },
      icon: Icon(
        _callService.isMuted ? Icons.unmute : Icons.mute,
        color: Colors.white,
      ),
      label: Text(
        _callService.isMuted ? 'Unmute' : 'Mute',
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
    );
  }

  Widget _buildEndCallButton() {
    return ElevatedButton(
      onPressed: _endCall,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text(
        'End Call',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildVideoToggle() {
    return ElevatedButton.icon(
      onPressed: () async {
        await _callService.switchCamera();
        setState(() {});
      },
      icon: const Icon(Icons.videocam, color: Colors.white),
      label: const Text(
        'Switch Camera',
        style: Style(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
    );
  }
}
