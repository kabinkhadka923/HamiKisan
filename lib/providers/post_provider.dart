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

  Future<bool> createPost(String userId, String userName, String userRole, String content, String? imageUrl, {String postType = 'General', String? district}) async {
    try {
      print('Creating post: userId=$userId, userName=$userName, userRole=$userRole, postType=$postType, district=$district');
      final post = await _postService.createPost(userId, userName, userRole, content, imageUrl, postType: postType, district: district);
      _posts.insert(0, post);
      notifyListeners();
      print('Post created successfully');
      return true;
    } catch (e) {
      print('Error in createPost: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = _posts[postIndex];
    post.isLiked = !post.isLiked;
    post.likes += post.isLiked ? 1 : -1;
    notifyListeners();

    try {
      await _postService.toggleLike(postId);
    } catch (e) {
      post.isLiked = !post.isLiked;
      post.likes += post.isLiked ? 1 : -1;
      notifyListeners();
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      await _postService.deletePost(postId);
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
