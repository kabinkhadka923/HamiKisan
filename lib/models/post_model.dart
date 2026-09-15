import 'dart:convert';

import '../models/user.dart';

enum PostType { crop_update, price_alert, availability, question, success_story, resource_share }
enum PostStatus { active, archived, sold_out }

class Post {
  final String id;
  final String farmerId;
  final String farmerName;
  final PostType postType;
  final String title;
  final String content;
  final String? mediaUrl;
  final String? imageUrl;
  final List<String> imageUrls;
  final double? price;
  final String? unit;
  final String? cropName;
  final String? location;
  final String? district;
  final PostStatus status;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isOrganic;
  final String? qualityGrade;

  Post({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.postType,
    required this.title,
    required this.content,
    this.mediaUrl,
    this.imageUrl,
    List<String>? imageUrls,
    this.price,
    this.unit,
    this.cropName,
    this.location,
    this.district,
    this.status = PostStatus.active,
    this.likes = 0,
    this.comments = 0,
    required this.createdAt,
    this.updatedAt,
    this.isOrganic = false,
    this.qualityGrade,
  }) : imageUrls = imageUrls ?? [];

  factory Post.fromMap(Map<String, dynamic> map) {
    List<String> imgUrls = [];
    if (map['imageUrls'] != null) {
      imgUrls = List<String>.from(map['imageUrls']);
    } else if (map['imageUrl'] != null) {
      imgUrls = [map['imageUrl']];
    }

    DateTime? created;
    if (map['createdAt'] != null) {
      created = DateTime.parse(map['createdAt']);
    }

    DateTime? updated;
    if (map['updatedAt'] != null) {
      updated = DateTime.parse(map['updatedAt']);
    }

    PostType type;
    try {
      type = PostType.values.firstWhere(
        (t) => t.name == map['postType'],
        orElse: () => PostType.crop_update,
      );
    } catch (_) {
      type = PostType.crop_update;
    }

    PostStatus status;
    try {
      status = PostStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => PostStatus.active,
      );
    } catch (_) {
      status = PostStatus.active;
    }

    return Post(
      id: map['id'] ?? '',
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? 'Unknown Farmer',
      postType: type,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      mediaUrl: map['mediaUrl'],
      imageUrl: map['imageUrl'],
      imageUrls: imgUrls,
      price: (map['price'] as num?)?.toDouble(),
      unit: map['unit'] as String?,
      cropName: map['cropName'] as String?,
      location: map['location'] as String?,
      district: map['district'] as String?,
      status: PostStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => PostStatus.active,
      ),
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      createdAt: created ?? DateTime.now(),
      updatedAt: updated,
      isOrganic: map['isOrganic'] ?? false,
      qualityGrade: map['qualityGrade'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'postType': postType.name,
      'title': title,
      'content': content,
      'mediaUrl': mediaUrl,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'price': price,
      'unit': unit,
      'cropName': cropName,
      'location': location,
      'district': district,
      'status': status.name,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'isOrganic': isOrganic,
      'qualityGrade': qualityGrade,
    };
  }

  Post copyWith({
    String? id,
    String? farmerId,
    String? farmerName,
    PostType? postType,
    String? title,
    String? content,
    String? mediaUrl,
    String? imageUrl,
    List<String>? imageUrls,
    double? price,
    String? unit,
    String? cropName,
    String? location,
    String? district,
    PostStatus? status,
    int? likes,
    int? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOrganic,
    String? qualityGrade,
  }) {
    return Post(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      postType: postType ?? this.postType,
      title: title ?? this.title,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      cropName: cropName ?? this.cropName,
      location: location ?? this.location,
      district: district ?? this.district,
      status: status ?? this.status,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOrganic: isOrganic ?? this.isOrganic,
      qualityGrade: qualityGrade ?? this.qualityGrade,
    );
  }
}
