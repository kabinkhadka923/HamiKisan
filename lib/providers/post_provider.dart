import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../utils/logger.dart';

class PostProvider with ChangeNotifier {
  final PostService _postService = PostService();
  List<Post> _posts = [];
  final Set<String> _pendingLikes = {};
  bool _isLoading = false;
  String? _error;
  String? _activeUserId;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPosts({String? userId}) async {
    _activeUserId = userId ?? _activeUserId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final posts = await _postService.getAllPosts();
      final activeUserId = _activeUserId;
      final likedIds = activeUserId == null
          ? <String>{}
          : (await SharedPreferences.getInstance())
                  .getStringList('liked_posts_$activeUserId')
                  ?.toSet() ??
              <String>{};
      _posts = posts
          .map((post) => post.copyWith(isLiked: likedIds.contains(post.id)))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost(Post post) async {
    try {
      final createdPost = await _postService.createPost(post);
      _posts.removeWhere((item) => item.id == createdPost.id);
      _posts.insert(0, createdPost.copyWith(isLiked: false));
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1 || userId.isEmpty || _pendingLikes.contains(postId)) {
      return;
    }

    final post = _posts[postIndex];
    final updatedPost = post.copyWith(
      likes: (post.likes + (post.isLiked ? -1 : 1)).clamp(0, 1 << 31).toInt(),
      isLiked: !post.isLiked,
    );
    _pendingLikes.add(postId);
    _posts[postIndex] = updatedPost;
    _activeUserId = userId;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final likedIds = prefs.getStringList('liked_posts_$userId')?.toSet() ?? {};
      if (updatedPost.isLiked) {
        likedIds.add(postId);
      } else {
        likedIds.remove(postId);
      }
      await prefs.setStringList('liked_posts_$userId', likedIds.toList());
      await _postService.toggleLike(post, userId);
    } catch (e) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final likedIds =
            prefs.getStringList('liked_posts_$userId')?.toSet() ?? {};
        if (post.isLiked) {
          likedIds.add(postId);
        } else {
          likedIds.remove(postId);
        }
        await prefs.setStringList('liked_posts_$userId', likedIds.toList());
      } catch (rollbackError) {
        Logger.warning(
          'Could not restore saved post-like state',
          tag: 'Posts',
          data: rollbackError,
        );
      }
      final currentIndex = _posts.indexWhere((item) => item.id == postId);
      if (currentIndex >= 0) _posts[currentIndex] = post;
      _error = e.toString();
      notifyListeners();
    } finally {
      _pendingLikes.remove(postId);
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      final postToDelete = _posts.firstWhere((p) => p.id == postId);
      await _postService.deletePost(postToDelete);
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
