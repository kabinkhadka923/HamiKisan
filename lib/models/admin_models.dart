import 'package:flutter/material.dart';
import 'dart:convert';

// ==================== ENUMS ====================

enum AdminRole {
  kisanAdmin,
  superAdmin,
  systemAdmin;

  factory AdminRole.fromString(String value) {
    switch (value.toLowerCase()) {
      case 'super_admin':
        return AdminRole.superAdmin;
      case 'system_admin':
        return AdminRole.systemAdmin;
      default:
        return AdminRole.kisanAdmin;
    }
  }

  String get displayName {
    switch (this) {
      case AdminRole.kisanAdmin:
        return 'Kisan Admin';
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.systemAdmin:
        return 'System Admin';
    }
  }

  String get databaseValue {
    switch (this) {
      case AdminRole.kisanAdmin:
        return 'kisan_admin';
      case AdminRole.superAdmin:
        return 'super_admin';
      case AdminRole.systemAdmin:
        return 'system_admin';
    }
  }
}

enum NotificationType {
  alert,
  warning,
  info,
  success,
  critical;

  factory NotificationType.fromString(String value) {
    switch (value.toLowerCase()) {
      case 'alert':
        return NotificationType.alert;
      case 'warning':
        return NotificationType.warning;
      case 'success':
        return NotificationType.success;
      case 'critical':
        return NotificationType.critical;
      default:
        return NotificationType.info;
    }
  }

  String get databaseValue {
    switch (this) {
      case NotificationType.alert:
        return 'alert';
      case NotificationType.warning:
        return 'warning';
      case NotificationType.info:
        return 'info';
      case NotificationType.success:
        return 'success';
      case NotificationType.critical:
        return 'critical';
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.alert:
        return Colors.orange;
      case NotificationType.warning:
        return Colors.amber;
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.critical:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.alert:
        return Icons.notification_important;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.critical:
        return Icons.error;
    }
  }
}

enum FarmerStatus {
  pending,
  approved,
  rejected,
  banned,
  suspended,
  inactive;

  factory FarmerStatus.fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return FarmerStatus.pending;
      case 'approved':
        return FarmerStatus.approved;
      case 'rejected':
        return FarmerStatus.rejected;
      case 'banned':
        return FarmerStatus.banned;
      case 'suspended':
        return FarmerStatus.suspended;
      case 'inactive':
        return FarmerStatus.inactive;
      default:
        return FarmerStatus.pending;
    }
  }

  String get databaseValue {
    switch (this) {
      case FarmerStatus.pending:
        return 'pending';
      case FarmerStatus.approved:
        return 'approved';
      case FarmerStatus.rejected:
        return 'rejected';
      case FarmerStatus.banned:
        return 'banned';
      case FarmerStatus.suspended:
        return 'suspended';
      case FarmerStatus.inactive:
        return 'inactive';
    }
  }

  String get displayName {
    switch (this) {
      case FarmerStatus.pending:
        return 'Pending';
      case FarmerStatus.approved:
        return 'Approved';
      case FarmerStatus.rejected:
        return 'Rejected';
      case FarmerStatus.banned:
        return 'Banned';
      case FarmerStatus.suspended:
        return 'Suspended';
      case FarmerStatus.inactive:
        return 'Inactive';
    }
  }

  Color get color {
    switch (this) {
      case FarmerStatus.pending:
        return Colors.orange;
      case FarmerStatus.approved:
        return Colors.green;
      case FarmerStatus.rejected:
        return Colors.red;
      case FarmerStatus.banned:
        return Colors.red[900]!;
      case FarmerStatus.suspended:
        return Colors.amber;
      case FarmerStatus.inactive:
        return Colors.grey;
    }
  }
}

enum ProductStatus {
  pending,
  approved,
  rejected,
  sold,
  expired;

  factory ProductStatus.fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return ProductStatus.pending;
      case 'approved':
        return ProductStatus.approved;
      case 'rejected':
        return ProductStatus.rejected;
      case 'sold':
        return ProductStatus.sold;
      case 'expired':
        return ProductStatus.expired;
      default:
        return ProductStatus.pending;
    }
  }

  String get databaseValue {
    switch (this) {
      case ProductStatus.pending:
        return 'pending';
      case ProductStatus.approved:
        return 'approved';
      case ProductStatus.rejected:
        return 'rejected';
      case ProductStatus.sold:
        return 'sold';
      case ProductStatus.expired:
        return 'expired';
    }
  }
}

