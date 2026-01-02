class Post {
  final String id;
  final String authorName;
  final String authorRole;
  final String content;
  final String postType;
  final String? district;
  final String? imagePath;
  final DateTime timestamp;
  int likes;
  int comments;
  int shares;
  bool isLiked;

  Post({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.content,
    required this.postType,
    this.district,
    this.imagePath,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorName': authorName,
        'authorRole': authorRole,
        'content': content,
        'postType': postType,
        'district': district,
        'imagePath': imagePath,
        'timestamp': timestamp.toIso8601String(),
        'likes': likes,
        'comments': comments,
        'shares': shares,
        'isLiked': isLiked,
      };

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'],
        authorName: json['authorName'],
        authorRole: json['authorRole'],
        content: json['content'],
        postType: json['postType'],
        district: json['district'],
        imagePath: json['imagePath'],
        timestamp: DateTime.parse(json['timestamp']),
        likes: json['likes'] ?? 0,
        comments: json['comments'] ?? 0,
        shares: json['shares'] ?? 0,
        isLiked: json['isLiked'] ?? false,
      );

  String get userName => authorName;
  String get userRole => authorRole;
  DateTime get createdAt => timestamp;
}
