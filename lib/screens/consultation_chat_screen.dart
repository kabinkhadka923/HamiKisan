import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../models/chat_message.dart';
import '../providers/auth_provider.dart';
import '../services/call/kisan_video_call_service.dart';
import '../services/chat_service.dart';
import '../services/media_service.dart';
import '../services/location_service.dart';
import 'video_call_screen.dart';

enum ChatMode { one_on_one, group }

class ConsultationChatScreen extends StatefulWidget {
  final User peer;

  const ConsultationChatScreen({
    super.key,
    required this.peer,
  });

  @override
  State<ConsultationChatScreen> createState() => _ConsultationChatScreenState();
}

class _ConsultationChatScreenState extends State<ConsultationChatScreen> {
  final ChatService _chatService = ChatService();
  final MediaService _mediaService = MediaService();
  final LocationService _locationService = LocationService();

  StreamSubscription<ChatMessage>? _messageSub;

  String _myUserId = '';
  String _peerId = '';

  ChatMode _chatMode = ChatMode.one_on_one;
  String? _selectedGroupId;
  List<ChatMessage> _messages = [];
  List<ChatMessage> _groupMessages = [];
  List<Map<String, dynamic>> _availableGroups = [];
  bool _isLoadingGroups = false;

  TextEditingController _messageController = TextEditingController();
  bool _isComposing = false;
  bool _isSending = false;
  String? _mediaPath;
  String? _locationLat;
  String? _locationLng;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initialize() async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) return;

    // Initialize variables
    _myUserId = context.read<AuthProvider>().currentUser?.id ?? '';
    _peerId = widget.peer.id;

    await _chatService.initialize(currentUser.id);
    await _loadGroups();
    await _loadConversation();
  }

  void _handleIncomingMessage(ChatMessage message) {
    final isGroupMsg = message.groupId != null;
    final isCurrentGroup = !isGroupMsg ||
        (_selectedGroupId != null && message.groupId == _selectedGroupId);

    if (mounted) {
      setState(() {
        if (_chatMode == ChatMode.one_on_one) {
          if (!isGroupMsg &&
              (message.senderId == _peerId || message.receiverId == _myUserId)) {
            final index = _messages.indexWhere((m) => m.id == message.id);
            if (index >= 0) {
              _messages[index] = message;
            } else {
              _messages.add(message);
              _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            }
          }
        } else if (_chatMode == ChatMode.group && message.groupId == _selectedGroupId) {
          final index = _groupMessages.indexWhere((m) => m.id == message.id);
          if (index >= 0) {
            _groupMessages[index] = message;
          } else {
            _groupMessages.add(message);
            _groupMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          }
        }
      });
    }
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await _chatService.getGroups();
      if (mounted) {
        setState(() {
          _availableGroups = groups;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadConversation() async {
    if (_chatMode == ChatMode.group && _selectedGroupId != null) {
      final messages = await _chatService.getConversationWithGroup(_selectedGroupId!);
      if (mounted) {
        setState(() {
          _groupMessages = messages;
        });
      }
    } else {
      final messages = await _chatService.getConversationWithUser(_peerId);
      if (mounted) {
        setState(() {
          _messages = messages;
        });
      }
    }
  }

  Widget _buildChatModeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _chatMode == ChatMode.one_on_one
                  ? null
                  : () {
                      setState(() => _chatMode = ChatMode.one_on_one);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _chatMode == ChatMode.one_on_one
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300],
                foregroundColor: _chatMode == ChatMode.one_on_one
                    ? Colors.white
                    : Colors.black87,
              ),
              child: const Text('One-on-One'),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showGroupSelectionDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _chatMode == ChatMode.group
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300],
                foregroundColor: _chatMode == ChatMode.group
                    ? Colors.white
                    : Colors.black87,
              ),
              child: const Text('Groups'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showGroupSelectionDialog() async {
    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _GroupSelectionDialog(groups: []),
    );

    if (selected != null && mounted) {
      setState(() {
        _chatMode = ChatMode.group;
        _selectedGroupId = selected['groupId'] as String;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.peer.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoCallScreen(
                    callId: 'call_${DateTime.now().millisecondsSinceEpoch}',
                    peerName: widget.peer.name,
                    callerName: authProvider.currentUser?.name ?? 'Me',
                    callerSpecialty: 'Consultation',
                    role: CallRole.caller,
                    callerId: authProvider.currentUser?.id ?? '',
                    calleeId: widget.peer.id,
                    isOutgoing: true,
                    callType: CallType.video,
                  ),
                ),
              );
            },
            tooltip: 'Video Call',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Chat with ${widget.peer.name}',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      final authProvider = context.read<AuthProvider>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoCallScreen(
                            callId: 'call_${DateTime.now().millisecondsSinceEpoch}',
                            peerName: widget.peer.name,
                            callerName: authProvider.currentUser?.name ?? 'Me',
                            callerSpecialty: 'Consultation',
                            role: CallRole.caller,
                            callerId: authProvider.currentUser?.id ?? '',
                            calleeId: widget.peer.id,
                            isOutgoing: true,
                            callType: CallType.video,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.video_call),
                    label: const Text('Start Video Call'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupSelectionDialog extends StatelessWidget {
  final List<Map<String, dynamic>> groups;

  const _GroupSelectionDialog({required this.groups});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Group'),
      content: SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return ListTile(
              title: Text(group['name'] ?? 'Unnamed Group'),
              onTap: () => Navigator.of(context).pop({'groupId': group['id']}),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}