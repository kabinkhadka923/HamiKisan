import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post_model.dart';
import 'auth_service.dart';
import 'backend_config.dart';

class PostService {
  final Map<String, String> _headers = const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<void> initialize() async {}

  Future<void> addPost(Post post) async {
    await createPost(
      post.id,
      post.authorName,
      post.authorRole,
      post.content,
      post.imagePath,
      postType: post.postType,
      district: post.district,
    );
  }

  Future<Post> createPost(
    String userId,
    String userName,
    String userRole,
    String content,
    String? imagePath, {
    String postType = 'General',
    String? district,
  }) async {
    final _ = [userId, userName, userRole];
    final token = await AuthService.getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('You must be logged in to create a post.');
    }

    final response = await http.post(
      BackendConfig.uri('/api/posts'),
      headers: {
        ..._headers,
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'content': content,
        'postType': postType,
        'district': district,
        'imagePath': imagePath,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create post.');
    }

    final payload = json.decode(response.body) as Map<String, dynamic>;
    return _mapPost(payload);
  }

  Future<List<Post>> getPosts() async {
    return getAllPosts();
  }

  Future<List<Post>> getAllPosts() async {
    final token = await AuthService.getAuthToken();
    final headers = {
      ..._headers,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      BackendConfig.uri('/api/posts'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load posts.');
    }

    final data = json.decode(response.body) as List<dynamic>;
    return data.map((item) => _mapPost(Map<String, dynamic>.from(item))).toList();
  }

  Future<List<Post>> getPostsByDistrict(String district) async {
    final token = await AuthService.getAuthToken();
    final headers = {
      ..._headers,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      BackendConfig.uri('/api/posts', query: {'district': district}),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load district posts.');
    }

    final data = json.decode(response.body) as List<dynamic>;
    return data.map((item) => _mapPost(Map<String, dynamic>.from(item))).toList();
  }

  Future<void> deletePost(String postId) async {
    final token = await AuthService.getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('You must be logged in to delete a post.');
    }

    final response = await http.delete(
      BackendConfig.uri('/api/posts/$postId'),
      headers: {
        ..._headers,
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post.');
    }
  }

  Future<void> toggleLike(String postId) async {
    final token = await AuthService.getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('You must be logged in to like a post.');
    }

    final response = await http.post(
      BackendConfig.uri('/api/posts/$postId/like'),
      headers: {
        ..._headers,
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to toggle like.');
    }
  }

  Post _mapPost(Map<String, dynamic> raw) {
    return Post(
      id: raw['id'].toString(),
      authorName: (raw['authorName'] ?? '').toString(),
      authorRole: (raw['authorRole'] ?? 'farmer').toString(),
      content: (raw['content'] ?? '').toString(),
      postType: (raw['postType'] ?? 'General').toString(),
      district: raw['district']?.toString(),
      imagePath: raw['imagePath']?.toString(),
      timestamp: DateTime.tryParse(raw['timestamp']?.toString() ?? '') ?? DateTime.now(),
      likes: (raw['likes'] as num?)?.toInt() ?? 0,
      comments: (raw['comments'] as num?)?.toInt() ?? 0,
      shares: (raw['shares'] as num?)?.toInt() ?? 0,
      isLiked: raw['isLiked'] == true,
    );
  }
}
