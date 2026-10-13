import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/post_model.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';
import 'backend_config.dart';

class PostService {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  static const String _localPostsKey = 'local_farmer_posts_v1';
  static const String _localCommentsKey = 'local_post_comments_v1';

  String? _currentFarmerId;

  final StreamController<Post> _postStreamController =
      StreamController<Post>.broadcast();
  Stream<Post> get postStream => _postStreamController.stream;

  Function(Post)? onPostCreated;
  Function(List<Post>)? onPostsLoaded;
  Function(Post)? onPostUpdated;
  Function(Post)? onPostDeleted;
  Function(Post)? onPostLiked;

  Future<void> initialize(String farmerId) async {
    _currentFarmerId = farmerId;

    // Load local posts first
    final localPosts = await _loadLocalPosts();
    onPostsLoaded?.call(localPosts);
  }

  Future<List<Post>> _loadLocalPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_localPostsKey);

    if (jsonString == null) return [];

    final List<dynamic> posts = json.decode(jsonString);
    return posts.map((p) => Post.fromMap(p)).toList();
  }

  Future<void> _saveLocalPosts(List<Post> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonPosts =
        posts.map((p) => p.toMap()).toList();
    final String jsonString = json.encode(jsonPosts);
    await prefs.setString(_localPostsKey, jsonString);
  }

  /// Create a new post
  Future<Post> createPost(Post post) async {
    final farmerId = _currentFarmerId ?? post.farmerId;
    if (farmerId.isEmpty) {
      throw StateError('A signed-in user is required to create a post.');
    }

    final postWithFarmer = post.copyWith(
      id: post.id.isEmpty
          ? 'post_${farmerId}_${DateTime.now().microsecondsSinceEpoch}'
          : post.id,
      farmerId: farmerId,
      farmerName: post.farmerName.isEmpty ? 'Farmer' : post.farmerName,
    );

    // Save locally
    final currentPosts = await _loadLocalPosts();
    currentPosts.add(postWithFarmer);
    await _saveLocalPosts(currentPosts);

    // Broadcast to UI
    _postStreamController.add(postWithFarmer);

    // Call backend
    try {
      final token = await AuthService.getAuthToken();
      final body = {
        'farmerId': postWithFarmer.farmerId,
        'farmerName': postWithFarmer.farmerName,
        'postType': postWithFarmer.postType.name,
        'title': postWithFarmer.title,
        'content': postWithFarmer.content,
        if (postWithFarmer.mediaUrl != null)
          'mediaUrl': postWithFarmer.mediaUrl,
        if (postWithFarmer.imageUrl != null)
          'imageUrl': postWithFarmer.imageUrl,
        if (postWithFarmer.imageUrls.isNotEmpty)
          'imageUrls': postWithFarmer.imageUrls,
        if (postWithFarmer.price != null) 'price': postWithFarmer.price,
        if (postWithFarmer.unit != null) 'unit': postWithFarmer.unit,
        if (postWithFarmer.cropName != null)
          'cropName': postWithFarmer.cropName,
        if (postWithFarmer.location != null)
          'location': postWithFarmer.location,
        if (postWithFarmer.district != null)
          'district': postWithFarmer.district,
        'isOrganic': postWithFarmer.isOrganic,
        'qualityGrade': postWithFarmer.qualityGrade,
        'status': postWithFarmer.status.name,
      };

      final response = await http
          .post(
            BackendConfig.uri('/api/posts'),
            headers: {
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        onPostCreated?.call(postWithFarmer);
        return postWithFarmer;
      } else {
        throw Exception(
          'Post saved locally, but the server rejected it '
          '(HTTP ${response.statusCode}).',
        );
      }
    } catch (e) {
      Logger.warning(
        'Post is available locally but could not be synchronized',
        tag: 'Posts',
        data: e,
      );
      onPostCreated?.call(postWithFarmer);
      return postWithFarmer;
    }
  }

  /// Get all posts (local + backend)
  Future<List<Post>> getAllPosts() async {
    final localPosts = await _loadLocalPosts();
    localPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return localPosts;
  }

  /// Like a post
  Future<void> likePost(Post post, String userId) async {
    final updatedPost = post.copyWith(likes: post.likes + 1, isLiked: true);

    // Update locally
    final currentPosts = await _loadLocalPosts();
    final idx = currentPosts.indexWhere((p) => p.id == post.id);
    if (idx >= 0) {
      currentPosts[idx] = updatedPost;
      await _saveLocalPosts(currentPosts);
      _postStreamController.add(updatedPost);
    }

    // Call backend
    try {
      final token = await AuthService.getAuthToken();
      final response = await http.post(
        BackendConfig.uri('/api/posts/like'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {'postId': post.id, 'farmerId': userId},
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        Logger.warning('Post like update was not accepted by the server',
            tag: 'Posts',
            data: {'postId': post.id, 'statusCode': response.statusCode});
      }
    } catch (e) {
      Logger.warning('Could not synchronize post like', tag: 'Posts', data: e);
    }
  }

  /// Get posts for a specific farmer
  Future<List<Post>> getPostsByFarmer(String farmerId) async {
    final localPosts = await _loadLocalPosts();
    return localPosts.where((post) => post.farmerId == farmerId).toList();
  }

  /// Get all local posts (farmerId parameter not required)
  Future<List<Post>> getPosts() async {
    return getAllPosts();
  }

  /// Toggle like on a post
  Future<void> toggleLike(Post post, String userId) async {
    if (post.isLiked) {
      await unlikePost(post, userId);
    } else {
      await likePost(post, userId);
    }
  }

  /// Unlike a post
  Future<void> unlikePost(Post post, String userId) async {
    final updatedPost = post.copyWith(
      likes: (post.likes - 1).clamp(0, 1 << 31),
      isLiked: false,
    );

    // Update locally
    final currentPosts = await _loadLocalPosts();
    final idx = currentPosts.indexWhere((p) => p.id == post.id);
    if (idx >= 0) {
      currentPosts[idx] = updatedPost;
      await _saveLocalPosts(currentPosts);
      _postStreamController.add(updatedPost);
    }

    // Call backend
    try {
      final token = await AuthService.getAuthToken();
      final response = await http.post(
        BackendConfig.uri('/api/posts/unlike'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {'postId': post.id, 'farmerId': userId},
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        Logger.warning('Post unlike update was not accepted by the server',
            tag: 'Posts',
            data: {'postId': post.id, 'statusCode': response.statusCode});
      }
    } catch (e) {
      Logger.warning('Could not synchronize post unlike',
          tag: 'Posts', data: e);
    }
  }

  /// Delete a post
  Future<void> deletePost(Post post) async {
    // Remove locally
    final currentPosts = await _loadLocalPosts();
    currentPosts.removeWhere((p) => p.id == post.id);
    await _saveLocalPosts(currentPosts);
    // Call backend
    try {
      final token = await AuthService.getAuthToken();
      final response = await http.delete(
        BackendConfig.uri('/api/posts/${post.id}'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        Logger.warning('Post deletion was not accepted by the server',
            tag: 'Posts',
            data: {'postId': post.id, 'statusCode': response.statusCode});
      }
    } catch (e) {
      Logger.warning('Post was deleted locally but could not be synchronized',
          tag: 'Posts', data: e);
    }
  }

  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_localCommentsKey);
    if (stored == null) return [];
    final allComments = json.decode(stored) as Map<String, dynamic>;
    final rawComments = allComments[postId] as List<dynamic>? ?? [];
    return rawComments
        .whereType<Map<String, dynamic>>()
        .toList()
        .reversed
        .toList();
  }

  /// Save the comment locally and attempt to synchronize it with the backend.
  Future<Map<String, dynamic>> addComment({
    required Post post,
    required String comment,
    required String userId,
    required String userName,
  }) async {
    final cleanedComment = comment.trim();
    if (cleanedComment.isEmpty) {
      throw ArgumentError.value(comment, 'comment', 'Comment cannot be empty');
    }
    if (userId.isEmpty) {
      throw StateError('A signed-in user is required to comment.');
    }

    final savedComment = {
      'id': 'comment_${DateTime.now().microsecondsSinceEpoch}',
      'userId': userId,
      'userName': userName,
      'comment': cleanedComment,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_localCommentsKey);
    final allComments = stored == null
        ? <String, dynamic>{}
        : json.decode(stored) as Map<String, dynamic>;
    final postComments =
        (allComments[post.id] as List<dynamic>? ?? []).toList();
    postComments.add(savedComment);
    allComments[post.id] = postComments;
    await prefs.setString(_localCommentsKey, json.encode(allComments));

    final currentPosts = await _loadLocalPosts();
    final idx = currentPosts.indexWhere((p) => p.id == post.id);
    if (idx >= 0) {
      final updatedPost =
          currentPosts[idx].copyWith(comments: currentPosts[idx].comments + 1);
      currentPosts[idx] = updatedPost;
      await _saveLocalPosts(currentPosts);
      _postStreamController.add(updatedPost);
    }

    try {
      final token = await AuthService.getAuthToken();
      final response = await http.post(
        BackendConfig.uri('/api/posts/comment'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {
          'postId': post.id,
          'comment': cleanedComment,
          'farmerId': userId,
        },
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        Logger.warning('Post comment was not accepted by the server',
            tag: 'Posts',
            data: {'postId': post.id, 'statusCode': response.statusCode});
      }
    } catch (e) {
      Logger.warning(
          'Post comment is saved locally but could not be synchronized',
          tag: 'Posts',
          data: e);
    }
    return savedComment;
  }
}
