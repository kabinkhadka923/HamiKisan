import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum CallState { idle, ringingIncoming, ringingOutgoing, connected, ended, error }

enum CallType { video, voice }

class CallSignalingService {
  late IO.Socket _socket;
  late ValueNotifier<String?> _currentCallId;
  late ValueNotifier<CallState> _callState;
  late ValueNotifier<String?> _callerName;

  CallSignalingService() {
    _currentCallId = ValueNotifier<String?>(null);
    _callState = ValueNotifier<CallState>(CallState.idle);
    _callerName = ValueNotifier<String?>(null);
  }

  ValueNotifier<String?> get currentCallId => _currentCallId;
  ValueNotifier<CallState> get callState => _callState;
  ValueNotifier<String?> get callerName => _callerName;

  setSocket(IO.Socket socket) {
    _socket = socket;

    _socket.on('call:init', (data) {
      _callState.value = CallState.ringingOutgoing;
    });

    _socket.on('call:ringing', (data) {
      _callState.value = CallState.ringingIncoming;
      _callerName.value = data['fromName'] ?? 'Doctor';
    });

    _socket.on('call:connected', (data) {
      _callState.value = CallState.connected;
    });

    _socket.on('call:ended', (data) {
      _callState.value = CallState.ended;
    });
  }

  Future<void> initiateCall({
    required String receiverId,
    required CallType callType,
    required BuildContext context,
  }) async {
    if (!_socket.connected) return;

    _socket.emit('call:initiate', {
      'receiverId': receiverId,
      'callType': callType.name,
    });
  }

  Future<void> answerCall() async {
    if (!_socket.connected) return;
    _socket.emit('call:answer');
  }

  Future<void> endCall() async {
    if (!_socket.connected) return;
    _socket.emit('call:end');
    _callState.value = CallState.idle;
    _currentCallId.value = null;
  }

  Future<void> muteToggle() async {
    if (!_socket.connected) return;
    _socket.emit('call:muteToggle');
  }
}