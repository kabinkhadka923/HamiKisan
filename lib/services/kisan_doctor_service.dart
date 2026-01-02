import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kisan_doctor_models.dart';

class KisanDoctorService {
  static const String _casesKey = 'kisan_doctor_cases';
  static const String _messagesKey = 'kisan_doctor_messages';
  static const String _appointmentsKey = 'kisan_doctor_appointments';
  static const String _notificationsKey = 'kisan_doctor_notifications';
  static const String _feedbackKey = 'kisan_doctor_feedback';

  // ============= CASE MANAGEMENT =============

  Future<List<Case>> getDoctorCases(String doctorId, {CaseStatus? status}) async {
    final prefs = await SharedPreferences.getInstance();
    final casesStr = prefs.getString(_casesKey);
    if (casesStr == null) return [];

    final cases = (json.decode(casesStr) as List<dynamic>)
        .map((e) => Case.fromJson(e as Map<String, dynamic>))
        .toList();

    return cases
        .where((c) => c.doctorId == doctorId && (status == null || c.status == status))
        .toList();
  }

  Future<Case?> getCaseById(String caseId) async {
    final prefs = await SharedPreferences.getInstance();
    final casesStr = prefs.getString(_casesKey);
    if (casesStr == null) return null;

    final cases = (json.decode(casesStr) as List<dynamic>)
        .map((e) => Case.fromJson(e as Map<String, dynamic>))
        .toList();

    try {
      return cases.firstWhere((c) => c.caseId == caseId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateCase(Case updatedCase) async {
    final prefs = await SharedPreferences.getInstance();
    final casesStr = prefs.getString(_casesKey);
    if (casesStr == null) return;

    final cases = (json.decode(casesStr) as List<dynamic>)
        .map((e) => Case.fromJson(e as Map<String, dynamic>))
        .toList();

    final index = cases.indexWhere((c) => c.caseId == updatedCase.caseId);
    if (index != -1) {
      cases[index] = updatedCase;
      await prefs.setString(_casesKey, json.encode(cases.map((c) => c.toJson()).toList()));
    }
  }

  Future<void> closeCase(String caseId) async {
    final case_ = await getCaseById(caseId);
    if (case_ != null) {
      await updateCase(case_.copyWith(status: CaseStatus.resolved));
    }
  }

  // ============= CHAT MANAGEMENT =============

  Future<List<ChatMessage>> getCaseMessages(String caseId) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesStr = prefs.getString(_messagesKey);
    if (messagesStr == null) return [];

    final messages = (json.decode(messagesStr) as List<dynamic>)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();

    return messages.where((m) => m.caseId == caseId).toList();
  }

  Future<void> sendMessage(ChatMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesStr = prefs.getString(_messagesKey) ?? '[]';

    final messages = (json.decode(messagesStr) as List<dynamic>)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();

    messages.add(message);
    await prefs.setString(_messagesKey, json.encode(messages.map((m) => m.toJson()).toList()));
  }

  // ============= APPOINTMENT MANAGEMENT =============

  Future<List<Appointment>> getDoctorAppointments(String doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsStr = prefs.getString(_appointmentsKey);
    if (appointmentsStr == null) return [];

    final appointments = (json.decode(appointmentsStr) as List<dynamic>)
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();

    return appointments.where((a) => a.doctorId == doctorId).toList();
  }

  Future<void> approveAppointment(String appointmentId) async {
    await _updateAppointmentStatus(appointmentId, AppointmentStatus.accepted);
  }

  Future<void> rejectAppointment(String appointmentId) async {
    await _updateAppointmentStatus(appointmentId, AppointmentStatus.rejected);
  }

  Future<void> _updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsStr = prefs.getString(_appointmentsKey);
    if (appointmentsStr == null) return;

    final appointments = (json.decode(appointmentsStr) as List<dynamic>)
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();

    final index = appointments.indexWhere((a) => a.appointmentId == appointmentId);
    if (index != -1) {
      final appointment = appointments[index];
      appointments[index] = Appointment(
        appointmentId: appointment.appointmentId,
        doctorId: appointment.doctorId,
        farmerId: appointment.farmerId,
        dateTime: appointment.dateTime,
        status: status,
        notes: appointment.notes,
      );
      await prefs.setString(_appointmentsKey, json.encode(appointments.map((a) => a.toJson()).toList()));
    }
  }

  // ============= NOTIFICATION MANAGEMENT =============

  Future<List<DoctorNotification>> getDoctorNotifications(String doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsStr = prefs.getString(_notificationsKey);
    if (notificationsStr == null) return [];

    final notifications = (json.decode(notificationsStr) as List<dynamic>)
        .map((e) => DoctorNotification.fromJson(e as Map<String, dynamic>))
        .toList();

    return notifications.where((n) => n.receiverId == doctorId).toList();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsStr = prefs.getString(_notificationsKey);
    if (notificationsStr == null) return;

    final notifications = (json.decode(notificationsStr) as List<dynamic>)
        .map((e) => DoctorNotification.fromJson(e as Map<String, dynamic>))
        .toList();

    final index = notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1) {
      final notification = notifications[index];
      notifications[index] = DoctorNotification(
        notificationId: notification.notificationId,
        receiverId: notification.receiverId,
        type: notification.type,
        title: notification.title,
        message: notification.message,
        isRead: true,
        createdAt: notification.createdAt,
        relatedId: notification.relatedId,
      );
      await prefs.setString(_notificationsKey, json.encode(notifications.map((n) => n.toJson()).toList()));
    }
  }

