import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/user.dart';
import '../../providers/kisan_doctor_provider.dart';
import '../../utils/app_colors.dart';

class FeedbackScreen extends StatelessWidget {
  final User doctor;

  const FeedbackScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('Feedback & Ratings'),
      ),
      body: Consumer<KisanDoctorProvider>(
        builder: (context, provider, _) {
          if (provider.feedback.isEmpty) {
            return const Center(child: Text('No feedback yet'));
          }

          final avgRating = provider.feedback.isEmpty
              ? 0.0
              : provider.feedback.map((f) => f.rating).reduce((a, b) => a + b) / provider.feedback.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Average Rating', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              avgRating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(
                                    5,
                                    (index) => Icon(
                                      Icons.star,
                                      color: index < avgRating.toInt() ? Colors.amber : Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                Text('${provider.feedback.length} ratings', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Feedback List
                Text('Recent Feedback', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.feedback.length,
                  itemBuilder: (context, index) {
                    final feedback = provider.feedback[index];
                    final dateFormat = DateFormat('MMM dd, yyyy');
                    final dateStr = dateFormat.format(feedback.createdAt);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Farmer: ${feedback.farmerId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      Icons.star,
                                      color: i < feedback.rating.toInt() ? Colors.amber : Colors.grey,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (feedback.comment != null) ...[
                              Text(feedback.comment!, style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 8),
                            ],
                            Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
