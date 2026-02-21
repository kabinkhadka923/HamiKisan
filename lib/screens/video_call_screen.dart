import 'package:flutter/material.dart';
import '../services/call/kisan_video_call_service.dart';

class VideoCallScreen extends StatefulWidget {
  final String doctorName;
  final String doctorSpecialty;
  final String? doctorImageUrl;
  final String callId;
  final String? recipientId;
  final bool isOutgoing;
  final CallType callType;
  final Map<String, dynamic>? callContext;

  const VideoCallScreen({
    super.key,
    required this.doctorName,
    this.doctorSpecialty = 'General Practitioner',
    this.doctorImageUrl,
    required this.callId,
    this.recipientId,
    this.isOutgoing = true,
    this.callType = CallType.video,
    this.callContext,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with SingleTickerProviderStateMixin {
  final KisanVideoCallService _callService = KisanVideoCallService();

  late AnimationController _ringAnimationController;
  late Animation<double> _ringPulseAnimation;

  bool _isCallConnected = false;
  bool _isRinging = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  String _callDuration = '00:00';

  @override
  void initState() {
    super.initState();
    _isVideoEnabled = widget.callType == CallType.video;

    // Initialize ring animation
    _ringAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _ringPulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _ringAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _ringAnimationController.repeat(reverse: true);

    // Start call process
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    // Listen for connection events
    _callService.onCallConnected.listen((_) {
      if (mounted) {
        setState(() {
          _isCallConnected = true;
          _isRinging = false;
        });
        _ringAnimationController.stop();
      }
    });

    _callService.onCallEnded.listen((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });

    // Listen for call duration updates
    _callService.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _callDuration = _callService.getCallDurationString();
        });
      }
    });

    // Listen for state changes
    _callService.onStateChanged.listen((state) {
      if (!mounted) return;
    });

    if (widget.isOutgoing) {
      // Outgoing call
      setState(() {
        _isRinging = true;
      });
      final recipientId = (widget.recipientId ?? widget.callId).trim();
      if (recipientId.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Unable to start call: missing recipient')),
        );
        Navigator.pop(context);
        return;
      }
      await _callService.handleOutgoingCall(
        recipientId: recipientId,
        callType: widget.callType,
      );
    } else {
      // Incoming call
      setState(() {
        _isRinging = true;
      });
      final callerType =
          (widget.callContext?['callerType']?.toString() ?? 'doctor');
      await _callService.handleIncomingCall(
        callerId: widget.callId,
        callerType: callerType,
        context: widget.callContext,
      );
    }
  }

  @override
  void dispose() {
    _ringAnimationController.dispose();
    _callService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main video/content area
          _buildMainContent(),

          // Ringing overlay
          if (_isRinging) _buildRingingOverlay(),

          // Call controls
          _buildCallControls(),

          // Top info bar
          _buildInfoBar(),
        ],
      ),
    );
  }

  Widget _buildRingingOverlay() {
    if (!widget.isOutgoing) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF66BB6A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ScaleTransition(
              scale: _ringPulseAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                    child: widget.doctorImageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              widget.doctorImageUrl!,
                              fit: BoxFit.cover,
                              width: 112,
                              height: 112,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 52,
                            color: Colors.white,
                          ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.doctorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Incoming Video Consultation...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        heroTag: 'decline_call',
                        onPressed: () => _callService.declineCall(),
                        backgroundColor: Colors.red.shade600,
                        child: const Icon(Icons.call_end),
                      ),
                      const SizedBox(width: 44),
                      FloatingActionButton(
                        heroTag: 'accept_call',
                        onPressed: () => _callService.acceptCall(),
                        backgroundColor: Colors.green.shade600,
                        child: const Icon(Icons.video_call),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: ScaleTransition(
          scale: _ringPulseAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue.shade800,
                child: widget.doctorImageUrl != null
                    ? ClipOval(
                        child: Image.network(
                          widget.doctorImageUrl!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.isOutgoing ? 'Calling...' : 'Incoming Call',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.doctorName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 30),
              if (!widget.isOutgoing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decline button
                    FloatingActionButton(
                      heroTag: 'decline_call',
                      onPressed: () => _callService.declineCall(),
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.call_end),
                    ),
                    const SizedBox(width: 40),
                    // Accept button
                    FloatingActionButton(
                      heroTag: 'accept_call',
                      onPressed: () => _callService.acceptCall(),
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.call),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade800,
          ],
        ),
      ),
      child:
          _isCallConnected ? _buildConnectedContent() : _buildWaitingContent(),
    );
  }

  Widget _buildConnectedContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 80,
            backgroundColor: Colors.blue.shade800,
            child: widget.doctorImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      widget.doctorImageUrl!,
                      fit: BoxFit.cover,
                      width: 160,
                      height: 160,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.doctorName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.doctorSpecialty,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _callDuration,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          Text(
            widget.isOutgoing
                ? 'Connecting to ${widget.doctorName}...'
                : 'Incoming call from ${widget.doctorName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    if (!widget.isOutgoing && _isRinging && !_isCallConnected) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute button
          _buildControlButton(
            icon: Icons.mic,
            activeIcon: Icons.mic_off,
            isActive: _isMuted,
            onTap: () {
              setState(() => _isMuted = !_isMuted);
              _callService.muteCall(_isMuted);
            },
            color: _isMuted ? Colors.red : Colors.white24,
          ),

          // End call button
          _buildControlButton(
            icon: Icons.call_end,
            isActive: true,
            onTap: () => _callService.endCall(),
            color: Colors.red,
            scale: 1.3,
          ),

          // Switch camera button
          if (widget.callType == CallType.video)
            _buildControlButton(
              icon: Icons.switch_camera,
              isActive: false,
              onTap: () {
                setState(() => _isVideoEnabled = !_isVideoEnabled);
                _callService.switchCamera();
              },
              color: _isVideoEnabled ? Colors.white24 : Colors.red,
            )
          else
            const SizedBox(width: 56),
        ],
      ),
    );
  }

  Widget _buildInfoBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            onPressed: () => _showExitConfirmation(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // Call info
          Column(
            children: [
              Text(
                _isCallConnected ? 'Connected' : 'Connecting',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              if (_isCallConnected)
                Text(
                  _callDuration,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                Text(
                  widget.callType == CallType.video
                      ? 'Video Call'
                      : 'Audio Call',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
            ],
          ),

          // Network status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isCallConnected
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.wifi,
                  color: _isCallConnected ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _isCallConnected ? 'Good' : 'Connecting',
                  style: TextStyle(
                    color: _isCallConnected ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    IconData? activeIcon,
    required bool isActive,
    required VoidCallback onTap,
    required Color color,
    double scale = 1.0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          isActive && activeIcon != null ? activeIcon : icon,
          color: Colors.white,
          size: 24 * scale,
        ),
      ),
    );
  }

  Future<void> _showExitConfirmation() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Call?'),
        content: const Text('Are you sure you want to end the call?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'End Call',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      await _callService.endCall();
    }
  }
}
