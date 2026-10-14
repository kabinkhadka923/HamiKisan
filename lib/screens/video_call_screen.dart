import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../services/call/kisan_video_call_service.dart';
import '../services/call/call_signaling_service.dart';
import '../services/audio_service.dart';
import '../utils/logger.dart';

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
  Timer? _offerRetryTimer;
  Timer? _ringTimeoutTimer;
  dynamic _signalingSocket;
  final Map<String, Function> _signalingHandlers = {};
  bool _isHandlingOffer = false;
  bool _hasReceivedAnswer = false;
  bool _isEnding = false;

  // WebRTC
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final List<RTCIceCandidate> _pendingIceCandidates = [];
  bool _hasRemoteDescription = false;
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
    _offerRetryTimer?.cancel();
    _ringTimeoutTimer?.cancel();
    for (final entry in _signalingHandlers.entries) {
      _signalingSocket?.off(entry.key, entry.value);
    }
    _signalingHandlers.clear();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _peerConnection?.close();
    _callService.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    final authProvider = context.read<AuthProvider>();
    _callService = KisanVideoCallService();
    _audioService = AudioService();
    await _initializeRenderers();
    if (!mounted) return;

    _callService.setSocket(authProvider.socket);

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
      _callService.updateCallState(CallState.ringingOutgoing);
      final invited = await _prepareOutgoingCall(authProvider);
      if (!invited && mounted) _callService.updateCallState(CallState.idle);
    }
  }

  Future<bool> _prepareOutgoingCall(AuthProvider authProvider) async {
    final callId = await CallSignalingService().inviteCall(
      receiverId: widget.calleeId,
      callerName: authProvider.currentUser?.name ?? 'HamiKisan user',
      callType: widget.callType == CallType.voice ? 'voice' : 'video',
    );
    if (callId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Unable to start the call. Please try again.')),
        );
      }
      return false;
    }
    if (!mounted) {
      await CallSignalingService().endCall(callId: callId);
      return false;
    }
    _activeCallId = callId;
    authProvider.socket?.emit('call_invite', {
      'toUserId': widget.calleeId,
      'callId': callId,
      'callType': widget.callType.name,
      'callerName': authProvider.currentUser?.name,
    });
    _ringTimeoutTimer?.cancel();
    _ringTimeoutTimer = Timer(const Duration(seconds: 30), () async {
      if (!mounted || _callService.callState == CallState.connected) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No answer. The call has ended.')),
      );
      await _endCall();
    });
    return true;
  }

  void _setupSignaling() {
    final socket = _callService.socket;
    if (socket == null) return;
    _signalingSocket = socket;

    _listenToCallEvent('call:offer', (data) async {
      if (!mounted ||
          data is! Map<String, dynamic> ||
          data['callId']?.toString() != _activeCallId) {
        return;
      }
      await _handleIncomingOffer(data);
    });

    _listenToCallEvent('call:answer', (data) async {
      if (!mounted ||
          data is! Map<String, dynamic> ||
          data['callId']?.toString() != _activeCallId) {
        return;
      }
      await _handleAnswer(data);
    });

    _listenToCallEvent('call:accepted', (data) async {
      if (!mounted || data['callId']?.toString() != _activeCallId) return;
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      await _makeCall();
    });

    _listenToCallEvent('call:declined', (data) {
      if (!mounted || data['callId']?.toString() != _activeCallId) return;
      _handleCallDeclined();
    });

    _listenToCallEvent('call:ended', (data) {
      if (!mounted || data['callId']?.toString() != _activeCallId) return;
      _handleCallEnded();
    });

    _listenToCallEvent('call:ice', (data) async {
      if (!mounted ||
          data is! Map<String, dynamic> ||
          data['callId']?.toString() != _activeCallId) {
        return;
      }
      await _handleIceCandidate(data);
    });

  }

  void _listenToCallEvent(
    String event,
    void Function(dynamic) handler,
  ) {
    _signalingHandlers[event] = handler;
    _signalingSocket.on(event, handler);
  }

  void _handleCallStateChange(CallState state) {
    setState(() {});
    switch (state) {
      case CallState.idle:
        _ringTimeoutTimer?.cancel();
        unawaited(_audioService.stopCallSound());
        break;
      case CallState.connected:
        _ringTimeoutTimer?.cancel();
        unawaited(_playConnectedTone());
        break;
      case CallState.ending:
        unawaited(_playEndedTone());
        break;
      case CallState.error:
        unawaited(_audioService.stopCallSound());
        break;
      case CallState.connecting:
      case CallState.ringingIncoming:
        unawaited(_audioService.stopCallSound());
        break;
      case CallState.ringingOutgoing:
        unawaited(_audioService.stopCallSound());
        break;
    }
  }

  Future<void> _playConnectedTone() async {
    await _audioService.stopCallSound();
    await _audioService.playCallConnected();
  }

  Future<void> _playEndedTone() async {
    await _audioService.stopCallSound();
    await _audioService.playCallEnded();
  }

  Future<bool> _startLocalStream() async {
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

      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      for (final track in _localStream!.getAudioTracks()) {
        track.enabled = !_isMuted;
      }
      for (final track in _localStream!.getVideoTracks()) {
        track.enabled = _isVideoEnabled;
      }
      _localRenderer.srcObject = _localStream;

      if (mounted) setState(() {});
      return true;
    } catch (e) {
      Logger.error('Could not start local video stream',
          tag: 'VideoCall', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.callType == CallType.voice
                  ? 'Microphone access is required for voice calls.'
                  : 'Camera and microphone access are required for video calls.',
            ),
          ),
        );
      }
      return false;
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
    _peerConnection!.onConnectionState = (state) {
      if (!mounted) return;
      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          _callService.updateCallState(CallState.connected);
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          if (_callService.callState != CallState.ending) {
            _callService.updateCallState(CallState.connecting);
          }
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The call connection failed. Please try again.'),
            ),
          );
          _callService.updateCallState(CallState.error);
          unawaited(_endCall());
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
        case RTCPeerConnectionState.RTCPeerConnectionStateNew:
          break;
      }
    };

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
    _callService.updateCallState(CallState.connecting);
    try {
      if (!await _startLocalStream()) {
        _callService.updateCallState(CallState.error);
        await _endCall();
        return;
      }
      await _createPeerConnection();

      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      final payload = {
        'callId': _activeCallId,
        'offer': offer.toMap(),
        'callerId': widget.callerId,
        'calleeId': widget.calleeId,
        'callType': widget.callType.name,
      };
      _callService.socket?.emit('call:offer', payload);
      _offerRetryTimer?.cancel();
      _offerRetryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || _hasReceivedAnswer) {
          timer.cancel();
          return;
        }
        _callService.socket?.emit('call:offer', payload);
      });
    } catch (error) {
      Logger.error('Could not start call media signaling',
          tag: 'VideoCall', error: error);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not connect the call.')),
        );
        _callService.updateCallState(CallState.error);
        await _endCall();
      }
    }
  }

  Future<void> _handleIncomingOffer(Map<String, dynamic> data) async {
    if (_isHandlingOffer) return;
    _isHandlingOffer = true;

    try {
      if (!await _startLocalStream()) {
        _isHandlingOffer = false;
        _callService.updateCallState(CallState.error);
        await _endCall();
        return;
      }
      await _createPeerConnection();

      final offer = RTCSessionDescription(
        data['offer']['sdp'],
        data['offer']['type'],
      );

      await _peerConnection!.setRemoteDescription(offer);
      _hasRemoteDescription = true;
      await _applyPendingIceCandidates();

      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      _callService.updateCallState(CallState.connecting);

      _callService.socket?.emit('call:answer', {
        'callId': _activeCallId,
        'answer': (await _peerConnection!.getLocalDescription())?.toMap(),
        'callerId': data['callerId'],
        'calleeId': widget.calleeId,
      });
    } catch (error) {
      _isHandlingOffer = false;
      Logger.error('Could not accept call offer',
          tag: 'VideoCall', error: error);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not connect the call.')),
        );
      }
    }
  }

  Future<void> _handleAnswer(Map<String, dynamic> data) async {
    if (_peerConnection != null && !_hasReceivedAnswer) {
      try {
        final answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );
        await _peerConnection!.setRemoteDescription(answer);
        _hasRemoteDescription = true;
        await _applyPendingIceCandidates();
        _hasReceivedAnswer = true;
        _offerRetryTimer?.cancel();
        _callService.updateCallState(CallState.connecting);
      } catch (error) {
        Logger.error('Could not apply call answer',
            tag: 'VideoCall', error: error);
        if (mounted) await _endCall();
      }
    }
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> data) async {
    final rawCandidate = data['candidate'];
    if (rawCandidate is! Map<String, dynamic>) return;

    final candidate = RTCIceCandidate(
      rawCandidate['candidate']?.toString(),
      rawCandidate['sdpMid']?.toString(),
      rawCandidate['sdpMLineIndex'] is int
          ? rawCandidate['sdpMLineIndex'] as int
          : int.tryParse(rawCandidate['sdpMLineIndex']?.toString() ?? ''),
    );

    if (_peerConnection != null && _hasRemoteDescription) {
      await _peerConnection!.addCandidate(candidate);
    } else {
      _pendingIceCandidates.add(candidate);
    }
  }

  Future<void> _applyPendingIceCandidates() async {
    final peerConnection = _peerConnection;
    if (peerConnection == null) return;

    for (final candidate in _pendingIceCandidates) {
      await peerConnection.addCandidate(candidate);
    }
    _pendingIceCandidates.clear();
  }

  void _sendIceCandidate(RTCIceCandidate candidate) {
    _callService.socket?.emit('call:ice', {
      'callId': _activeCallId,
      'candidate': candidate.toMap(),
      'callerId': widget.callerId,
      'calleeId': widget.calleeId,
    });
  }

  Future<void> _endCall() async {
    if (_isEnding) return;
    _isEnding = true;
    _offerRetryTimer?.cancel();
    _ringTimeoutTimer?.cancel();
    await _cleanupCall();
    await CallSignalingService().endCall(callId: _activeCallId);
    _callService.socket?.emit('call:end', {
      'callId': _activeCallId,
      'callerId': widget.callerId,
      'calleeId': widget.calleeId,
    });
    await _callService.endCall();
    _navigateBack();
  }

  void _handleCallDeclined() {
    _ringTimeoutTimer?.cancel();
    _offerRetryTimer?.cancel();
    unawaited(_audioService.stopCallSound());
    _cleanupCall();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Call declined')),
      );
      _navigateBack();
    }
  }

  void _handleCallEnded() {
    _ringTimeoutTimer?.cancel();
    _offerRetryTimer?.cancel();
    unawaited(_audioService.stopCallSound());
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
    final currentTrack = videoTracks.first;
    MediaStream? replacementStream;

    try {
      replacementStream = await navigator.mediaDevices.getUserMedia({
        'video': {
          'facingMode': _isFrontCamera ? 'environment' : 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
        },
        'audio': false,
      });

      final newVideoTracks = replacementStream.getVideoTracks();
      if (newVideoTracks.isEmpty) {
        throw StateError('No video track returned when switching cameras.');
      }
      final newVideoTrack = newVideoTracks.first;

      if (_peerConnection != null) {
        final senders = await _peerConnection!.getSenders();
        RTCRtpSender? sender;
        for (final candidate in senders) {
          if (candidate.track?.kind == 'video') {
            sender = candidate;
            break;
          }
        }
        if (sender == null) {
          throw StateError('Video sender is not available.');
        }
        await sender.replaceTrack(newVideoTrack);
      }

      _localStream!.removeTrack(currentTrack);
      _localStream!.addTrack(newVideoTrack);
      await currentTrack.stop();
      _localRenderer.srcObject = _localStream;
      if (mounted) setState(() => _isFrontCamera = !_isFrontCamera);
    } catch (e) {
      for (final track in replacementStream?.getTracks() ?? <MediaStreamTrack>[]) {
        await track.stop();
      }
      Logger.error('Could not switch camera', tag: 'VideoCall', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not switch camera.')),
        );
      }
    }
  }

  Widget _buildVideoArea() {
    if (widget.callType == CallType.voice) {
      return Positioned.fill(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF173B32), Color(0xFF101820)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 58,
                backgroundColor: Colors.white.withValues(alpha: 0.14),
                child: const Icon(Icons.person, size: 58, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                widget.peerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildCallStateWidget(),
            ],
          ),
        ),
      );
    }
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
      case CallState.connecting:
        color = Colors.orange;
        text = 'Connecting...';
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
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
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
                if (widget.callType == CallType.video) ...[
                  _buildControlButton(
                    icon: _isVideoEnabled ? Icons.videocam_off : Icons.videocam,
                    label: _isVideoEnabled ? 'Video Off' : 'Video On',
                    onPressed: _toggleVideo,
                    backgroundColor:
                        _isVideoEnabled ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  _buildControlButton(
                    icon: Icons.flip_camera_android,
                    label: 'Flip',
                    onPressed: _switchCamera,
                    backgroundColor: Colors.blue,
                  ),
                  const SizedBox(width: 16),
                ],
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
                color: Colors.black.withValues(alpha: 0.3),
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
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor =
        context.read<AuthProvider>().currentUser?.role == UserRole.kisanDoctor;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _callService.callState == CallState.idle && widget.isOutgoing
          ? AppBar(
              title: Text(isDoctor ? 'Video Consultation' : 'Video Call'),
              backgroundColor:
                  isDoctor ? Colors.blue.shade700 : Colors.green.shade700,
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
          if (_callService.callState != CallState.idle) _buildCallControls(),
        ],
      ),
    );
  }
}
