import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../models/kisan_doctor_models.dart';
import '../../providers/kisan_doctor_provider.dart';
import '../../utils/app_colors.dart';
import '../video_call_screen.dart';

class ConsultationScreen extends StatefulWidget {
  final User doctor;
  final CaseStatus? initialStatusFilter;

  const ConsultationScreen({
    super.key,
    required this.doctor,
    this.initialStatusFilter,
  });

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _solutionController = TextEditingController();
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _fertilizerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<KisanDoctorProvider>(
      builder: (context, provider, _) {
        if (provider.selectedCase == null) {
          return _buildCasesList(provider);
        }
        return _buildCaseDetail(provider);
      },
    );
  }

  Widget _buildCasesList(KisanDoctorProvider provider) {
    final visibleCases = widget.initialStatusFilter == null
        ? provider.cases
        : provider.cases
            .where((case_) => case_.status == widget.initialStatusFilter)
            .toList();
    final title = widget.initialStatusFilter == CaseStatus.ongoing
        ? 'Pending Queries'
        : 'Consultations';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(title),
      ),
      body: visibleCases.isEmpty
          ? Center(
              child: Text(
                widget.initialStatusFilter == CaseStatus.ongoing
                    ? 'No pending queries'
                    : 'No cases available',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: visibleCases.length,
              itemBuilder: (context, index) {
                final case_ = visibleCases[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.agriculture,
                          color: AppColors.primaryGreen),
                    ),
                    title: Text(case_.cropType,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(case_.problemDescription,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(case_.status.name),
                          backgroundColor: _getStatusColor(case_.status),
                        ),
                      ],
                    ),
                    onTap: () => provider.selectCase(case_.caseId),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildCaseDetail(KisanDoctorProvider provider) {
    final case_ = provider.selectedCase!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('Case Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => provider.clearSelection(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoCallScreen(
                    doctorName: widget.doctor.name,
                    doctorSpecialty: 'Medical Consultant',
                    callId: case_.caseId,
                    recipientId: case_.farmerId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Case Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Crop: ${case_.cropType}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Problem: ${case_.problemDescription}'),
                    const SizedBox(height: 8),
                    Text('Status: ${case_.status.name}',
                        style: TextStyle(color: _getStatusColor(case_.status))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Chat Messages
            Row(
              children: [
                Text('Chat History',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                const Icon(Icons.security, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                const Text('E2EE Secured',
                    style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: provider.currentCaseMessages.isEmpty
                  ? const Center(child: Text('No messages yet'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: provider.currentCaseMessages.length,
                      itemBuilder: (context, index) {
                        final msg = provider.currentCaseMessages[index];
                        return Align(
                          alignment: msg.senderId == widget.doctor.id
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: msg.senderId == widget.doctor.id
                                  ? AppColors.primaryGreen
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  msg.messageText,
                                  style: TextStyle(
                                    color: msg.senderId == widget.doctor.id
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Icon(
                                  Icons.lock_outline,
                                  size: 10,
                                  color: msg.senderId == widget.doctor.id
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),

            // Send Message
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type message...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      provider.sendMessage(
                        caseId: case_.caseId,
                        senderId: widget.doctor.id,
                        messageText: _messageController.text,
                      );
                      _messageController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Solution Form
            Text('Provide Solution',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _solutionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe the solution...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _medicineController,
              decoration: InputDecoration(
                hintText: 'Medicine recommendation...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fertilizerController,
              decoration: InputDecoration(
                hintText: 'Fertilizer recommendation...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      provider.updateCaseWithSolution(
                        caseId: case_.caseId,
                        solution: _solutionController.text,
                        medicineRecommendation: _medicineController.text,
                        fertilizerRecommendation: _fertilizerController.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solution updated')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen),
                    child: const Text('Update Solution',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      provider.closeCase(case_.caseId);
                      provider.clearSelection();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Case closed')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    child: const Text('Close Case',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(CaseStatus status) {
    switch (status) {
      case CaseStatus.new_:
        return Colors.orange;
      case CaseStatus.ongoing:
        return Colors.blue;
      case CaseStatus.resolved:
        return Colors.green;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _solutionController.dispose();
    _medicineController.dispose();
    _fertilizerController.dispose();
    super.dispose();
  }
}
