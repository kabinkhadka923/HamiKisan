import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../models/post_model.dart';
import '../providers/auth_provider.dart';
import '../services/post_service.dart';
import '../services/media_service.dart';

class FarmerPostScreen extends StatefulWidget {
  final User farmer;

  const FarmerPostScreen({
    super.key,
    required this.farmer,
  });

  @override
  State<FarmerPostScreen> createState() => _FarmerPostScreenState();
}

class _FarmerPostScreenState extends State<FarmerPostScreen>
    with TickerProviderStateMixin {
  final PostService _postService = PostService();
  final MediaService _mediaService = MediaService();

  StreamSubscription<Post>? _postSub;
  List<Post> _posts = [];

  // State for creating post
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  PostType _selectedType = PostType.crop_update;
  String? _mediaPath;
  bool _isLoading = true;
  bool _isSending = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    _postSub?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    await _postService.initialize(currentUser.id);
    await _loadPosts();

    _postSub = _postService.postStream.listen((post) {
      if (!mounted) return;
      setState(() {
        final index = _posts.indexWhere((item) => item.id == post.id);
        if (index >= 0) {
          _posts[index] = post;
        } else {
          _posts.insert(0, post);
          if (_posts.length > 20) _posts = _posts.sublist(0, 20);
        }
      });
      _scrollToBottom();
    });
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _postService.getAllPosts();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load posts: $e')),
      );
    }
  }

  Widget _buildPostTypeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: PostType.values.map((type) {
          return FilterChip(
            label: Text(_typeLabel(type)),
            selected: _selectedType == type,
            onSelected: (_) => setState(() => _selectedType = type),
            backgroundColor: Colors.grey[200],
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: _selectedType == type ? Colors.white : Colors.black87,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _typeLabel(PostType type) {
    switch (type) {
      case PostType.crop_update:
        return 'Crop Update';
      case PostType.price_alert:
        return 'Price Alert';
      case PostType.availability:
        return 'Availability';
      case PostType.question:
        return 'Question';
      case PostType.success_story:
        return 'Success Story';
      case PostType.resource_share:
        return 'Resource Share';
    }
  }

  Widget _buildPostForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post type selector
          _buildPostTypeSelector(),

          // Title
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Title (optional)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 8.0),

          // Content
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              hintText: 'What would you like to share?',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8.0),

          // Media attachment
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file, size: 20),
                onPressed: _pickMedia,
                tooltip: 'Attach photo',
              ),
              if (_mediaPath != null) ...[
                Expanded(
                  child: Text(
                    'Selected image (upload not configured)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove selected image',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _mediaPath = null),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8.0),

          // Quick fields based on type
          _buildQuickFields(),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSending ? null : _createPost,
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Share Post'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFields() {
    switch (_selectedType) {
      case PostType.price_alert:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price:',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Price per unit',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (val) =>
                  setState(() => _quickPrice = double.tryParse(val) ?? 0),
            ),
            const SizedBox(height: 4),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Unit (kg, bundle, etc.)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) =>
                  setState(() => _quickUnit = val.isNotEmpty ? val : 'kg'),
            ),
          ],
        );
      case PostType.availability:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crop:',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Crop name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) => setState(
                  () => _quickCrop = val.isNotEmpty ? val : 'Tomatoes'),
            ),
            const SizedBox(height: 4),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Quantity available',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) =>
                  setState(() => _quickQuantity = double.tryParse(val) ?? 0),
            ),
          ],
        );
      case PostType.resource_share:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resource:',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            TextField(
              decoration: const InputDecoration(
                hintText: 'What are you sharing?',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) => setState(() => _quickResource = val),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // Quick field controllers
  double _quickPrice = 0;
  String _quickUnit = 'kg';
  String _quickCrop = 'Tomatoes';
  double _quickQuantity = 0;
  String _quickResource = '';

  Future<void> _pickMedia() async {
    final type = await _showMediaTypeDialog();
    if (type == null) return;

    setState(() => _isSending = true);

    try {
      String? result;
      switch (type) {
        case 'image':
          result = await _mediaService.pickImage();
          break;
      }

      if (result != null && mounted) {
        setState(() => _mediaPath = result);
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<String?> _showMediaTypeDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Attach'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Photo'),
              onTap: () => Navigator.of(context).pop('image'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _createPost() async {
    if (_titleController.text.trim().isEmpty &&
        _contentController.text.trim().isEmpty &&
        _mediaPath == null &&
        !(_selectedType == PostType.resource_share &&
            _quickResource.trim().isNotEmpty) &&
        !(_selectedType == PostType.availability && _quickQuantity > 0)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Add a title or message before sharing.')),
        );
      }
      return;
    }
    if (_mediaPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Image uploads are not configured yet. Remove the image to share text only.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final post = Post(
        id: 'post_${DateTime.now().millisecondsSinceEpoch}',
        farmerId: '',
        farmerName: widget.farmer.name,
        postType: _selectedType,
        title: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : _selectedType == PostType.resource_share
                ? _quickResource.trim()
                : '',
        content: _selectedType == PostType.availability && _quickQuantity > 0
            ? [
                _contentController.text.trim(),
                'Quantity available: ${_quickQuantity.toString()}',
              ].where((value) => value.isNotEmpty).join('\n')
            : _contentController.text.trim(),
        price: _selectedType == PostType.price_alert ? _quickPrice : null,
        unit: _selectedType == PostType.price_alert ? _quickUnit : null,
        cropName: _selectedType == PostType.availability ? _quickCrop : null,
        isOrganic: _selectedType == PostType.crop_update,
        qualityGrade: _selectedType == PostType.crop_update ? 'A' : null,
        createdAt: DateTime.now(),
      );

      await _postService.createPost(post);

      // Clear form
      _titleController.clear();
      _contentController.clear();
      setState(() {
        _mediaPath = null;
        _isSending = false;
      });

      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share post: $e')),
        );
      }
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.farmer.name}\'s Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logout handler
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Post composer
                _buildPostForm(),

                // Divider
                const Divider(height: 1, thickness: 1),

                // Posts list
                Expanded(
                  child: _posts.isEmpty
                      ? Center(
                          child: Text(
                            'No posts yet. Share your first crop update!',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8.0),
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            return _buildPost(_posts[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildPost(Post post) {
    final isFromCurrentFarmer =
        post.farmerId == context.read<AuthProvider>().currentUser?.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isFromCurrentFarmer
            ? Theme.of(context).colorScheme.surface
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12.0),
        border: isFromCurrentFarmer
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: Text(
                  post.farmerName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.farmerName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color:
                            isFromCurrentFarmer ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      _formatDate(post.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Content
          const SizedBox(height: 4.0),
          Text(
            post.content,
            style: TextStyle(
              fontSize: 14,
              color: isFromCurrentFarmer ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),

          // Type and fields
          const SizedBox(height: 4.0),
          _postTypeTag(post.postType),
          const SizedBox(height: 4.0),

          // Price/availability info
          if (post.price != null || post.cropName != null) ...[
            _postDetailRow(
              icon: Icons.attach_money,
              label: 'Price',
              value: post.price != null ? '${post.price} ${post.unit}' : '',
            ),
            _postDetailRow(
              icon: Icons.local_florist,
              label: 'Crop',
              value: post.cropName ?? '',
            ),
          ],

          // Actions
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Likes
              Row(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 18,
                    color: post.likes > 0 ? Colors.pink : Colors.grey[400],
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${post.likes}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              // Comments
              Row(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 18,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${post.comments}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _postTypeTag(PostType type) {
    final color = _getTypeColor(type);
    final label = _typeLabel(type).toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getTypeColor(PostType type) {
    switch (type) {
      case PostType.crop_update:
        return Colors.green;
      case PostType.price_alert:
        return Colors.orange;
      case PostType.availability:
        return Colors.blue;
      case PostType.question:
        return Colors.purple;
      case PostType.success_story:
        return Colors.teal;
      case PostType.resource_share:
        return Colors.brown;
    }
  }

  Widget _postDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[800],
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 365) {
      return '${date.year}';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}m ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}min ago';
    } else {
      return 'Just now';
    }
  }
}
