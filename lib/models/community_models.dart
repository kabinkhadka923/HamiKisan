import 'package:flutter/foundation.dart';

/// Represents a community group based on geographic location
class CommunityGroup {
  final String id;
  final String name;
  final CommunityGroupType type;
  final String location; // Ward/Municipality/District/Province name
  final String leaderId;
  final String leaderName;
  final String? leaderProfilePicture;
  final int memberCount;
  final DateTime createdAt;
  final bool isActive;

  CommunityGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.leaderId,
    required this.leaderName,
    this.leaderProfilePicture,
    required this.memberCount,
    required this.createdAt,
    this.isActive = true,
  });

  factory CommunityGroup.fromJson(Map<String, dynamic> json) {
    return CommunityGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CommunityGroupType.values.firstWhere(
        (e) => e.toString() == 'CommunityGroupType.${json['type']}',
        orElse: () => CommunityGroupType.ward,
      ),
      location: json['location'] as String,
      leaderId: json['leader_id'] as String,
      leaderName: json['leader_name'] as String,
      leaderProfilePicture: json['leader_profile_picture'] as String?,
      memberCount: json['member_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'location': location,
      'leader_id': leaderId,
      'leader_name': leaderName,
      'leader_profile_picture': leaderProfilePicture,
      'member_count': memberCount,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}

enum CommunityGroupType {
  ward,
  municipality,
  district,
  province,
}

extension CommunityGroupTypeExtension on CommunityGroupType {
  String get displayName {
    switch (this) {
      case CommunityGroupType.ward:
        return 'Ward';
      case CommunityGroupType.municipality:
        return 'Municipality';
      case CommunityGroupType.district:
        return 'District';
      case CommunityGroupType.province:
        return 'Province';
    }
  }

  String get displayNameNepali {
    switch (this) {
      case CommunityGroupType.ward:
        return 'वडा';
      case CommunityGroupType.municipality:
        return 'नगरपालिका';
      case CommunityGroupType.district:
        return 'जिल्ला';
      case CommunityGroupType.province:
        return 'प्रदेश';
    }
  }
}

/// Represents a notice/announcement posted by group leader
class CommunityNotice {
  final String id;
  final String groupId;
  final String title;
  final String content;
  final NoticeType type;
  final String authorId;
  final String authorName;
  final String? authorProfilePicture;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isPinned;
  final List<String> attachments;
  final int viewCount;

  CommunityNotice({
    required this.id,
    required this.groupId,
    required this.title,
    required this.content,
    required this.type,
    required this.authorId,
    required this.authorName,
    this.authorProfilePicture,
    required this.createdAt,
    this.expiresAt,
    this.isPinned = false,
    this.attachments = const [],
    this.viewCount = 0,
  });

  factory CommunityNotice.fromJson(Map<String, dynamic> json) {
    return CommunityNotice(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: NoticeType.values.firstWhere(
        (e) => e.toString() == 'NoticeType.${json['type']}',
        orElse: () => NoticeType.general,
      ),
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      authorProfilePicture: json['author_profile_picture'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      isPinned: json['is_pinned'] as bool? ?? false,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      viewCount: json['view_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'title': title,
      'content': content,
      'type': type.toString().split('.').last,
      'author_id': authorId,
      'author_name': authorName,
      'author_profile_picture': authorProfilePicture,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'is_pinned': isPinned,
      'attachments': attachments,
      'view_count': viewCount,
    };
  }
}

enum NoticeType {
  general,
  subsidy,
  training,
  emergency,
  weather,
  marketPrice,
  program,
}

extension NoticeTypeExtension on NoticeType {
  String get displayName {
    switch (this) {
      case NoticeType.general:
        return 'General';
      case NoticeType.subsidy:
        return 'Subsidy';
      case NoticeType.training:
        return 'Training';
      case NoticeType.emergency:
        return 'Emergency';
      case NoticeType.weather:
        return 'Weather Alert';
      case NoticeType.marketPrice:
        return 'Market Price';
      case NoticeType.program:
        return 'Program';
    }
  }
}

/// Represents market price information posted by group leader
class CommunityMarketPrice {
  final String id;
  final String groupId;
  final String productName;
  final String category; // vegetable, fruit, grain
  final double minPrice;
  final double maxPrice;
  final double avgPrice;
  final String unit; // kg, quintal, etc.
  final String marketLocation;
  final DateTime priceDate;
  final String postedById;
  final String postedByName;
  final DateTime createdAt;

  CommunityMarketPrice({
    required this.id,
    required this.groupId,
    required this.productName,
    required this.category,
    required this.minPrice,
    required this.maxPrice,
    required this.avgPrice,
    required this.unit,
    required this.marketLocation,
    required this.priceDate,
    required this.postedById,
    required this.postedByName,
    required this.createdAt,
  });

  factory CommunityMarketPrice.fromJson(Map<String, dynamic> json) {
    return CommunityMarketPrice(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      productName: json['product_name'] as String,
      category: json['category'] as String,
      minPrice: (json['min_price'] as num).toDouble(),
      maxPrice: (json['max_price'] as num).toDouble(),
      avgPrice: (json['avg_price'] as num).toDouble(),
      unit: json['unit'] as String,
      marketLocation: json['market_location'] as String,
      priceDate: DateTime.parse(json['price_date'] as String),
      postedById: json['posted_by_id'] as String,
      postedByName: json['posted_by_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'product_name': productName,
      'category': category,
      'min_price': minPrice,
      'max_price': maxPrice,
      'avg_price': avgPrice,
      'unit': unit,
      'market_location': marketLocation,
      'price_date': priceDate.toIso8601String(),
      'posted_by_id': postedById,
      'posted_by_name': postedByName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Represents a feedback/request from farmers to group leader
class CommunityFeedback {
  final String id;
  final String groupId;
  final String userId;
  final String userName;
  final String? userProfilePicture;
  final FeedbackType type;
  final String subject;
  final String message;
  final FeedbackStatus status;
  final String? response;
  final String? respondedById;
  final String? respondedByName;
  final DateTime? respondedAt;
  final DateTime createdAt;
  final bool isUrgent;

  CommunityFeedback({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.userName,
    this.userProfilePicture,
    required this.type,
    required this.subject,
    required this.message,
    this.status = FeedbackStatus.pending,
    this.response,
    this.respondedById,
    this.respondedByName,
    this.respondedAt,
    required this.createdAt,
    this.isUrgent = false,
  });

  factory CommunityFeedback.fromJson(Map<String, dynamic> json) {
    return CommunityFeedback(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userProfilePicture: json['user_profile_picture'] as String?,
      type: FeedbackType.values.firstWhere(
        (e) => e.toString() == 'FeedbackType.${json['type']}',
        orElse: () => FeedbackType.general,
      ),
      subject: json['subject'] as String,
      message: json['message'] as String,
      status: FeedbackStatus.values.firstWhere(
        (e) => e.toString() == 'FeedbackStatus.${json['status']}',
        orElse: () => FeedbackStatus.pending,
      ),
      response: json['response'] as String?,
      respondedById: json['responded_by_id'] as String?,
      respondedByName: json['responded_by_name'] as String?,
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      isUrgent: json['is_urgent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'user_name': userName,
      'user_profile_picture': userProfilePicture,
      'type': type.toString().split('.').last,
      'subject': subject,
      'message': message,
      'status': status.toString().split('.').last,
      'response': response,
      'responded_by_id': respondedById,
      'responded_by_name': respondedByName,
      'responded_at': respondedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_urgent': isUrgent,
    };
  }
}

enum FeedbackType {
  general,
  complaint,
  request,
  cropIssue,
  emergency,
  inputNeed,
}

enum FeedbackStatus {
  pending,
  inProgress,
  resolved,
  forwarded,
}

/// Represents a controlled message in the group
class CommunityMessage {
  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String? senderProfilePicture;
  final String message;
  final String? replyToNoticeId;
  final DateTime createdAt;
  final bool isApproved;
  final String? approvedById;

  CommunityMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    this.senderProfilePicture,
    required this.message,
    this.replyToNoticeId,
    required this.createdAt,
    this.isApproved = false,
    this.approvedById,
  });

  factory CommunityMessage.fromJson(Map<String, dynamic> json) {
    return CommunityMessage(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String,
      senderProfilePicture: json['sender_profile_picture'] as String?,
      message: json['message'] as String,
      replyToNoticeId: json['reply_to_notice_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isApproved: json['is_approved'] as bool? ?? false,
      approvedById: json['approved_by_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_profile_picture': senderProfilePicture,
      'message': message,
      'reply_to_notice_id': replyToNoticeId,
      'created_at': createdAt.toIso8601String(),
      'is_approved': isApproved,
      'approved_by_id': approvedById,
    };
  }
}