enum PostStatus {
  pending,
  approved,
  rejected,
  deleted,
  flagged;

  factory PostStatus.fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return PostStatus.pending;
      case 'approved':
        return PostStatus.approved;
      case 'rejected':
        return PostStatus.rejected;
      case 'deleted':
        return PostStatus.deleted;
      case 'flagged':
        return PostStatus.flagged;
      default:
        return PostStatus.pending;
    }
  }
}

enum MarketTrend {
  up,
  down,
  stable,
  volatile;

  factory MarketTrend.fromString(String value) {
    switch (value.toLowerCase()) {
      case 'up':
        return MarketTrend.up;
      case 'down':
        return MarketTrend.down;
      case 'volatile':
        return MarketTrend.volatile;
      default:
        return MarketTrend.stable;
    }
  }

  Color get color {
    switch (this) {
      case MarketTrend.up:
        return Colors.green;
      case MarketTrend.down:
        return Colors.red;
      case MarketTrend.stable:
        return Colors.blue;
      case MarketTrend.volatile:
        return Colors.orange;
    }
  }

  IconData get icon {
    switch (this) {
      case MarketTrend.up:
        return Icons.arrow_upward;
      case MarketTrend.down:
        return Icons.arrow_downward;
      case MarketTrend.stable:
        return Icons.remove;
      case MarketTrend.volatile:
        return Icons.sync;
    }
  }
}

class AuditLog {
  final String id;
  final String adminId;
  final String adminName;
  final String action;
  final String targetId;
  final Map<String, dynamic> details;
  final DateTime timestamp;
  final String ipAddress;

  AuditLog({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.action,
    required this.targetId,
    required this.details,
    required this.timestamp,
    required this.ipAddress,
  });

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'] as String,
      adminId: map['admin_id'] as String,
      adminName: map['admin_name'] as String,
      action: map['action'] as String,
      targetId: map['target_id'] as String,
      details: map['details'] != null
          ? Map<String, dynamic>.from(map['details'])
          : {},
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      ipAddress: map['ip_address'] as String? ?? '',
    );
  }
}

class PaginatedResult<T> {
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  PaginatedResult({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });
}

// ==================== MODELS ====================

class AdminUser {
  final String id;
  final String name;
  final String email;
  final AdminRole role;
  final List<String> permissions;
  final DateTime lastLogin;
  final DateTime? createdAt;
  final String? avatarUrl;
  final bool isActive;
  final String? phoneNumber;
  final List<String>? assignedDistricts;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    required this.lastLogin,
    this.createdAt,
    this.avatarUrl,
    this.isActive = true,
    this.phoneNumber,
    this.assignedDistricts,
  });

  factory AdminUser.fromMap(Map<String, dynamic> map) {
    return AdminUser(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: AdminRole.fromString(map['role'] as String? ?? 'kisan_admin'),
      permissions: _parseList(map['permissions'] as String?),
      lastLogin: DateTime.fromMillisecondsSinceEpoch(
          map['last_login_at'] as int? ?? 0),
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
      avatarUrl: map['avatar_url'] as String?,
      isActive: (map['is_active'] ?? 1) == 1,
      phoneNumber: map['phone_number'] as String?,
      assignedDistricts: map['assigned_districts'] != null
          ? (map['assigned_districts'] as String).split(',')
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.databaseValue,
      'permissions': permissions.join(','),
      'last_login_at': lastLogin.millisecondsSinceEpoch,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'avatar_url': avatarUrl,
      'is_active': isActive ? 1 : 0,
      'phone_number': phoneNumber,
      'assigned_districts': assignedDistricts?.join(','),
    };
  }

  AdminUser copyWith({
    String? id,
    String? name,
    String? email,
    AdminRole? role,
    List<String>? permissions,
    DateTime? lastLogin,
    DateTime? createdAt,
    String? avatarUrl,
    bool? isActive,
    String? phoneNumber,
    List<String>? assignedDistricts,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      assignedDistricts: assignedDistricts ?? this.assignedDistricts,
    );
  }
}

