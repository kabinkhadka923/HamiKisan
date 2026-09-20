import 'package:flutter/material.dart';
import '../models/user.dart';

class ConsultationChatScreen extends StatelessWidget {
  final User peer;

  const ConsultationChatScreen({super.key, required this.peer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${peer.name}')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Chat feature coming soon', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}