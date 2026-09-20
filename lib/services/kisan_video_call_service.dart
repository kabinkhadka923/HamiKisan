import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum CallState { idle, ringingIncoming, ringingOutgoing, connected, ending, error }
enum CallType { video, voice }

class KisanVideoCallService {
  late IO.Socket _socket;
  late CallState _callState;
  late String? _currentCallId;
  final ValueNotifier<CallState> _onStateChanged = ValueNotifier(CallState.idle);
  final ValueNotifier<String?> _onCallConnected = ValueNotifier<String?>(null);
  final ValueNotifier<void> _onCallEnded = ValueNotifier<void>(null);

  ValueNotifier<CallState> get onStateChanged => _onStateChanged;
  ValueNotifier<String?> get onCallConnected => _onCallConnected;
  ValueNotifier<void> get onCallEnded => _onCallEnded;

  setSocket(IO.Socket socket) {
    _socket = socket;
  }

  Future<void> init({required IO.Socket socket}) async {
    _socket = socket;

    _socket.on('call:init', (data) {
      _onStateChanged.value = CallState.ringingOutgoing;
    });

    _socket.on('call:ringing', (data) {
      _onStateChanged.value = CallState.ringingIncoming;
    });

    _socket.on('call:connected', (data) {
      _onStateChanged.value = CallState.connected;
      _onCallConnected.value = _currentCallId;
    });

    _socket.on('call:ended', (data) {
      _onStateChanged.value = CallState.error;
      _onCallEnded.value();
    });
  }

  Future<void> answerCall() async {
    if (_socket.connected) {
      _socket.emit('call:answer', {'callId': _currentCallId});
    }
  }

  Future<void> endCall() async {
    if (_socket.connected) {
      _socket.emit('call:end', {'callId': _currentCallId});
    }
    _onStateChanged.value = CallState.idle;
    _onCallEnded.value();
  }

  Future<void> muteCall(bool muted) async {
    if (_socket.connected) {
      _socket.emit('call:mute', {'callId': _currentCallId, 'muted': muted});
    }
    _callServiceIsMuted = muted;
  }

  Future<void> switchCamera() async {
    // Camera switch logic
  }

  bool get isMuted => _callServiceIsMuted;
  bool _callServiceIsMuted = false;

  String? get currentCallId => _currentCallId;
  CallState get callState => _callState;

  Future<void> dispose() async {
    _onStateChanged.dispose();
    _onCallConnected.dispose();
    _onCallEnded.dispose();
    if (_socket.connected) {
      _socket.disconnect();
    }
  }

  Future<void> declineCall() async {
    if (_socket.connected && _currentCallId != null) {
      _socket.emit('call:decline', {'callId': _currentCallId});
    }
    _onStateChanged.value = CallState.idle;
  }
}