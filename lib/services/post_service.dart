import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/post_model.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'backend_config.dart';

class PostService {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  static const String _localPostsKey = 'local_farmer_posts_v1';

  String? _currentFarmerId;
  bool _isConnected = false;

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
    _isConnected = true;

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
    // Set farmer info from current user
    final postWithFarmer = post.copyWith(
      farmerId: _currentFarmerId ?? '',
      farmerName: await _getFarmerName(),
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
        if (postWithFarmer.mediaUrl != null) 'mediaUrl': postWithFarmer.mediaUrl,
        if (postWithFarmer.imageUrl != null) 'imageUrl': postWithFarmer.imageUrl,
        if (postWithFarmer.imageUrls.isNotEmpty)
            'imageUrls': postWithFarmer.imageUrls,
        if (postWithFarmer.price != null) 'price': postWithFarmer.price,
        if (postWithFarmer.unit != null) 'unit': postWithFarmer.unit,
        if (postWithFarmer.cropName != null) 'cropName': postWithFarmer.cropName,
        if (postWithFarmer.location != null) 'location': postWithFarmer.location,
        if (postWithFarmer.district != null) 'district': postWithFarmer.district,
        'isOrganic': postWithFarmer.isOrganic,
        'qualityGrade': postWithFarmer.qualityGrade,
        'status': postWithFarmer.status.name,
      };

      final response = await http.post(
        BackendConfig.uri('/api/posts'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        onPostCreated?.call(postWithFarmer);
        return postWithFarmer;
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      // If backend fails, keep local version
      onPostCreated?.call(postWithFarmer);
      return postWithFarmer;
    }
  }

  /// Get all posts (local + backend)
  Future<List<Post>> getAllPosts() async {
    final localPosts = await _loadLocalPosts();
    // TODO: Fetch from backend and merge
    return localPosts;
  }

  /// Like a post
  Future<void> likePost(Post post) async {
    final updatedPost = post.copyWith(likes: post.likes + 1);

    // Update locally
    final currentPosts = await _loadLocalPosts();
    final idx =
        currentPosts.indexWhere((p) => p.id == post.id);
    if (idx >= 0) {
      currentPosts[idx] = updatedPost;
      await _saveLocalPosts(currentPosts);
      _postStreamController.add(updatedPost);
    }

    // Call backend
    try {
      final token = await AuthService.getAuthToken();
      await http.post(
        BackendConfig.uri('/api/posts/like'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {'postId': post.id, 'farmerId': _currentFarmerId},
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  /// Get posts for a specific farmer
  Future<List<Post>> getPostsByFarmer(String farmerId) async {
    final localPosts = await _loadLocalPosts();
    return localPosts.where((post) => post.farmerId == farmerId).toList();
  }

  /// Get all local posts (farmerId parameter not required)
  Future<List<Post>> getPosts() async {
    return await _loadLocalPosts();
  }

  /// Toggle like on a post
  Future<void> toggleLike(Post post) async {
    if (post.isLiked) {
      await unlikePost(post);
    } else {
      await likePost(post);
    }
  }

  /// Unlike a post
  Future<void> unlikePost(Post post) async {
    final updatedPost = post.copyWith(likes: post.likes - 1);

    // Update locally
    final currentPosts = await _loadLocalPosts();
    final idx =
        currentPosts.indexWhere((p) => p.id == post.id);
    if (idx >= 0) {
      currentPosts[idx] = updatedPost;
      await _saveLocalPosts(currentPosts);
      _postStreamController.add(updatedPost);
    }

    // Call backend
    try {
      final token = await AuthService.getAuthToken();
      await http.post(
        BackendConfig.uri('/api/posts/unlike'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {'postId': post.id, 'farmerId': _currentFarmerId},
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  /// Delete a post
  Future<void> deletePost(Post post) async {
    // Remove locally
    final currentPosts = await _loadLocalPosts();
    currentPosts.removeWhere((p) => p.id == post.id);
    await _saveLocalPosts(currentPosts);
    _postStreamController.add(post);

    // Call backend
    try {
      final token = await AuthService.getAuthToken();
      await http.delete(
        BackendConfig.uri('/api/posts/${post.id}'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  /// Add comment to post
  Future<void> addComment(Post post, String comment) async {
    final updatedPost = post.copyWith(comments: post.comments + 1);

    // Update locally
    final currentPosts = await _loadLocalPosts();
    final idx =
        currentPosts.indexWhere((p) => p.id == post.id);
    if (idx >= 0) {
      currentPosts[idx] = updatedPost;
      await _saveLocalPosts(currentPosts);
      _postStreamController.add(updatedPost);
    }

    // Call backend
    try {
      final token = await AuthService.getAuthToken();
      await http.post(
        BackendConfig.uri('/api/posts/comment'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {'postId': post.id, 'comment': comment, 'farmerId': _currentFarmerId},
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  /// Get farmer name from auth
  Future<String> _getFarmerName() async {
    // In production, fetch from user service
    return 'Farmer';
  }
}
