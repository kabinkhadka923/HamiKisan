import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';

class PostService {
  static const String _postsKey = 'community_posts';
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> addPost(Post post) async {
    await initialize();
    final posts = await getAllPosts();
    posts.insert(0, post);
    await _savePosts(posts);
  }

  Future<Post> createPost(String userId, String userName, String userRole, String content, String? imagePath, {String postType = 'General', String? district}) async {
    await initialize();
    final postId = DateTime.now().millisecondsSinceEpoch.toString();
    final post = Post(
      id: postId,
      authorName: userName,
      authorRole: userRole,
      content: content,
      postType: postType,
      district: district,
      imagePath: imagePath,
      timestamp: DateTime.now(),
      likes: 0,
      comments: 0,
      shares: 0,
      isLiked: false,
    );
    await addPost(post);
    return post;
  }

  Future<List<Post>> getPosts() async {
    return await getAllPosts();
  }

  Future<List<Post>> getAllPosts() async {
    await initialize();
    final jsonString = _prefs!.getString(_postsKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Post.fromJson(json)).toList();
  }

  Future<List<Post>> getPostsByDistrict(String district) async {
    final posts = await getAllPosts();
    return posts.where((p) => p.district == district).toList();
  }

  Future<void> deletePost(String postId) async {
    final posts = await getAllPosts();
    posts.removeWhere((p) => p.id == postId);
    await _savePosts(posts);
  }

  Future<void> toggleLike(String postId) async {
    final posts = await getAllPosts();
    final index = posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      posts[index].isLiked = !posts[index].isLiked;
      posts[index].likes += posts[index].isLiked ? 1 : -1;
      await _savePosts(posts);
    }
  }

  Future<void> _savePosts(List<Post> posts) async {
    final jsonString = json.encode(posts.map((p) => p.toJson()).toList());
    await _prefs!.setString(_postsKey, jsonString);
  }
}