  // ============= FEEDBACK MANAGEMENT =============

  Future<List<DoctorFeedback>> getDoctorFeedback(String doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    final feedbackStr = prefs.getString(_feedbackKey);
    if (feedbackStr == null) return [];

    final feedback = (json.decode(feedbackStr) as List<dynamic>)
        .map((e) => DoctorFeedback.fromJson(e as Map<String, dynamic>))
        .toList();

    return feedback.where((f) => f.doctorId == doctorId).toList();
  }

  // ============= STATISTICS =============

  Future<DoctorStats> getDoctorStats(String doctorId) async {
    final cases = await getDoctorCases(doctorId);
    final feedback = await getDoctorFeedback(doctorId);
    final appointments = await getDoctorAppointments(doctorId);

    final solvedCases = cases.where((c) => c.status == CaseStatus.resolved).length;
    final pendingCases = cases.where((c) => c.status == CaseStatus.new_).length;
    final todayAppointments = appointments
        .where((a) => a.dateTime.day == DateTime.now().day && a.status == AppointmentStatus.accepted)
        .length;

    double avgRating = 0;
    if (feedback.isNotEmpty) {
      avgRating = feedback.map((f) => f.rating).reduce((a, b) => a + b) / feedback.length;
    }

    return DoctorStats(
      totalCasesSolved: solvedCases,
      averageResponseTime: 2.5,
      averageRating: avgRating,
      totalConsultations: cases.length,
      pendingCases: pendingCases,
      todayAppointments: todayAppointments,
    );
  }

  // ============= INITIALIZATION =============

  Future<void> initializeMockData() async {
    final prefs = await SharedPreferences.getInstance();

    // Initialize mock cases
    if (prefs.getString(_casesKey) == null) {
      final mockCases = [
        Case(
          caseId: 'case_1',
          farmerId: 'user_1',
          doctorId: 'user_2',
          cropType: 'Tomato',
          problemDescription: 'Leaves turning yellow with brown spots',
          imageUrls: [],
          status: CaseStatus.new_,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Case(
          caseId: 'case_2',
          farmerId: 'user_1',
          doctorId: 'user_2',
          cropType: 'Wheat',
          problemDescription: 'Plant wilting despite regular watering',
          imageUrls: [],
          status: CaseStatus.ongoing,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now(),
        ),
      ];
      await prefs.setString(_casesKey, json.encode(mockCases.map((c) => c.toJson()).toList()));
    }

    // Initialize mock notifications
    if (prefs.getString(_notificationsKey) == null) {
      final mockNotifications = [
        DoctorNotification(
          notificationId: 'notif_1',
          receiverId: 'user_2',
          type: NotificationType.newCase,
          title: 'New Case Assigned',
          message: 'Farmer Rajesh reported tomato disease',
          createdAt: DateTime.now(),
          relatedId: 'case_1',
        ),
      ];
      await prefs.setString(_notificationsKey, json.encode(mockNotifications.map((n) => n.toJson()).toList()));
    }
  }
}
