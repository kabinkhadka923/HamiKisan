import 'package:flutter/material.dart';
import '../models/community_models.dart';
import '../services/community_service.dart';

class CommunityProvider with ChangeNotifier {
  final CommunityService _communityService = CommunityService();

  // Current state
  List<CommunityGroup> _userGroups = [];
  CommunityGroup? _selectedGroup;
  List<CommunityNotice> _notices = [];
  List<CommunityMarketPrice> _marketPrices = [];
  List<CommunityFeedback> _feedback = [];
  List<CommunityMessage> _messages = [];
  Map<String, dynamic> _groupStats = {};

  bool _isLoading = false;
  String? _error;

  // Getters
  List<CommunityGroup> get userGroups => _userGroups;
  CommunityGroup? get selectedGroup => _selectedGroup;
  List<CommunityNotice> get notices => _notices;
  List<CommunityNotice> get pinnedNotices =>
      _notices.where((n) => n.isPinned).toList();
  List<CommunityMarketPrice> get marketPrices => _marketPrices;
  List<CommunityFeedback> get feedback => _feedback;
  List<CommunityFeedback> get pendingFeedback =>
      _feedback.where((f) => f.status == FeedbackStatus.pending).toList();
  List<CommunityMessage> get messages => _messages;
  Map<String, dynamic> get groupStats => _groupStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ==================== INITIALIZATION ====================

