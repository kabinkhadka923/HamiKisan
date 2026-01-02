import 'package:flutter/material.dart';
import '../models/kisan_doctor_models.dart';
import '../services/kisan_doctor_service.dart';

class KisanDoctorProvider extends ChangeNotifier {
  final KisanDoctorService _service = KisanDoctorService();

  // State variables
  List<Case> _cases = [];
  List<ChatMessage> _currentCaseMessages = [];
  List<Appointment> _appointments = [];
  List<DoctorNotification> _notifications = [];
  List<DoctorFeedback> _feedback = [];
  DoctorStats? _stats;
  Case? _selectedCase;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Case> get cases => _cases;
  List<ChatMessage> get currentCaseMessages => _currentCaseMessages;
  List<Appointment> get appointments => _appointments;
  List<DoctorNotification> get notifications => _notifications;
  List<DoctorFeedback> get feedback => _feedback;
  DoctorStats? get stats => _stats;
  Case? get selectedCase => _selectedCase;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed properties
  List<Case> get newCases => _cases.where((c) => c.status == CaseStatus.new_).toList();
  List<Case> get pendingCases => _cases.where((c) => c.status == CaseStatus.ongoing).toList();
  List<Case> get resolvedCases => _cases.where((c) => c.status == CaseStatus.resolved).toList();
  List<DoctorNotification> get unreadNotifications => _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;

  // ============= INITIALIZATION =============

  Future<void> initialize(String doctorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.initializeMockData();
      await loadDoctorCases(doctorId);
      await loadDoctorAppointments(doctorId);
      await loadDoctorNotifications(doctorId);
      await loadDoctorFeedback(doctorId);
      await loadDoctorStats(doctorId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============= CASE MANAGEMENT =============

  Future<void> loadDoctorCases(String doctorId) async {
    try {
      _cases = await _service.getDoctorCases(doctorId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> selectCase(String caseId) async {
    try {
      _selectedCase = await _service.getCaseById(caseId);
      if (_selectedCase != null) {
        await loadCaseMessages(caseId);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCaseWithSolution({
    required String caseId,
    required String solution,
    String? medicineRecommendation,
    String? fertilizerRecommendation,
  }) async {
    try {
      final case_ = await _service.getCaseById(caseId);
      if (case_ != null) {
        final updated = case_.copyWith(
          solution: solution,
          medicineRecommendation: medicineRecommendation,
          fertilizerRecommendation: fertilizerRecommendation,
          status: CaseStatus.ongoing,
        );
        await _service.updateCase(updated);
        _selectedCase = updated;
        await loadDoctorCases(case_.doctorId);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> closeCase(String caseId) async {
    try {
      await _service.closeCase(caseId);
      if (_selectedCase?.caseId == caseId) {
        _selectedCase = _selectedCase?.copyWith(status: CaseStatus.resolved);
      }
      _cases = _cases.map((c) => c.caseId == caseId ? c.copyWith(status: CaseStatus.resolved) : c).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ============= CHAT MANAGEMENT =============

  Future<void> loadCaseMessages(String caseId) async {
    try {
      _currentCaseMessages = await _service.getCaseMessages(caseId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendMessage({
    required String caseId,
    required String senderId,
    required String messageText,
    String? imageUrl,
    String? audioUrl,
  }) async {
    try {
      final message = ChatMessage(
        messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        caseId: caseId,
        senderId: senderId,
        messageText: messageText,
        imageUrl: imageUrl,
        audioUrl: audioUrl,
        timestamp: DateTime.now(),
      );
      await _service.sendMessage(message);
      _currentCaseMessages.add(message);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ============= APPOINTMENT MANAGEMENT =============

  Future<void> loadDoctorAppointments(String doctorId) async {
    try {
      _appointments = await _service.getDoctorAppointments(doctorId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> approveAppointment(String appointmentId) async {
    try {
      await _service.approveAppointment(appointmentId);
      _appointments = _appointments.map((a) =>
        a.appointmentId == appointmentId
            ? Appointment(
                appointmentId: a.appointmentId,
                doctorId: a.doctorId,
                farmerId: a.farmerId,
                dateTime: a.dateTime,
                status: AppointmentStatus.accepted,
                notes: a.notes,
              )
            : a
      ).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> rejectAppointment(String appointmentId) async {
    try {
      await _service.rejectAppointment(appointmentId);
      _appointments = _appointments.map((a) =>
        a.appointmentId == appointmentId
            ? Appointment(
                appointmentId: a.appointmentId,
                doctorId: a.doctorId,
                farmerId: a.farmerId,
                dateTime: a.dateTime,
                status: AppointmentStatus.rejected,
                notes: a.notes,
              )
            : a
      ).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ============= NOTIFICATION MANAGEMENT =============

  Future<void> loadDoctorNotifications(String doctorId) async {
    try {
      _notifications = await _service.getDoctorNotifications(doctorId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _service.markNotificationAsRead(notificationId);
      _notifications = _notifications.map((n) =>
        n.notificationId == notificationId
            ? DoctorNotification(
                notificationId: n.notificationId,
                receiverId: n.receiverId,
                type: n.type,
                title: n.title,
                message: n.message,
                isRead: true,
                createdAt: n.createdAt,
                relatedId: n.relatedId,
              )
            : n
      ).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ============= FEEDBACK MANAGEMENT =============

  Future<void> loadDoctorFeedback(String doctorId) async {
    try {
      _feedback = await _service.getDoctorFeedback(doctorId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ============= STATISTICS =============

  Future<void> loadDoctorStats(String doctorId) async {
    try {
      _stats = await _service.getDoctorStats(doctorId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ============= UTILITY METHODS =============

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCase = null;
    _currentCaseMessages = [];
    notifyListeners();
  }
}
