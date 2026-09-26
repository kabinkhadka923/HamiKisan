import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../services/call/kisan_video_call_service.dart';
import '../services/call/call_signaling_service.dart';
import '../services/audio_service.dart';

enum CallRole { caller, callee }

class VideoCallScreen extends StatefulWidget {
  final String callId;
  final String peerName;
  final String callerName;
  final String? callerSpecialty;
  final CallRole role;
  final String callerId;
  final String calleeId;
  final String? calleePhoneNumber;
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
    this.calleePhoneNumber,
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
  late String _activeCallId;
  late KisanVideoCallService _callService;
  late AudioService _audioService;

  StreamSubscription<CallState>? _stateSub;
  StreamSubscription<void>? _connectedSub;
  StreamSubscription<void>? _endedSub;

  // WebRTC
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isFrontCamera = true;

  @override
  void initState() {
    super.initState();
    _activeCallId = widget.callId;
    _initializeServices();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _connectedSub?.cancel();
    _endedSub?.cancel();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _peerConnection?.close();
    _callService.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    await _initializeRenderers();
    _callService = KisanVideoCallService();
    _audioService = AudioService();

    final authProvider = context.read<AuthProvider>();
    _callService.setSocket(authProvider.socket);

    await _callService.init(socket: authProvider.socket);

    _stateSub = _callService.onStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {});
      _handleCallStateChange(state);
    });

    _connectedSub = _callService.onCallConnected.listen((_) {
      if (!mounted) return;
      setState(() {});
    });

    _endedSub = _callService.onCallEnded.listen((_) {
      if (!mounted) return;
      setState(() {});
      _navigateBack();
    });

    _setupSignaling();
    if (widget.isOutgoing) {
      final invited = await _prepareOutgoingCall(authProvider);
      if (invited && mounted) {
        await _makeCall();
      }
    }
  }

  Future<bool> _prepareOutgoingCall(AuthProvider authProvider) async {
    final callId = await CallSignalingService().inviteCall(
      receiverId: widget.calleeId,
      callerName: authProvider.currentUser?.name ?? 'HamiKisan user',
      callType: widget.callType == CallType.voice ? 'voice' : 'video',
    );
    if (!mounted || callId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to start the call. Please try again.')),
        );
      }
      return false;
    }
    _activeCallId = callId;
    authProvider.socket?.emit('call_invite', {
      'toUserId': widget.calleeId,
      'callId': callId,
      'callType': widget.callType.name,
      'callerName': authProvider.currentUser?.name,
    });
    return true;
  }

  void _setupSignaling() {
    final socket = _callService.socket;
    if (socket == null) return;

    socket.on('call:offer', (data) async {
      if (!mounted) return;
      await _handleIncomingOffer(data);
    });

    socket.on('call:answer', (data) async {
      if (!mounted) return;
      await _handleAnswer(data);
    });

    socket.on('call:ice', (data) async {
      if (!mounted) return;
      await _handleIceCandidate(data);
    });

    socket.on('call:decline', (data) {
      if (!mounted) return;
      _handleCallDeclined();
    });

    socket.on('call:end', (data) {
      if (!mounted) return;
      _handleCallEnded();
    });
  }

  void _handleCallStateChange(CallState state) {
    setState(() {});
    switch (state) {
      case CallState.idle:
        break;
      case CallState.connected:
        _audioService.playCallConnected();
        break;
      case CallState.ending:
        _audioService.playCallEnded();
        break;
      case CallState.error:
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

  Future<void> _startLocalStream() async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': widget.callType == CallType.video
            ? {
                'facingMode': _isFrontCamera ? 'user' : 'environment',
                'width': {'ideal': 1280},
                'height': {'ideal': 720},
              }
            : false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;

      if (mounted) setState(() {});
    } catch (e) {
      print('Error starting local stream: $e');
    }
  }

  Future<void> _createPeerConnection() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(configuration);

    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
    }

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
        if (mounted) setState(() {});
      }
    };

    _peerConnection!.onIceCandidate = (candidate) {
      _sendIceCandidate(candidate);
    };
  }

  Future<void> _makeCall() async {
    await _startLocalStream();
    await _createPeerConnection();

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _callService.socket?.emit('call:offer', {
      'callId': _activeCallId,
      'offer': offer.toMap(),
      'callerId': widget.callerId,
      'calleeId': widget.calleeId,
      'callType': widget.callType.name,
    });
  }

  Future<void> _handleIncomingOffer(Map<String, dynamic> data) async {
    await _startLocalStream();
    await _createPeerConnection();

    final offer = RTCSessionDescription(
      data['offer']['sdp'],
      data['offer']['type'],
    );

    await _peerConnection!.setRemoteDescription(offer);

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    _callService.socket?.emit('call:answer', {
      'callId': _activeCallId,
      'answer': (await _peerConnection!.getLocalDescription())?.toMap(),
      'callerId': data['callerId'],
      'calleeId': widget.calleeId,
    });

    _showIncomingCallDialog(data);
  }

  Future<void> _handleAnswer(Map<String, dynamic> data) async {
    if (_peerConnection != null) {
      final answer = RTCSessionDescription(
        data['answer']['sdp'],
        data['answer']['type'],
      );
      await _peerConnection!.setRemoteDescription(answer);
    }
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> data) async {
    final candidate = RTCIceCandidate(
      data['candidate']['candidate'],
      data['candidate']['sdpMid'],
      data['candidate']['sdpMLineIndex'],
    );

    if (_peerConnection != null) {
      await _peerConnection!.addCandidate(candidate);
    }
  }

  void _sendIceCandidate(RTCIceCandidate candidate) {
    _callService.socket?.emit('call:ice', {
      'callId': _activeCallId,
      'candidate': candidate.toMap(),
      'callerId': widget.callerId,
      'calleeId': widget.calleeId,
    });
  }

  Future<void> _answerCall() async {
    if (_callService.currentCallId != null) {
      await _callService.answerCall();
    }
  }

  Future<void> _endCall() async {
    await _cleanupCall();
    _callService.socket?.emit('call:end', {
      'callId': _activeCallId,
      'callerId': widget.callerId,
      'calleeId': widget.calleeId,
    });
    await _callService.endCall();
    _navigateBack();
  }

  Future<void> _declineCall() async {
    await _cleanupCall();
    _callService.socket?.emit('call:decline', {
      'callId': _activeCallId,
      'callerId': widget.callerId,
      'calleeId': widget.calleeId,
    });
    await _callService.declineCall();
  }

  void _handleCallDeclined() {
    _cleanupCall();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Call declined')),
      );
      _navigateBack();
    }
  }

  void _handleCallEnded() {
    _cleanupCall();
    if (mounted) {
      _navigateBack();
    }
  }

  Future<void> _cleanupCall() async {
    await _localStream?.dispose();
    _localStream = null;
    await _peerConnection?.close();
    _peerConnection = null;
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
  }

  Future<void> _navigateBack() async {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _localStream?.getAudioTracks().forEach((track) {
        track.enabled = !_isMuted;
      });
    });
  }

  Future<void> _toggleVideo() async {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
    final videoTracks = _localStream?.getVideoTracks();
    if (videoTracks != null) {
      for (var track in videoTracks) {
        track.enabled = _isVideoEnabled;
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_localStream == null) return;

    final videoTracks = _localStream!.getVideoTracks();
    if (videoTracks.isEmpty) return;

    videoTracks[0].stop();

    _isFrontCamera = !_isFrontCamera;

    try {
      final newStream = await navigator.mediaDevices.getUserMedia({
        'video': {
          'facingMode': _isFrontCamera ? 'user' : 'environment',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        },
        'audio': false,
      });

      final newVideoTrack = newStream.getVideoTracks()[0];
      _localStream!.removeTrack(_localStream!.getVideoTracks()[0]);
      _localStream!.addTrack(newVideoTrack);

      if (_peerConnection != null) {
        final senders = await _peerConnection!.getSenders();
        final sender = senders.firstWhere(
          (s) => s.track != null && s.track!.kind == 'video',
        );
        await sender.replaceTrack(newVideoTrack);
      }

      _localRenderer.srcObject = _localStream;
      setState(() => _isFrontCamera = !_isFrontCamera);
    } catch (e) {
      print('Error switching camera: $e');
    }
  }

  void _showIncomingCallDialog(Map<String, dynamic> data) {
    final callerName = data['callerName'] ?? widget.callerName ?? 'Doctor';
    final callType = data['callType'] ?? 'video';

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

  Widget _buildVideoArea() {
    return Stack(
      children: [
        Positioned.fill(
          child: RTCVideoView(_remoteRenderer),
        ),
        Positioned(
          top: 100,
          right: 16,
          width: 120,
          height: 160,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: RTCVideoView(_localRenderer, mirror: true),
            ),
          ),
        ),
        Positioned(
          top: 100,
          left: 16,
          right: 16,
          child: Center(child: _buildCallStateWidget()),
        ),
      ],
    );
  }

  Widget _buildCallStateWidget() {
    Color color;
    String text;
    switch (_callService.callState) {
      case CallState.idle:
        color = Colors.white;
        text = 'Ready for call';
        break;
      case CallState.ringingIncoming:
      case CallState.ringingOutgoing:
        color = Colors.orange;
        text = 'Ringing...';
        break;
      case CallState.connected:
        color = Colors.green;
        text = 'Connected';
        break;
      case CallState.ending:
        color = Colors.orange;
        text = 'Ending call...';
        break;
      case CallState.error:
        color = Colors.red;
        text = 'Call error';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCallControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  label: _isMuted ? 'Unmute' : 'Mute',
                  onPressed: _toggleMute,
                  backgroundColor: _isMuted ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 16),
                _buildControlButton(
                  icon: _isVideoEnabled ? Icons.videocam_off : Icons.videocam,
                  label: _isVideoEnabled ? 'Video Off' : 'Video On',
                  onPressed: _toggleVideo,
                  backgroundColor: _isVideoEnabled ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 16),
                if (widget.callType == CallType.video)
                  _buildControlButton(
                    icon: Icons.flip_camera_android,
                    label: 'Flip',
                    onPressed: _switchCamera,
                    backgroundColor: Colors.blue,
                  ),
                const SizedBox(width: 16),
                _buildControlButton(
                  icon: Icons.call_end,
                  label: 'End',
                  onPressed: _endCall,
                  backgroundColor: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 28),
            onPressed: onPressed,
            iconSize: 28,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = context.read<AuthProvider>().currentUser?.role == UserRole.kisanDoctor;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _callService.callState == CallState.idle && widget.isOutgoing
          ? AppBar(
              title: Text(isDoctor ? 'Video Consultation' : 'Video Call'),
              backgroundColor: isDoctor ? Colors.blue.shade700 : Colors.green.shade700,
              leading: widget.isOutgoing
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : null,
            )
          : null,
      body: Stack(
        children: [
          _buildVideoArea(),
          if (_callService.callState != CallState.idle)
            _buildCallControls(),
        ],
      ),
    );
  }
}