  Future<void> initialize(String userId) async {
    _setLoading(true);
    try {
      _userGroups = await _communityService.getUserGroups(userId);
      if (_userGroups.isNotEmpty) {
        await selectGroup(_userGroups.first.id);
      }
      _clearError();
    } catch (e) {
      _setError('Failed to load groups: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ==================== GROUP MANAGEMENT ====================

  Future<void> selectGroup(String groupId) async {
    _setLoading(true);
    try {
      _selectedGroup = await _communityService.getGroupById(groupId);
      if (_selectedGroup != null) {
        await Future.wait([
          loadNotices(groupId),
          loadMarketPrices(groupId),
          loadMessages(groupId),
          loadGroupStats(groupId),
        ]);
      }
      _clearError();
    } catch (e) {
      _setError('Failed to load group data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> isGroupLeader(String userId, String groupId) async {
    return await _communityService.isGroupLeader(userId, groupId);
  }

  // ==================== NOTICES ====================

  Future<void> loadNotices(String groupId) async {
    try {
      _notices = await _communityService.getGroupNotices(groupId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load notices: $e');
    }
  }

  Future<void> createNotice(CommunityNotice notice) async {
    _setLoading(true);
    try {
      await _communityService.createNotice(notice);
      await loadNotices(notice.groupId);
      _clearError();
    } catch (e) {
      _setError('Failed to create notice: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateNotice(CommunityNotice notice) async {
    _setLoading(true);
    try {
      await _communityService.updateNotice(notice);
      await loadNotices(notice.groupId);
      _clearError();
    } catch (e) {
      _setError('Failed to update notice: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteNotice(String noticeId, String groupId) async {
    _setLoading(true);
    try {
      await _communityService.deleteNotice(noticeId);
      await loadNotices(groupId);
      _clearError();
    } catch (e) {
      _setError('Failed to delete notice: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> togglePinNotice(
      String noticeId, bool isPinned, String groupId) async {
    try {
      await _communityService.togglePinNotice(noticeId, isPinned);
      await loadNotices(groupId);
    } catch (e) {
      _setError('Failed to pin/unpin notice: $e');
    }
  }

  Future<void> incrementNoticeViews(String noticeId) async {
    try {
      await _communityService.incrementNoticeViews(noticeId);
    } catch (e) {
      // Silent fail for view count
    }
  }

  // ==================== MARKET PRICES ====================

  Future<void> loadMarketPrices(String groupId, {String? category}) async {
    try {
      _marketPrices = await _communityService.getGroupMarketPrices(
        groupId,
        category: category,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load market prices: $e');
    }
  }

  Future<void> postMarketPrice(CommunityMarketPrice price) async {
    _setLoading(true);
    try {
      await _communityService.postMarketPrice(price);
      await loadMarketPrices(price.groupId);
      _clearError();
    } catch (e) {
      _setError('Failed to post market price: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMarketPrice(CommunityMarketPrice price) async {
    _setLoading(true);
    try {
      await _communityService.updateMarketPrice(price);
      await loadMarketPrices(price.groupId);
      _clearError();
    } catch (e) {
      _setError('Failed to update market price: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteMarketPrice(String priceId, String groupId) async {
    _setLoading(true);
    try {
      await _communityService.deleteMarketPrice(priceId);
      await loadMarketPrices(groupId);
      _clearError();
    } catch (e) {
      _setError('Failed to delete market price: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ==================== FEEDBACK ====================

  Future<void> loadFeedback(String groupId, {FeedbackStatus? status}) async {
    try {
      _feedback = await _communityService.getGroupFeedback(
        groupId,
        status: status,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load feedback: $e');
    }
  }

  Future<void> loadUserFeedback(String userId) async {
    try {
      _feedback = await _communityService.getUserFeedback(userId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load your feedback: $e');
    }
  }

  Future<void> submitFeedback(CommunityFeedback feedback) async {
    _setLoading(true);
    try {
      await _communityService.submitFeedback(feedback);
      await loadUserFeedback(feedback.userId);
      _clearError();
    } catch (e) {
      _setError('Failed to submit feedback: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> respondToFeedback(
    String feedbackId,
    String response,
    String responderId,
    String responderName,
    FeedbackStatus newStatus,
    String groupId,
  ) async {
    _setLoading(true);
    try {
      await _communityService.respondToFeedback(
        feedbackId,
        response,
        responderId,
        responderName,
        newStatus,
      );
      await loadFeedback(groupId);
      _clearError();
    } catch (e) {
      _setError('Failed to respond to feedback: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateFeedbackStatus(
    String feedbackId,
    FeedbackStatus status,
    String groupId,
  ) async {
    try {
      await _communityService.updateFeedbackStatus(feedbackId, status);
      await loadFeedback(groupId);
    } catch (e) {
      _setError('Failed to update feedback status: $e');
    }
  }

  // ==================== MESSAGES ====================

  Future<void> loadMessages(String groupId, {bool onlyApproved = true}) async {
    try {
      _messages = await _communityService.getGroupMessages(
        groupId,
        onlyApproved: onlyApproved,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load messages: $e');
    }
  }

  Future<void> sendMessage(CommunityMessage message, bool isLeader) async {
    _setLoading(true);
    try {
      await _communityService.sendMessage(message, isLeader);
      await loadMessages(message.groupId);
      _clearError();
    } catch (e) {
      _setError('Failed to send message: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> approveMessage(
      String messageId, String approverId, String groupId) async {
    try {
      await _communityService.approveMessage(messageId, approverId);
      await loadMessages(groupId, onlyApproved: false);
    } catch (e) {
      _setError('Failed to approve message: $e');
    }
  }

  Future<void> deleteMessage(String messageId, String groupId) async {
    try {
      await _communityService.deleteMessage(messageId);
      await loadMessages(groupId, onlyApproved: false);
    } catch (e) {
      _setError('Failed to delete message: $e');
    }
  }

  Future<List<CommunityMessage>> getPendingMessages(String groupId) async {
    try {
      return await _communityService.getPendingMessages(groupId);
    } catch (e) {
      _setError('Failed to load pending messages: $e');
      return [];
    }
  }

  // ==================== STATISTICS ====================

  Future<void> loadGroupStats(String groupId) async {
    try {
      _groupStats = await _communityService.getGroupStats(groupId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load group stats: $e');
    }
  }

  // ==================== ADMIN FUNCTIONS ====================

  /// Admin: Get all groups in the system
  Future<List<CommunityGroup>> getAllGroups() async {
    // TODO: Implement admin-level group fetching
    return _userGroups;
  }

  /// Admin: Create a new community group
  Future<void> createGroup(CommunityGroup group) async {
    _setLoading(true);
    try {
      // TODO: Implement group creation
      _clearError();
    } catch (e) {
      _setError('Failed to create group: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Admin: Assign/change group leader
  Future<void> assignGroupLeader(String groupId, String newLeaderId) async {
    _setLoading(true);
    try {
      // TODO: Implement leader assignment
      _clearError();
    } catch (e) {
      _setError('Failed to assign group leader: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Admin: Deactivate a group
  Future<void> deactivateGroup(String groupId) async {
    _setLoading(true);
    try {
      // TODO: Implement group deactivation
      _clearError();
    } catch (e) {
      _setError('Failed to deactivate group: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Admin: Get all feedback across all groups
  Future<List<CommunityFeedback>> getAllFeedback(
      {FeedbackStatus? status}) async {
    try {
      // TODO: Implement system-wide feedback fetching
      return [];
    } catch (e) {
      _setError('Failed to load all feedback: $e');
      return [];
    }
  }

  /// Admin: Get statistics for all groups
  Future<Map<String, dynamic>> getSystemStats() async {
    try {
      // TODO: Implement system-wide statistics
      return {
        'total_groups': 0,
        'total_members': 0,
        'total_notices': 0,
        'pending_feedback': 0,
      };
    } catch (e) {
      _setError('Failed to load system stats: $e');
      return {};
    }
  }

  // ==================== HELPER METHODS ====================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearAll() {
    _userGroups = [];
    _selectedGroup = null;
    _notices = [];
    _marketPrices = [];
    _feedback = [];
    _messages = [];
    _groupStats = {};
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
