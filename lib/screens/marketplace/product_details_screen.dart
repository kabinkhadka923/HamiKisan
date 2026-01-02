import 'package:flutter/material.dart';
import '../../models/marketplace_models.dart';
// For constants and utility

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images Carousel (or single image for now)
            if (product.imageUrls.isNotEmpty)
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(product.imageUrls.first),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      child: Text(
                        '${product.imageUrls.length} photos',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 250,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name & Verified Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF212121),
                          ),
                        ),
                      ),
                      if (product.isVerified)
                        const Icon(
                          Icons.verified,
                          size: 28,
                          color: Color(0xFF4CAF50),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price & Quantity
                  Text(
                    'Rs. ${product.price}/${product.unit} (${product.quantity} ${product.unit} available)',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category
                  _buildDetailRow(
                    context,
                    Icons.category_outlined,
                    'Category',
                    '${product.category} > ${product.subCategory}',
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    'Description:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Seller Info
                  _buildDetailRow(
                    context,
                    Icons.person_outline,
                    'Seller',
                    'ID: ${product.sellerId}', // In a real app, fetch seller name
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    context,
                    Icons.location_on_outlined,
                    'Location',
                    '${product.location}, ${product.district}',
                  ),
                  const SizedBox(height: 16),

                  // Quality, Organic
                  _buildDetailRow(
                    context,
                    Icons.star_half_outlined,
                    'Quality Grade',
                    product.qualityGrade,
                    color: _getQualityColor(product.qualityGrade),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    context,
                    Icons.local_florist_outlined,
                    'Organic',
                    product.isOrganic ? 'Yes' : 'No',
                    color: product.isOrganic ? const Color(0xFF4CAF50) : Colors.grey,
                  ),
                  const SizedBox(height: 16),

                  // Delivery Options (placeholder)
                  _buildDetailRow(
                    context,
                    Icons.delivery_dining_outlined,
                    'Delivery Options',
                    'Pickup, Home Delivery (Local)', // Placeholder
                  ),
                  const SizedBox(height: 16),

                  // Reviews & Rating (placeholder)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '4.5 (12 Reviews)', // Placeholder
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chat with Seller coming soon!')),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800), // Orange
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Buy Now coming soon!')),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart_outlined),
                          label: const Text('Buy Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50), // Primary Green
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color ?? const Color(0xFF757575)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF757575),
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color ?? const Color(0xFF212121),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getQualityColor(String grade) {
    switch (grade) {
      case 'A+':
        return const Color(0xFF4CAF50);
      case 'A':
        return const Color(0xFF8BC34A);
      case 'B+':
        return const Color(0xFFFFC107);
      case 'B':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
