import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../services/connection_service.dart';
import 'consultation_chat_screen.dart';

class ConsultationContactsScreen extends StatefulWidget {
  const ConsultationContactsScreen({super.key});

  @override
  State<ConsultationContactsScreen> createState() =>
      _ConsultationContactsScreenState();
}

class _ConsultationContactsScreenState
    extends State<ConsultationContactsScreen> {
  final ChatService _chatService = ChatService();
  final ConnectionService _connectionService = ConnectionService();
  final TextEditingController _searchController = TextEditingController();

  List<User> _contacts = [];
  List<User> _filteredContacts = [];
  bool _isLoading = true;
  String? _error;
  List<ConnectionRecord> _connections = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applySearchFilter);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadContacts());
  }

  @override
  void dispose() {
    _searchController.removeListener(_applySearchFilter);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      setState(() {
        _error = 'Please login first';
        _isLoading = false;
      });
      return;
    }

    try {
      await _chatService.initialize(currentUser.id);
      final connections = await _connectionService.listConnections(currentUser.id);

      final contacts = currentUser.role == UserRole.kisanDoctor
          ? await _chatService.getAvailableFarmers()
          : await _chatService.getAvailableDoctors();

      setState(() {
        _contacts = contacts;
        _filteredContacts = contacts;
        _connections = connections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load contacts: $e';
        _isLoading = false;
      });
    }
  }

  ConnectionRecord? _connectionFor(String userId) {
    for (final connection in _connections) {
      if (connection.otherUserId == userId) return connection;
    }
    return null;
  }

  Future<void> _updateConnection(String connectionId, String action) async {
    try {
      await _connectionService.updateConnection(connectionId, action);
      await _loadContacts();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _requestConnection(User user) async {
    try {
      await _connectionService.requestConnection(user.id);
      await _loadContacts();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _showConnectionActions(ConnectionRecord connection) async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Connection actions'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'block'),
            child: const Text('Block user'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'report'),
            child: const Text('Report user'),
          ),
        ],
      ),
    );
    if (!mounted || action == null) return;
    try {
      if (action == 'block') {
        await _connectionService.updateConnection(connection.id, 'block');
      } else {
        await _connectionService.reportConnection(
          connection.id,
          'Reported from consultation contacts.',
        );
      }
      await _loadContacts();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _applySearchFilter() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredContacts = List<User>.from(_contacts));
      return;
    }

    setState(() {
      _filteredContacts = _contacts.where((user) {
        final name = user.name.toLowerCase();
        final email = user.email.toLowerCase();
        final phone = (user.phoneNumber ?? '').toLowerCase();
        return name.contains(query) ||
            email.contains(query) ||
            phone.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final isDoctor = currentUser?.role == UserRole.kisanDoctor;
    final title = isDoctor ? 'Farmers' : 'Kisan Doctors';

    return Scaffold(
      appBar: AppBar(
        title: Text('Consultation - $title'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or phone',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          _buildPendingRequestsBanner(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildPendingRequestsBanner() {
    final currentUser = context.read<AuthProvider>().currentUser;
    final requests = _connections.where((connection) {
      return connection.status == 'pending' &&
          connection.receiverId == currentUser?.id;
    }).toList();
    if (requests.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCA28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connection Requests',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          ...requests.map((request) {
            final name = request.otherUserName ?? 'A user';
            return Row(
              children: [
                Expanded(child: Text('$name wants to connect with you.')),
                IconButton(
                  tooltip: 'Reject',
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _updateConnection(request.id, 'reject'),
                ),
                IconButton(
                  tooltip: 'Accept',
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _updateConnection(request.id, 'accept'),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }

    if (_filteredContacts.isEmpty) {
      return const Center(child: Text('No contacts found'));
    }

    return RefreshIndicator(
      onRefresh: _loadContacts,
      child: ListView.separated(
        itemCount: _filteredContacts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = _filteredContacts[index];
          final hasPhone = user.phoneNumber?.isNotEmpty == true;
            final connection = _connectionFor(user.id);
            final status = connection?.status;
            final isAccepted = status == 'accepted';
            final isIncoming = status == 'pending' &&
              connection?.receiverId == currentUser?.id;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2E7D32).withOpacity(0.12),
              child: Icon(
                user.role == UserRole.kisanDoctor
                    ? Icons.medical_services
                    : Icons.agriculture,
                color: const Color(0xFF2E7D32),
              ),
            ),
            title: Text(
              user.role == UserRole.kisanDoctor
                  ? '${user.name} (Kisan Doctor)'
                  : user.name,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasPhone ? user.phoneNumber! : user.email,
                ),
                if (user.specialization?.isNotEmpty == true)
                  Text(
                    user.specialization!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    status == null
                        ? 'No connection'
                        : status == 'accepted'
                            ? 'Connected'
                            : status == 'pending' && isIncoming
                                ? 'Wants to connect with you'
                                : status == 'pending'
                                    ? 'Request sent'
                                    : 'Communication disabled',
                    style: TextStyle(
                      fontSize: 12,
                      color: isAccepted ? Colors.green : Colors.grey,
                    ),
                  ),
              ],
            ),
              isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                  if (isIncoming) ...[
                  IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      tooltip: 'Reject request',
                      onPressed: () => _updateConnection(connection!.id, 'reject'),
                  ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      tooltip: 'Accept request',
                      onPressed: () => _updateConnection(connection!.id, 'accept'),
                    ),
                  ] else if (isAccepted)
                    const Icon(Icons.chat_bubble_outline,
                        color: Color(0xFF2E7D32))
                  else if (status == null)
                    IconButton(
                      icon: const Icon(Icons.person_add_alt_1,
                          color: Color(0xFF2E7D32)),
                      tooltip: 'Send connection request',
                      onPressed: () => _requestConnection(user),
                    )
                  else
                    const Icon(Icons.block, color: Colors.grey),
              ],
            ),
              onTap: isAccepted
                  ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConsultationChatScreen(peer: user),
                ),
              );
              }
                  : null,
                onLongPress: connection == null
                  ? null
                  : () => _showConnectionActions(connection),
          );
        },
      ),
    );
  }
}
