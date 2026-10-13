import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../models/post_model.dart';
import '../widgets/localized_text.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PostProvider>().loadPosts(
              userId: context.read<AuthProvider>().currentUser?.id,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const LocalizedText('my_posts'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.article_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('please_login'),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _buildPostsList(
              context,
              user.id,
              context.watch<PostProvider>(),
            ),
    );
  }

  Widget _buildPostsList(
    BuildContext context,
    String userId,
    PostProvider provider,
  ) {
    final posts = provider.posts.where((post) => post.farmerId == userId).toList();
    if (provider.isLoading && provider.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null && provider.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: provider.loadPosts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.article_outlined,
                  size: 72, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                context.tr('no_posts_yet'),
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(context.tr('start_sharing'), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _createPost,
                icon: const Icon(Icons.add),
                label: Text(context.tr('create_post')),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) => _buildPostCard(posts[index]),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    final provider = context.watch<PostProvider>();
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
        ),
        title: Text(post.title.isNotEmpty ? post.title : post.content,
            maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${post.postType.name.replaceAll('_', ' ')} · '
          '${post.createdAt.toLocal()}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) async {
            if (action != 'delete') return;
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete post?'),
                content: const Text('This will remove the post from your list.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
            if (confirmed == true && mounted) {
              final deleted = await provider.deletePost(post.id);
              if (!deleted && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.error ?? 'Could not delete post')),
                );
              }
            }
          },
          itemBuilder: (_) => [
            if (post.farmerId == userId)
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
    if (mounted) {
      await context.read<PostProvider>().loadPosts(
            userId: context.read<AuthProvider>().currentUser?.id,
          );
    }
  }
}
