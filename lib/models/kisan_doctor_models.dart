import 'package:json_annotation/json_annotation.dart';

// ============= CASE MODEL =============
class Case {
  final String caseId;
  final String farmerId;
  final String doctorId;
  final String cropType;
  final String problemDescription;
  final List<String>? imageUrls;
  final List<String>? voiceNoteUrls;
  final CaseStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? solution;
  final String? medicineRecommendation;
  final String? fertilizerRecommendation;

  Case({
    required this.caseId,
    required this.farmerId,
    required this.doctorId,
    required this.cropType,
    required this.problemDescription,
    this.imageUrls,
    this.voiceNoteUrls,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.solution,
    this.medicineRecommendation,
    this.fertilizerRecommendation,
  });

  factory Case.fromJson(Map<String, dynamic> json) => Case(
    caseId: json['caseId'] as String,
    farmerId: json['farmerId'] as String,
    doctorId: json['doctorId'] as String,
    cropType: json['cropType'] as String,
    problemDescription: json['problemDescription'] as String,
    imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>(),
    voiceNoteUrls: (json['voiceNoteUrls'] as List<dynamic>?)?.cast<String>(),
    status: CaseStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => CaseStatus.new_,
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    solution: json['solution'] as String?,
    medicineRecommendation: json['medicineRecommendation'] as String?,
    fertilizerRecommendation: json['fertilizerRecommendation'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'caseId': caseId,
    'farmerId': farmerId,
    'doctorId': doctorId,
    'cropType': cropType,
    'problemDescription': problemDescription,
    'imageUrls': imageUrls,
    'voiceNoteUrls': voiceNoteUrls,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'solution': solution,
    'medicineRecommendation': medicineRecommendation,
    'fertilizerRecommendation': fertilizerRecommendation,
  };

  Case copyWith({
    String? solution,
    String? medicineRecommendation,
    String? fertilizerRecommendation,
    CaseStatus? status,
  }) => Case(
    caseId: caseId,
    farmerId: farmerId,
    doctorId: doctorId,
    cropType: cropType,
    problemDescription: problemDescription,
    imageUrls: imageUrls,
    voiceNoteUrls: voiceNoteUrls,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
    solution: solution ?? this.solution,
    medicineRecommendation: medicineRecommendation ?? this.medicineRecommendation,
    fertilizerRecommendation: fertilizerRecommendation ?? this.fertilizerRecommendation,
  );
}

enum CaseStatus {
  @JsonValue('new')
  new_,
  @JsonValue('ongoing')
  ongoing,
  @JsonValue('resolved')
  resolved,
}

// ============= CHAT MESSAGE MODEL =============
class ChatMessage {
  final String messageId;
  final String caseId;
  final String senderId;
  final String messageText;
  final String? imageUrl;
  final String? audioUrl;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.messageId,
    required this.caseId,
    required this.senderId,
    required this.messageText,
    this.imageUrl,
    this.audioUrl,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    messageId: json['messageId'] as String,
    caseId: json['caseId'] as String,
    senderId: json['senderId'] as String,
    messageText: json['messageText'] as String,
    imageUrl: json['imageUrl'] as String?,
    audioUrl: json['audioUrl'] as String?,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isRead: json['isRead'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'caseId': caseId,
    'senderId': senderId,
    'messageText': messageText,
    'imageUrl': imageUrl,
    'audioUrl': audioUrl,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };
}

// ============= APPOINTMENT MODEL =============
class Appointment {
  final String appointmentId;
  final String doctorId;
  final String farmerId;
  final DateTime dateTime;
  final AppointmentStatus status;
  final String? notes;

  Appointment({
    required this.appointmentId,
    required this.doctorId,
    required this.farmerId,
    required this.dateTime,
    required this.status,
    this.notes,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    appointmentId: json['appointmentId'] as String,
    doctorId: json['doctorId'] as String,
    farmerId: json['farmerId'] as String,
    dateTime: DateTime.parse(json['dateTime'] as String),
    status: AppointmentStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => AppointmentStatus.pending,
    ),
    notes: json['notes'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'appointmentId': appointmentId,
    'doctorId': doctorId,
    'farmerId': farmerId,
    'dateTime': dateTime.toIso8601String(),
    'status': status.name,
    'notes': notes,
  };
}

enum AppointmentStatus {
  pending,
  accepted,
  rejected,
  completed,
}

// ============= NOTIFICATION MODEL =============
class DoctorNotification {
  final String notificationId;
  final String receiverId;
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId;

  DoctorNotification({
    required this.notificationId,
    required this.receiverId,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    required this.createdAt,
    this.relatedId,
  });

  factory DoctorNotification.fromJson(Map<String, dynamic> json) => DoctorNotification(
    notificationId: json['notificationId'] as String,
    receiverId: json['receiverId'] as String,
    type: NotificationType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => NotificationType.newCase,
    ),
    title: json['title'] as String,
    message: json['message'] as String,
    isRead: json['isRead'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    relatedId: json['relatedId'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'notificationId': notificationId,
    'receiverId': receiverId,
    'type': type.name,
    'title': title,
    'message': message,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
    'relatedId': relatedId,
  };
}

enum NotificationType {
  newCase,
  appointmentRequest,
  feedbackReceived,
  adminAlert,
  systemAlert,
}

// ============= FEEDBACK MODEL =============
class DoctorFeedback {
  final String feedbackId;
  final String farmerId;
  final String doctorId;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  DoctorFeedback({
    required this.feedbackId,
    required this.farmerId,
    required this.doctorId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory DoctorFeedback.fromJson(Map<String, dynamic> json) => DoctorFeedback(
    feedbackId: json['feedbackId'] as String,
    farmerId: json['farmerId'] as String,
    doctorId: json['doctorId'] as String,
    rating: (json['rating'] as num).toDouble(),
    comment: json['comment'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'feedbackId': feedbackId,
    'farmerId': farmerId,
    'doctorId': doctorId,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
  };
}

// ============= DOCTOR STATS MODEL =============
class DoctorStats {
  final int totalCasesSolved;
  final double averageResponseTime;
  final double averageRating;
  final int totalConsultations;
  final int pendingCases;
  final int todayAppointments;

  DoctorStats({
    required this.totalCasesSolved,
    required this.averageResponseTime,
    required this.averageRating,
    required this.totalConsultations,
    required this.pendingCases,
    required this.todayAppointments,
  });

  factory DoctorStats.fromJson(Map<String, dynamic> json) => DoctorStats(
    totalCasesSolved: json['totalCasesSolved'] as int? ?? 0,
    averageResponseTime: (json['averageResponseTime'] as num?)?.toDouble() ?? 0.0,
    averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    totalConsultations: json['totalConsultations'] as int? ?? 0,
    pendingCases: json['pendingCases'] as int? ?? 0,
    todayAppointments: json['todayAppointments'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'totalCasesSolved': totalCasesSolved,
    'averageResponseTime': averageResponseTime,
    'averageRating': averageRating,
    'totalConsultations': totalConsultations,
    'pendingCases': pendingCases,
    'todayAppointments': todayAppointments,
  };
}
