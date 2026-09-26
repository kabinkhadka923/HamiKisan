import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/audio_service.dart';
import '../services/call/call_signaling_service.dart';
import '../services/call/kisan_video_call_service.dart';
import '../screens/video_call_screen.dart';

/// Polls the backend for incoming calls and shows a ringing screen when the
/// current user is being called. Wrap any dashboard body with this widget.
class IncomingCallListener extends StatefulWidget {
  final Widget child;

  const IncomingCallListener({super.key, required this.child});

  @override
  State<IncomingCallListener> createState() => _IncomingCallListenerState();
}

class _IncomingCallListenerState extends State<IncomingCallListener> {
  final CallSignalingService _signaling = CallSignalingService();
  final AudioService _audioService = AudioService();
  Timer? _pollTimer;
  bool _isShowingCall = false;
  bool _socketListenerAttached = false;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkIncomingCall());
    WidgetsBinding.instance.addPostFrameCallback((_) => _attachSocketListener());
  }

  void _attachSocketListener() {
    if (!mounted || _socketListenerAttached) return;
    final socket = context.read<AuthProvider>().socket;
    if (socket == null) return;
    socket.on('call_incoming', (data) {
      if (!mounted || _isShowingCall || data is! Map) return;
      final call = SignalCall.fromBackend({
        'id': data['callId'],
        'from': data['from'],
        'fromName': data['fromName'],
        'to': context.read<AuthProvider>().currentUser?.id,
        'callType': data['callType'],
        'status': 'ringing',
      });
      if (call.callId.isEmpty) return;
      _presentIncomingCall(call);
    });
    _socketListenerAttached = true;
  }

  void _presentIncomingCall(SignalCall call) {
    if (!mounted || _isShowingCall) return;
    setState(() {
      _isShowingCall = true;
    });
    _showIncomingCallSheet(call);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _audioService.stopCallSound();
    super.dispose();
  }

  Future<void> _checkIncomingCall() async {
    if (!mounted || _isShowingCall) return;
    _attachSocketListener();

    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null) return;

    final call = await _signaling.getIncomingCall();
    if (call == null || !mounted || _isShowingCall) return;

    _presentIncomingCall(call);
  }

  Future<void> _showIncomingCallSheet(SignalCall call) async {
    try {
      await _audioService.playIncomingCall(callerType: 'doctor', vibrate: true);
    } catch (_) {}

    final navigator = Navigator.of(context);
    final accepted = await _showRingingDialog(call);

    _audioService.stopCallSound();
    _isShowingCall = false;
    if (!mounted) return;
    setState(() {});

    if (accepted) {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      navigator.push(
        MaterialPageRoute(
          builder: (_) => VideoCallScreen(
            callId: call.callId,
            peerName: call.fromName ?? 'Unknown Caller',
            callerName: call.fromName ?? 'Unknown Caller',
            callerSpecialty: 'Video Consultation',
            role: CallRole.callee,
            callerId: call.from,
            calleeId: currentUser?.id ?? '',
            isOutgoing: false,
            callType: call.callType == 'voice' ? CallType.voice : CallType.video,
            callContext: {'callerType': 'doctor'},
          ),
        ),
      );
    }
  }

  Future<bool> _showRingingDialog(SignalCall call) async {
    bool accepted = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF66BB6A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 44, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                call.fromName ?? 'Incoming Caller',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Incoming Video Consultation...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'listener_decline',
                    onPressed: () async {
                      accepted = false;
                      await CallSignalingService()
                          .answerCall(callId: call.callId, accept: false);
                      Navigator.pop(dialogContext);
                    },
                    backgroundColor: Colors.red.shade600,
                    child: const Icon(Icons.call_end),
                  ),
                  const SizedBox(width: 40),
                  FloatingActionButton(
                    heroTag: 'listener_accept',
                    onPressed: () async {
                      accepted = true;
                      await CallSignalingService()
                          .answerCall(callId: call.callId, accept: true);
                      Navigator.pop(dialogContext);
                    },
                    backgroundColor: Colors.green.shade600,
                    child: const Icon(Icons.video_call),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return accepted;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
