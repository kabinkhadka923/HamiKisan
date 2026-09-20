import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class PostProvider with ChangeNotifier {
  final PostService _postService = PostService();
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _postService.getPosts();
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
      _posts.insert(0, createdPost);
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
    if (postIndex == -1) return;

    final post = _posts[postIndex];
    // Toggle like: if likes > 0, already liked; otherwise like it
    final updatedPost = post.copyWith(
      likes: post.likes > 0 ? post.likes - 1 : 1,
    );
    _posts[postIndex] = updatedPost;
    notifyListeners();

    try {
      await _postService.toggleLike(updatedPost);
    } catch (e) {
      final revertPost = _posts[postIndex].copyWith(
        likes: updatedPost.likes,
      );
      _posts[postIndex] = revertPost;
      notifyListeners();
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
      return false;
    }
  }
}
