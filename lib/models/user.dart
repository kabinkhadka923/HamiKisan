import 'package:json_annotation/json_annotation.dart';

// Temporary manual implementation until build_runner generates the files
Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'name': instance.name,
      'profilePicture': instance.profilePicture,
      'role': instance.role.name,
      'status': instance.status.name,
      'address': instance.address,
      'language': instance.language,
      'farmingCategory': instance.farmingCategory,
      'specialization': instance.specialization,
      'permissions': instance.permissions,
      'createdAt': instance.createdAt.millisecondsSinceEpoch,
      'lastLoginAt': instance.lastLoginAt?.millisecondsSinceEpoch,
      'isVerified': instance.isVerified,
      'hasSelectedLanguage': instance.hasSelectedLanguage,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      name: json['name'] as String? ?? '',
      profilePicture: json['profilePicture'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.farmer,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UserStatus.pending,
      ),
      address: json['address'] as String?,
      language: json['language'] as String?,
      farmingCategory: json['farmingCategory'] as String?,
      specialization: json['specialization'] as String?,
      permissions: (json['permissions'] as List<dynamic>?)?.cast<String>(),
      createdAt: json['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(json['lastLoginAt'] as int),
      isVerified: json['isVerified'] as bool? ?? false,
      hasSelectedLanguage: json['hasSelectedLanguage'] as bool? ?? false,
    );

enum UserRole {
  @JsonValue('farmer')
  farmer,
  @JsonValue('kisan_doctor')
  kisanDoctor,
  @JsonValue('kisan_admin')
  kisanAdmin,
  @JsonValue('super_admin')
  superAdmin,
}

enum UserStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('suspended')
  suspended,
}

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String? phoneNumber;
  final String name;
  final String? profilePicture;
  final UserRole role;
  final UserStatus status;
  final String? address;
  final String? language;
  final String? farmingCategory;
  final String? specialization; // For doctors
  final List<String>? permissions;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isVerified;
  final bool hasSelectedLanguage;

  const User({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.name,
    this.profilePicture,
    required this.role,
    required this.status,
    this.address,
    this.language,
    this.farmingCategory,
    this.specialization,
    this.permissions,
    required this.createdAt,
    this.lastLoginAt,
    this.isVerified = false,
    this.hasSelectedLanguage = false,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Utility methods
  bool get canAccessAdminFeatures => role == UserRole.kisanAdmin || role == UserRole.superAdmin;
  bool get canAccessDoctorFeatures => role == UserRole.kisanDoctor || role == UserRole.superAdmin;
  bool get isFarmer => role == UserRole.farmer;
  bool get isActive => status == UserStatus.approved;

  User copyWith({
    String? name,
    String? profilePicture,
    UserStatus? status,
    DateTime? lastLoginAt,
    bool? isVerified,
    bool? hasSelectedLanguage,
    String? address,
    String? language,
    String? farmingCategory,
    String? specialization,
    List<String>? permissions,
  }) {
    return User(
      id: id,
      email: email,
      phoneNumber: phoneNumber,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role,
      status: status ?? this.status,
      address: address ?? this.address,
      language: language ?? this.language,
      farmingCategory: farmingCategory ?? this.farmingCategory,
      specialization: specialization ?? this.specialization,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isVerified: isVerified ?? this.isVerified,
      hasSelectedLanguage: hasSelectedLanguage ?? this.hasSelectedLanguage,
    );
  }

  // Preference management methods
  Future<void> loadPreferences() async {
    // Implementation for loading user preferences
    // This would load user settings from local storage
  }

  Future<void> setupDefaultPreferences() async {
    // Setup default user preferences based on role
    // This would set up default settings for new users
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, role: $role, status: $status}';
  }
}

// Helper extension for role-based UI
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.farmer:
        return 'Farmer / किसान';
      case UserRole.kisanDoctor:
        return 'Agriculture Expert / कृषि विशेषज्ञ';
      case UserRole.kisanAdmin:
        return 'Admin / प्रशासक';
      case UserRole.superAdmin:
        return 'Super Admin / मुख्य प्रशासक';
    }
  }

  String get description {
    switch (this) {
      case UserRole.farmer:
        return 'Access farming tools and expert advice';
      case UserRole.kisanDoctor:
        return 'Provide expert guidance to farmers';
      case UserRole.kisanAdmin:
        return 'Manage local farming community';
      case UserRole.superAdmin:
        return 'Full system administration';
    }
  }
}
