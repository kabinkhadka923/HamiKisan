import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';
import 'backend_config.dart';

class ConnectionRecord {
  final String id;
  final String requesterId;
  final String receiverId;
  final String status;
  final String otherUserId;
  final String? otherUserName;
  final String? otherUserRole;

  const ConnectionRecord({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.status,
    required this.otherUserId,
    this.otherUserName,
    this.otherUserRole,
  });

  factory ConnectionRecord.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final requesterId = (json['requester_id'] ?? json['requesterId']).toString();
    final receiverId = (json['receiver_id'] ?? json['receiverId']).toString();
    return ConnectionRecord(
      id: (json['id'] ?? '').toString(),
      requesterId: requesterId,
      receiverId: receiverId,
      status: (json['status'] ?? 'pending').toString(),
      otherUserId: requesterId == currentUserId ? receiverId : requesterId,
      otherUserName: json['other_user_name']?.toString(),
      otherUserRole: json['other_user_role']?.toString(),
    );
  }
}

class ConnectionService {
  Map<String, String> _headers({String? token, bool json = false}) => {
        'Accept': 'application/json',
        if (json) 'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<List<ConnectionRecord>> listConnections(String currentUserId) async {
    final token = await AuthService.getAuthToken();
    final response = await http.get(
      BackendConfig.uri('/api/connections'),
      headers: _headers(token: token),
    );
    if (response.statusCode != 200) {
      throw Exception(_errorMessage(response));
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final records = data['connections'] as List<dynamic>? ?? [];
    return records
        .whereType<Map<String, dynamic>>()
        .map((item) => ConnectionRecord.fromJson(item, currentUserId))
        .toList();
  }

  Future<ConnectionRecord> requestConnection(String receiverId) async {
    final token = await AuthService.getAuthToken();
    final response = await http.post(
      BackendConfig.uri('/api/connections/request'),
      headers: _headers(token: token, json: true),
      body: json.encode({'receiverId': receiverId}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return ConnectionRecord.fromJson(
      Map<String, dynamic>.from(data['connection'] as Map),
      '',
    );
  }

  Future<ConnectionRecord> updateConnection(String connectionId, String action) async {
    final token = await AuthService.getAuthToken();
    final response = await http.post(
      BackendConfig.uri('/api/connections/$connectionId/$action'),
      headers: _headers(token: token, json: true),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    return ConnectionRecord.fromJson(
      Map<String, dynamic>.from(data['connection'] as Map),
      '',
    );
  }

  Future<void> reportConnection(String connectionId, String reason) async {
    final token = await AuthService.getAuthToken();
    final response = await http.post(
      BackendConfig.uri('/api/connections/$connectionId/report'),
      headers: _headers(token: token, json: true),
      body: json.encode({'reason': reason}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }
  }

  Future<void> requestAppointment({
    required String doctorId,
    required DateTime scheduledAt,
    String notes = '',
  }) async {
    final token = await AuthService.getAuthToken();
    final response = await http.post(
      BackendConfig.uri('/api/appointments'),
      headers: _headers(token: token, json: true),
      body: json.encode({
        'doctorId': doctorId,
        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
        'notes': notes,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }
  }

  Future<void> setAvailability(bool isOnline) async {
    final token = await AuthService.getAuthToken();
    final response = await http.patch(
      BackendConfig.uri('/api/users/me/availability'),
      headers: _headers(token: token, json: true),
      body: json.encode({'isOnline': isOnline}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }
  }

  String _errorMessage(http.Response response) {
    try {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['error']?.toString() ?? 'Connection request failed.';
    } catch (_) {
      return 'Connection request failed (${response.statusCode}).';
    }
  }
}
