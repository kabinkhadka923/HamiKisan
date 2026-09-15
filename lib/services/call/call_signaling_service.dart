import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth_service.dart';
import '../backend_config.dart';

enum SignalCallStatus { ringing, connected, declined, ended, notFound }

class SignalCall {
  final String callId;
  final String from;
  final String? fromName;
  final String to;
  final String callType;
  final SignalCallStatus status;

  SignalCall({
    required this.callId,
    required this.from,
    required this.to,
    required this.status,
    this.fromName,
    this.callType = 'video',
  });

  static SignalCallStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'ringing':
        return SignalCallStatus.ringing;
      case 'connected':
        return SignalCallStatus.connected;
      case 'declined':
        return SignalCallStatus.declined;
      case 'ended':
        return SignalCallStatus.ended;
      default:
        return SignalCallStatus.notFound;
    }
  }

  factory SignalCall.fromBackend(Map<String, dynamic> json) {
    final call =
        (json['call'] is Map<String, dynamic>) ? json['call'] as Map<String, dynamic> : json;
    return SignalCall(
      callId: (call['id'] ?? call['callId'] ?? '').toString(),
      from: (call['from'] ?? '').toString(),
      fromName: call['fromName']?.toString(),
      to: (call['to'] ?? '').toString(),
      callType: (call['callType'] ?? 'video').toString(),
      status: _parseStatus((call['status'] ?? json['status'])?.toString()),
    );
  }
}

class CallSignalingService {
  static final CallSignalingService _instance = CallSignalingService._internal();
  factory CallSignalingService() => _instance;
  CallSignalingService._internal();

  static const Duration _timeout = Duration(seconds: 6);

  Map<String, String> _headers({String? token, bool json = false}) => {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        if (json) 'Content-Type': 'application/json',
      };

  Future<Map<String, dynamic>?> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(_timeout);
      if (response.statusCode >= 400) return null;
      final body = json.decode(response.body);
      return body is Map<String, dynamic> ? body : null;
    } catch (_) {
      return null;
    }
  }

  /// Starts a call to [receiverId]. Returns the call id, or null on failure.
  Future<String?> inviteCall({
    required String receiverId,
    required String callerName,
    String callType = 'video',
  }) async {
    final token = await AuthService.getAuthToken();
    final data = await _send(() => http.post(
          BackendConfig.uri('/api/calls/invite'),
          headers: _headers(token: token, json: true),
          body: json.encode({
            'receiverId': receiverId,
            'callType': callType,
            'callerName': callerName,
          }),
        ));
    return data?['callId']?.toString();
  }

  /// Returns the incoming ringing call for the current user, or null.
  Future<SignalCall?> getIncomingCall() async {
    final token = await AuthService.getAuthToken();
    if (token == null) return null;
    final data = await _send(
        () => http.get(BackendConfig.uri('/api/calls/incoming'), headers: _headers(token: token)));
    final rawCall = data?['call'];
    if (rawCall is! Map<String, dynamic>) return null;
    final call = SignalCall.fromBackend(rawCall);
    return call.status == SignalCallStatus.ringing ? call : null;
  }

  Future<SignalCallStatus> answerCall({
    required String callId,
    required bool accept,
  }) async {
    final token = await AuthService.getAuthToken();
    final data = await _send(() => http.post(
          BackendConfig.uri('/api/calls/answer'),
          headers: _headers(token: token, json: true),
          body: json.encode({'callId': callId, 'accept': accept}),
        ));
    final raw = data?['status']?.toString();
    if (raw == null) {
      return SignalCallStatus.notFound;
    }
    return SignalCallStatus.values.firstWhere(
      (s) => s.name == raw,
      orElse: () => SignalCallStatus.notFound,
    );
  }

  Future<void> endCall({required String callId}) async {
    final token = await AuthService.getAuthToken();
    await _send(() => http.post(
          BackendConfig.uri('/api/calls/end'),
          headers: _headers(token: token, json: true),
          body: json.encode({'callId': callId}),
        ));
  }

  Future<SignalCallStatus> getCallStatus(String callId) async {
    final token = await AuthService.getAuthToken();
    final data = await _send(() => http
        .get(BackendConfig.uri('/api/calls/status/$callId'), headers: _headers(token: token)));
    final raw = data?['status']?.toString();
    if (raw == null) return SignalCallStatus.notFound;
    return SignalCallStatus.values.firstWhere(
      (s) => s.name == raw,
      orElse: () => SignalCallStatus.notFound,
    );
  }
}
