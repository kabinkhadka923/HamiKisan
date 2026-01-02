import 'package:flutter/material.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> 
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  
  final List<Map<String, dynamic>> _doctors = [
    {
      'id': '1',
      'name': 'Dr. Ram Sharma',
      'specialization': 'Plant Pathology',
      'experience': '15 years',
      'rating': 4.9,
      'consultations': 2456,
      'image': '👨‍⚕️',
      'available': true,
      'education': 'PhD in Plant Pathology, TU',
      'languages': ['Nepali', 'English', 'Hindi'],
    },
    {
      'id': '2',
      'name': 'Dr. Sita Devi',
      'specialization': 'Horticulture',
      'experience': '12 years',
      'rating': 4.8,
      'consultations': 1892,
      'image': '👩‍⚕️',
      'available': true,
      'education': 'MSc Horticulture, IAAS',
      'languages': ['Nepali', 'English'],
    },
    {
      'id': '3',
      'name': 'Dr. Krishna Yadav',
      'specialization': 'Soil Science',
      'experience': '18 years',
      'rating': 4.7,
      'consultations': 3210,
      'image': '👨‍⚕️',
      'available': false,
      'education': 'PhD Soil Science, TU',
      'languages': ['Nepali', 'English', 'Maithili'],
    },
    {
      'id': '4',
      'name': 'Dr. Gopal Thapa',
      'specialization': 'Entomology',
      'experience': '10 years',
      'rating': 4.6,
      'consultations': 1456,
      'image': '👨‍⚕️',
      'available': true,
      'education': 'MSc Entomology, IAAS',
      'languages': ['Nepali', 'English'],
    },
  ];

  final List<Map<String, dynamic>> _conversations = [
    {
      'id': '1',
      'doctorId': '1',
      'doctorName': 'Dr. Ram Sharma',
      'lastMessage': 'Apply copper fungicide immediately. Take photo in 3 days.',
      'timestamp': '2 min ago',
      'unread': 2,
      'image': '🌾',
    },
    {
      'id': '2',
      'doctorId': '2',
      'doctorName': 'Dr. Sita Devi',
      'lastMessage': 'Tomato plants need staking support and regular pruning.',
      'timestamp': '1 hour ago',
      'unread': 0,
      'image': '🍅',
    },
    {
      'id': '3',
      'doctorId': '4',
      'doctorName': 'Dr. Gopal Thapa',
      'lastMessage': 'Use neem oil spray for natural pest control.',
      'timestamp': '1 day ago',
      'unread': 0,
      'image': '🐛',
    },
  ];

  final List<Map<String, dynamic>> _diagnoses = [
    {
      'id': '1',
      'crop': 'Tomato',
      'disease': 'Early Blight',
      'confidence': 89,
      'date': '2024-11-20',
      'image': '🍅',
      'treatment': 'Apply copper fungicide and remove affected leaves',
    },
    {
      'id': '2',
      'crop': 'Rice',
      'disease': 'Blast Disease',
      'confidence': 92,
      'date': '2024-11-18',
      'image': '🌾',
      'treatment': 'Use resistant variety and proper nitrogen management',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kisan Doctor'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Consult', icon: Icon(Icons.chat)),
            Tab(text: 'AI Diagnosis', icon: Icon(Icons.camera_alt)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showMessage('Notifications'),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConsultTab(),
          _buildAIDiagnosisTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewConsultationDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildConsultTab() {
    return Column(
      children: [
        _buildConsultationTypeSelector(),
        Expanded(
          child: _tabController.index == 0
              ? _buildDoctorsList()
              : _buildConversationsList(),
        ),
      ],
    );
  }

  Widget _buildConsultationTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(0),
              icon: const Icon(Icons.group),
              label: const Text('Find Doctor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.chat),
              label: const Text('My Chats'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    final availableDoctors = _doctors.where((d) => d['available']).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: availableDoctors.length,
      itemBuilder: (context, index) {
        final doctor = availableDoctors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Center(
                    child: Text(
                      doctor['image'],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor['specialization'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(doctor['rating'].toString()),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${doctor['consultations']} consultations',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        doctor['experience'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Available',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _startConsultation(doctor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Consult'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConversationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            onTap: () => _openChat(conversation),
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: Text(
                conversation['image'],
                style: const TextStyle(fontSize: 24),
              ),
            ),
            title: Row(
              children: [
                Text(
                  conversation['doctorName'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (conversation['unread'] > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        conversation['unread'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation['lastMessage'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  conversation['timestamp'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }

  Widget _buildAIDiagnosisTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 60,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AI Crop Diagnosis',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Take a photo of your crop for instant diagnosis',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showMessage('Opening camera...'),
            icon: const Icon(Icons.camera),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showMessage('Opening gallery...'),
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _diagnoses.length,
      itemBuilder: (context, index) {
        final diagnosis = _diagnoses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          diagnosis['image'],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${diagnosis['crop']} - ${diagnosis['disease']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${diagnosis['confidence']}% confidence',
                            style: TextStyle(
                              color: Colors.green.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            diagnosis['date'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.medical_services, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Treatment: ${diagnosis['treatment']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startConsultation(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Consult with ${doctor['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specialization: ${doctor['specialization']}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text('Experience: ${doctor['experience']}'),
            const SizedBox(height: 8),
            Text('Rating: ${doctor['rating']}/5.0'),
            const SizedBox(height: 8),
            const Text('Consultation Fee: Rs. 500'),
            const SizedBox(height: 16),
            const Text(
              'Choose consultation type:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showMessage('Starting text consultation...');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Text Chat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showMessage('Starting video consultation...');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Video Call'),
          ),
        ],
      ),
    );
  }

  void _openChat(Map<String, dynamic> conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          doctorName: conversation['doctorName'],
          doctorId: conversation['doctorId'],
        ),
      ),
    );
  }

  void _showNewConsultationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Consultation'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('What type of consultation do you need?'),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.blue),
              title: Text('Text Consultation'),
              subtitle: Text('Chat with a doctor via text'),
            ),
            ListTile(
              leading: Icon(Icons.video_call, color: Colors.green),
              title: Text('Video Consultation'),
              subtitle: Text('Face-to-face video call'),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.orange),
              title: Text('AI Diagnosis'),
              subtitle: Text('Upload photo for instant diagnosis'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showMessage('Starting consultation...');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Separate Chat Screen
class ChatScreen extends StatefulWidget {
  final String doctorName;
  final String doctorId;

  const ChatScreen({
    super.key,
    required this.doctorName,
    required this.doctorId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'text': 'Hello! I have a question about my tomato plants. The leaves are turning yellow.',
      'isUser': true,
      'timestamp': '10:30 AM',
    },
    {
      'id': '2',
      'text': 'Hi! I\'d be happy to help. Can you send me a photo of the affected leaves? Also, are the yellow leaves on the bottom or top of the plant?',
      'isUser': false,
      'timestamp': '10:31 AM',
    },
    {
      'id': '3',
      'text': 'They are mostly on the bottom leaves. I\'ll take a photo and send it.',
      'isUser': true,
      'timestamp': '10:32 AM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doctorName),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message['isUser'] 
                      ? Alignment.centerRight 
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: 8,
                      left: message['isUser'] ? 64 : 0,
                      right: message['isUser'] ? 0 : 64,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message['isUser'] 
                          ? Colors.orange 
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['text'],
                          style: TextStyle(
                            color: message['isUser'] 
                                ? Colors.white 
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message['timestamp'],
                          style: TextStyle(
                            color: message['isUser'] 
                                ? Colors.white.withOpacity(0.7)
                                : Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Attachment feature coming soon')),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': _messageController.text.trim(),
          'isUser': true,
          'timestamp': 'Now',
        });
      });
      _messageController.clear();
      
      // Simulate doctor reply
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _messages.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'text': 'Thank you for the information. Let me analyze this and get back to you.',
            'isUser': false,
            'timestamp': 'Now',
          });
        });
      });
    }
  }
}
