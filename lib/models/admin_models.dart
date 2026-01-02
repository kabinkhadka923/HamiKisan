
enum AdminRole { kisanAdmin, superAdmin }

enum NotificationType { alert, warning, info, success }

class AdminDashboardMetrics {
  final int totalFarmers;
  final int activeFarmersToday;
  final int registeredDoctors;
  final int submittedProblems;
  final int marketplaceListings;
  final int soldItemsToday;
  final String weatherApiStatus;
  final String systemHealthStatus;

  AdminDashboardMetrics({
    required this.totalFarmers,
    required this.activeFarmersToday,
    required this.registeredDoctors,
    required this.submittedProblems,
    required this.marketplaceListings,
    required this.soldItemsToday,
    required this.weatherApiStatus,
    required this.systemHealthStatus,
  });
}

class FarmerProfile {
  final String id;
  final String name;
  final String phone;
  final String district;
  final List<String> crops;
  final DateTime lastLogin;
  final bool isVerified;
  final String accountStatus;
  final List<String> productsPosted;
  final List<String> complaintsSubmitted;

  FarmerProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.district,
    required this.crops,
    required this.lastLogin,
    required this.isVerified,
    required this.accountStatus,
    required this.productsPosted,
    required this.complaintsSubmitted,
  });
}

class KisanDoctorProfile {
  final String id;
  final String name;
  final String qualification;
  final String expertise;
  final List<String> assignedDistricts;
  final List<String> languages;
  final bool isOnline;
  final double rating;
  final int answersGiven;
  final int farmerSatisfactionScore;
  final int pendingReplies;

  KisanDoctorProfile({
    required this.id,
    required this.name,
    required this.qualification,
    required this.expertise,
    required this.assignedDistricts,
    required this.languages,
    required this.isOnline,
    required this.rating,
    required this.answersGiven,
    required this.farmerSatisfactionScore,
    required this.pendingReplies,
  });
}

class MarketplaceProduct {
  final String id;
  final String title;
  final String category;
  final double price;
  final String location;
  final String image;
  final String status;
  final DateTime postedDate;
  final String farmerId;

  MarketplaceProduct({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.location,
    required this.image,
    required this.status,
    required this.postedDate,
    required this.farmerId,
  });
}

class MarketPrice {
  final String item;
  final double todayPrice;
  final double previousWeekPrice;
  final String trend;
  final String district;

  MarketPrice({
    required this.item,
    required this.todayPrice,
    required this.previousWeekPrice,
    required this.trend,
    required this.district,
  });
}

class AdminNotification {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  final String receiverId;
  final bool isRead;
  final NotificationType type;

  AdminNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.receiverId,
    required this.isRead,
    required this.type,
  });
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
}