class AdminDashboardMetrics {
  final int totalFarmers;
  final int activeFarmersToday;
  final int registeredDoctors;
  final int submittedProblems;
  final int marketplaceListings;
  final int soldItemsToday;
  final int pendingApprovals;
  final double revenueToday;
  final String weatherApiStatus;
  final String systemHealthStatus;
  final DateTime lastUpdated;

  AdminDashboardMetrics({
    required this.totalFarmers,
    required this.activeFarmersToday,
    required this.registeredDoctors,
    required this.submittedProblems,
    required this.marketplaceListings,
    required this.soldItemsToday,
    required this.pendingApprovals,
    required this.revenueToday,
    required this.weatherApiStatus,
    required this.systemHealthStatus,
    required this.lastUpdated,
  });

  factory AdminDashboardMetrics.fromMap(Map<String, dynamic> map) {
    return AdminDashboardMetrics(
      totalFarmers: map['total_farmers'] as int? ?? 0,
      activeFarmersToday: map['active_farmers_today'] as int? ?? 0,
      registeredDoctors: map['registered_doctors'] as int? ?? 0,
      submittedProblems: map['submitted_problems'] as int? ?? 0,
      marketplaceListings: map['marketplace_listings'] as int? ?? 0,
      soldItemsToday: map['sold_items_today'] as int? ?? 0,
      pendingApprovals: map['pending_approvals'] as int? ?? 0,
      revenueToday: (map['revenue_today'] as num?)?.toDouble() ?? 0.0,
      weatherApiStatus: map['weather_api_status'] as String? ?? 'Unknown',
      systemHealthStatus: map['system_health_status'] as String? ?? 'Unknown',
      lastUpdated: map['last_updated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_updated'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total_farmers': totalFarmers,
      'active_farmers_today': activeFarmersToday,
      'registered_doctors': registeredDoctors,
      'submitted_problems': submittedProblems,
      'marketplace_listings': marketplaceListings,
      'sold_items_today': soldItemsToday,
      'pending_approvals': pendingApprovals,
      'revenue_today': revenueToday,
      'weather_api_status': weatherApiStatus,
      'system_health_status': systemHealthStatus,
      'last_updated': lastUpdated.millisecondsSinceEpoch,
    };
  }
}

class FarmerProfile {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String district;
  final String province;
  final String? localLevel;
  final String? wardNumber;
  final List<String> crops;
  final List<String> farmingCategories;
  final String? kisanId;
  final double? landArea;
  final String? landAreaUnit;
  final DateTime lastLogin;
  final DateTime registeredAt;
  final FarmerStatus status;
  final bool isVerified;
  final List<String> productsPosted;
  final List<String> complaintsSubmitted;
  final int totalPosts;
  final int totalProducts;
  final double? rating;
  final String? profileImage;
  final String? address;
  final String? bio;
  final DateTime? approvedAt;

  FarmerProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.district,
    required this.province,
    this.localLevel,
    this.wardNumber,
    required this.crops,
    required this.farmingCategories,
    this.kisanId,
    this.landArea,
    this.landAreaUnit,
    required this.lastLogin,
    required this.registeredAt,
    required this.status,
    required this.isVerified,
    required this.productsPosted,
    required this.complaintsSubmitted,
    this.totalPosts = 0,
    this.totalProducts = 0,
    this.rating,
    this.profileImage,
    this.address,
    this.bio,
    this.approvedAt,
  });

  factory FarmerProfile.fromMap(Map<String, dynamic> map) {
    return FarmerProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone_number'] as String? ?? '',
      email: map['email'] as String? ?? '',
      district: _extractDistrict(map['address'] as String?),
      province: _extractProvince(map['address'] as String?),
      localLevel: _extractLocalLevel(map['address'] as String?),
      wardNumber: _extractWardNumber(map['address'] as String?),
      crops: _parseList(map['crops'] as String?),
      farmingCategories: _parseList(map['farming_category'] as String?),
      kisanId: map['kisan_id'] as String?,
      landArea: (map['land_area'] as num?)?.toDouble(),
      landAreaUnit: map['land_area_unit'] as String?,
      lastLogin: DateTime.fromMillisecondsSinceEpoch(
          map['last_login_at'] as int? ?? 0),
      registeredAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int? ?? 0),
      status: FarmerStatus.fromString(map['status'] as String? ?? 'pending'),
      isVerified: (map['is_verified'] ?? 0) == 1,
      productsPosted: _parseList(map['products_posted'] as String?),
      complaintsSubmitted: _parseList(map['complaints_submitted'] as String?),
      totalPosts: map['total_posts'] as int? ?? 0,
      totalProducts: map['total_products'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble(),
      profileImage: map['profile_image'] as String?,
      address: map['address'] as String?,
      bio: map['bio'] as String?,
      approvedAt: map['approved_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['approved_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone_number': phone,
      'email': email,
      'address': address,
      'crops': crops.join(','),
      'farming_category': farmingCategories.join(','),
      'kisan_id': kisanId,
      'land_area': landArea,
      'land_area_unit': landAreaUnit,
      'last_login_at': lastLogin.millisecondsSinceEpoch,
      'created_at': registeredAt.millisecondsSinceEpoch,
      'status': status.databaseValue,
      'is_verified': isVerified ? 1 : 0,
      'products_posted': productsPosted.join(','),
      'complaints_submitted': complaintsSubmitted.join(','),
      'total_posts': totalPosts,
      'total_products': totalProducts,
      'rating': rating,
      'profile_image': profileImage,
      'bio': bio,
      'approved_at': approvedAt?.millisecondsSinceEpoch,
    };
  }

  FarmerProfile copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? district,
    String? province,
    String? localLevel,
    String? wardNumber,
    List<String>? crops,
    List<String>? farmingCategories,
    String? kisanId,
    double? landArea,
    String? landAreaUnit,
    DateTime? lastLogin,
    DateTime? registeredAt,
    FarmerStatus? status,
    bool? isVerified,
    List<String>? productsPosted,
    List<String>? complaintsSubmitted,
    int? totalPosts,
    int? totalProducts,
    double? rating,
    String? profileImage,
    String? address,
    String? bio,
    DateTime? approvedAt,
  }) {
    return FarmerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      district: district ?? this.district,
      province: province ?? this.province,
      localLevel: localLevel ?? this.localLevel,
      wardNumber: wardNumber ?? this.wardNumber,
      crops: crops ?? this.crops,
      farmingCategories: farmingCategories ?? this.farmingCategories,
      kisanId: kisanId ?? this.kisanId,
      landArea: landArea ?? this.landArea,
      landAreaUnit: landAreaUnit ?? this.landAreaUnit,
      lastLogin: lastLogin ?? this.lastLogin,
      registeredAt: registeredAt ?? this.registeredAt,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      productsPosted: productsPosted ?? this.productsPosted,
      complaintsSubmitted: complaintsSubmitted ?? this.complaintsSubmitted,
      totalPosts: totalPosts ?? this.totalPosts,
      totalProducts: totalProducts ?? this.totalProducts,
      rating: rating ?? this.rating,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}

class KisanDoctorProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String qualification;
  final String expertise;
  final List<String> specializations;
  final List<String> assignedDistricts;
  final List<String> languages;
  final bool isOnline;
  final double rating;
  final int answersGiven;
  final int farmerSatisfactionScore;
  final int pendingReplies;
  final DateTime lastActive;
  final DateTime registeredAt;
  final bool isVerified;
  final String? licenseNumber;
  final String? licenseAuthority;
  final DateTime? licenseExpiry;
  final int yearsOfExperience;
  final String? profileImage;
  final String? bio;
  final List<String>? certificates;

  KisanDoctorProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.qualification,
    required this.expertise,
    required this.specializations,
    required this.assignedDistricts,
    required this.languages,
    required this.isOnline,
    required this.rating,
    required this.answersGiven,
    required this.farmerSatisfactionScore,
    required this.pendingReplies,
    required this.lastActive,
    required this.registeredAt,
    required this.isVerified,
    this.licenseNumber,
    this.licenseAuthority,
    this.licenseExpiry,
    this.yearsOfExperience = 0,
    this.profileImage,
    this.bio,
    this.certificates,
  });

  factory KisanDoctorProfile.fromMap(Map<String, dynamic> map) {
    return KisanDoctorProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String? ?? '',
      phone: map['phone_number'] as String? ?? '',
      qualification: map['qualification'] as String? ?? 'Certified',
      expertise: map['expertise'] as String? ?? 'General',
      specializations: _parseList(map['specializations'] as String?),
      assignedDistricts: _parseList(map['assigned_districts'] as String?),
      languages: _parseList(map['languages'] as String?),
      isOnline: (map['is_online'] ?? 0) == 1,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      answersGiven: map['answers_given'] as int? ?? 0,
      farmerSatisfactionScore: map['farmer_satisfaction_score'] as int? ?? 0,
      pendingReplies: map['pending_replies'] as int? ?? 0,
      lastActive: DateTime.fromMillisecondsSinceEpoch(
          map['last_active_at'] as int? ?? 0),
      registeredAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int? ?? 0),
      isVerified: (map['is_verified'] ?? 0) == 1,
      licenseNumber: map['license_number'] as String?,
      licenseAuthority: map['license_authority'] as String?,
      licenseExpiry: map['license_expiry'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['license_expiry'] as int)
          : null,
      yearsOfExperience: map['years_of_experience'] as int? ?? 0,
      profileImage: map['profile_image'] as String?,
      bio: map['bio'] as String?,
      certificates: _parseList(map['certificates'] as String?),
    );
  }
}

