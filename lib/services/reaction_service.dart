class ReactionService {
  /// Add reaction to message
  static Map<String, dynamic> addReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) {
    return {
      'messageId': messageId,
      'userId': userId,
      'emoji': emoji,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Get reactions for a message
  static List<Map<String, dynamic>> getReactions(
      List<Map<String, dynamic>> existingReactions,
      String emoji) {
    return existingReactions
        .where((reaction) => reaction['emoji'] == emoji)
        .map((reaction) => {'userId': reaction['userId'], 'emoji': emoji})
        .toList();
  }
}
