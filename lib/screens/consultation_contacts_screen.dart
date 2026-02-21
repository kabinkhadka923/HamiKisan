import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
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
  final TextEditingController _searchController = TextEditingController();

  List<User> _contacts = [];
  List<User> _filteredContacts = [];
  bool _isLoading = true;
  String? _error;

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

      final contacts = currentUser.role == UserRole.kisanDoctor
          ? await _chatService.getAvailableFarmers()
          : await _chatService.getAvailableDoctors();

      setState(() {
        _contacts = contacts;
        _filteredContacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load contacts: $e';
        _isLoading = false;
      });
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
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
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
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.12),
              child: Icon(
                user.role == UserRole.kisanDoctor
                    ? Icons.medical_services
                    : Icons.agriculture,
                color: const Color(0xFF2E7D32),
              ),
            ),
            title: Text(user.name),
            subtitle: Text(
              user.phoneNumber?.isNotEmpty == true
                  ? user.phoneNumber!
                  : user.email,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConsultationChatScreen(peer: user),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