class MarketplaceProduct {
  final String id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double? originalPrice;
  final String unit;
  final String image;
  final List<String>? images;
  final String status;
  final DateTime postedDate;
  final String farmerId;
  final String farmerName;
  final String? district;
  final bool isVerified;
  final int views;

  MarketplaceProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.unit,
    required this.image,
    this.images,
    required this.status,
    required this.postedDate,
    required this.farmerId,
    required this.farmerName,
    this.district,
    this.isVerified = false,
    this.views = 0,
  });

  factory MarketplaceProduct.fromMap(Map<String, dynamic> map) {
    return MarketplaceProduct(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      unit: map['unit'] as String,
      image: map['image'] as String? ?? '',
      status: map['status'] as String,
      postedDate:
          DateTime.fromMillisecondsSinceEpoch(map['posted_date'] as int),
      farmerId: map['farmer_id'] as String,
      farmerName: map['farmer_name'] as String? ?? 'Unknown',
      district: map['district'] as String?,
      isVerified: (map['is_verified'] ?? 0) == 1,
      views: map['views'] as int? ?? 0,
    );
  }
}

class SystemAudit {
  final String id;
  final String module;
  final String action;
  final String performedBy;
  final String userRole;
  final DateTime performedAt;
  final Map<String, dynamic>? changes;
  final String? ipAddress;
  final String? userAgent;
  final bool isSuccess;
  final String? errorMessage;
  final int? processingTimeMs;

  SystemAudit({
    required this.id,
    required this.module,
    required this.action,
    required this.performedBy,
    required this.userRole,
    required this.performedAt,
    this.changes,
    this.ipAddress,
    this.userAgent,
    this.isSuccess = true,
    this.errorMessage,
    this.processingTimeMs,
  });

  factory SystemAudit.fromMap(Map<String, dynamic> map) {
    return SystemAudit(
      id: map['id'] as String,
      module: map['module'] as String,
      action: map['action'] as String,
      performedBy: map['performed_by'] as String,
      userRole: map['user_role'] as String? ?? '',
      performedAt:
          DateTime.fromMillisecondsSinceEpoch(map['performed_at'] as int? ?? 0),
      changes: map['changes'] != null
          ? Map<String, dynamic>.from(json.decode(map['changes'] as String))
          : null,
      ipAddress: map['ip_address'] as String?,
      userAgent: map['user_agent'] as String?,
      isSuccess: (map['is_success'] ?? 1) == 1,
      errorMessage: map['error_message'] as String?,
      processingTimeMs: map['processing_time_ms'] as int?,
    );
  }
}

class AdminNotification {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final String receiverId;
  final bool isRead;
  final String type;

  AdminNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.receiverId,
    required this.isRead,
    required this.type,
  });

  factory AdminNotification.fromMap(Map<String, dynamic> map) {
    return AdminNotification(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      receiverId: map['receiver_id'] as String? ?? 'all',
      isRead: (map['is_read'] ?? 0) == 1,
      type: map['type'] as String? ?? 'info',
    );
  }
}

class SecurityLog {
  final String id;
  final String adminId;
  final String action;
  final String ipAddress;
  final DateTime timestamp;
  final String details;

  SecurityLog({
    required this.id,
    required this.adminId,
    required this.action,
    required this.ipAddress,
    required this.timestamp,
    required this.details,
  });

  factory SecurityLog.fromMap(Map<String, dynamic> map) {
    return SecurityLog(
      id: map['id'] as String,
      adminId: map['admin_id'] as String,
      action: map['action'] as String,
      ipAddress: map['ip_address'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      details: map['details'] as String? ?? '',
    );
  }
}

class CommunityPost {
  final String id;
  final String farmerId;
  final String content;
  final List<String> images;
  final DateTime postedDate;
  final int likes;
  final int comments;
  final String status;

  CommunityPost({
    required this.id,
    required this.farmerId,
    required this.content,
    required this.images,
    required this.postedDate,
    required this.likes,
    required this.comments,
    required this.status,
  });

  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    return CommunityPost(
      id: map['id'] as String,
      farmerId: map['farmer_id'] as String,
      content: map['content'] as String,
      images: map['images'] != null ? (map['images'] as String).split(',') : [],
      postedDate:
          DateTime.fromMillisecondsSinceEpoch(map['posted_date'] as int? ?? 0),
      likes: map['likes'] as int? ?? 0,
      comments: map['comments'] as int? ?? 0,
      status: map['status'] as String? ?? 'pending',
    );
  }
}

class HotMarketItem {
  final String productName;
  final double avgPrice;
  final double priceChangePercent;
  final double profitabilityScore;
  final String location;

  HotMarketItem({
    required this.productName,
    required this.avgPrice,
    required this.priceChangePercent,
    required this.profitabilityScore,
    required this.location,
  });
}

class MarketPrice {
  final String id;
  final String item;
  final double todayPrice;
  final double previousWeekPrice;
  final String trend;
  final String district;
  final DateTime updatedAt;

  MarketPrice({
    required this.id,
    required this.item,
    required this.todayPrice,
    required this.previousWeekPrice,
    required this.trend,
    required this.district,
    required this.updatedAt,
  });

  factory MarketPrice.fromMap(Map<String, dynamic> map) {
    return MarketPrice(
      id: map['id'] as String,
      item: map['item'] as String,
      todayPrice: (map['today_price'] as num).toDouble(),
      previousWeekPrice: (map['previous_week_price'] as num).toDouble(),
      trend: map['trend'] as String? ?? 'stable',
      district: map['district'] as String,
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int? ?? 0),
    );
  }
}

// Helper Functions
List<String> _parseList(String? input) {
  if (input == null || input.isEmpty) return [];
  return input
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

String _extractDistrict(String? address) {
  if (address == null || address.isEmpty) return 'Unknown';
  final districts = [
    'Kathmandu',
    'Lalitpur',
    'Bhaktapur',
    'Pokhara',
    'Chitwan',
    'Biratnagar',
    'Butwal',
    'Bharatpur',
    'Dharan',
    'Hetauda',
    'Janakpur',
    'Itahari'
  ];
  for (var district in districts) {
    if (address.toLowerCase().contains(district.toLowerCase())) {
      return district;
    }
  }
  final parts = address.split(',').map((part) => part.trim()).toList();
  if (parts.length > 1) {
    return parts.last;
  }
  return address;
}

String _extractProvince(String? address) {
  if (address == null || address.isEmpty) return 'Unknown';
  final provinces = {
    'Bagmati': ['kathmandu', 'lalitpur', 'bhaktapur', 'chitwan'],
    'Gandaki': ['pokhara', 'kaski'],
    'Province 1': ['biratnagar', 'dharan', 'itahari'],
    'Lumbini': ['butwal', 'rupandehi'],
  };
  final addressLower = address.toLowerCase();
  for (var province in provinces.keys) {
    for (var city in provinces[province]!) {
      if (addressLower.contains(city)) {
        return province;
      }
    }
  }
  return 'Unknown';
}

String? _extractLocalLevel(String? address) {
  return null;
}

String? _extractWardNumber(String? address) {
  if (address == null) return null;
  final wardRegex = RegExp(r'ward\s*(\d+)', caseSensitive: false);
  final match = wardRegex.firstMatch(address);
  return match?.group(1);
}
