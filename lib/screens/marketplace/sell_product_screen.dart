import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../providers/marketplace_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/marketplace_models.dart';
import '../../widgets/custom_button.dart';
import '../../services/marketplace_database_service.dart'; // For constants

class SellProductScreen extends StatefulWidget {
  const SellProductScreen({super.key});

  @override
  State<SellProductScreen> createState() => _SellProductScreenState();
}

class _SellProductScreenState extends State<SellProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String? _title;
  String? _description;
  String? _category;
  String? _subCategory;
  double? _price;
  String? _unit;
  double? _quantity;
  String? _location;
  String? _district;
  bool _isOrganic = false;
  String? _qualityGrade;
  final List<File> _images = [];

  @override
  Widget build(BuildContext context) {
    final marketplaceProvider = Provider.of<MarketplaceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell New Product'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Information',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Product Title',
                hint: 'e.g., Fresh Organic Tomatoes',
                onSaved: (value) => _title = value,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Description',
                hint: 'Provide a detailed description of your product',
                maxLines: 3,
                onSaved: (value) => _description = value,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),

              // Category & Subcategory Pickers
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                hint: const Text('Select Category'),
                items: MarketplaceCategory.allCategories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text('${category.icon} ${category.name}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value;
                    _subCategory = null; // Reset subcategory on category change
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),

              if (_category != null)
                DropdownButtonFormField<String>(
                  initialValue: _subCategory,
                  decoration: const InputDecoration(
                    labelText: 'Sub-Category',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  hint: const Text('Select Sub-Category'),
                  items: MarketplaceCategory.allCategories
                      .firstWhere((cat) => cat.id == _category!)
                      .subcategories
                      .map((sub) => DropdownMenuItem(value: sub, child: Text(sub)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _subCategory = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a sub-category' : null,
                ),
              const SizedBox(height: 16),

              // Price, Unit, Quantity
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      label: 'Price',
                      hint: 'Price per unit',
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _price = double.tryParse(value ?? ''),
                      validator: (value) => value == null || double.tryParse(value) == null ? 'Enter valid price' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      hint: const Text('Unit'),
                      items: MarketplaceConstants.priceUnits.map((unit) {
                        return DropdownMenuItem(value: unit, child: Text(unit));
                      }).toList(),
                      onChanged: (value) => setState(() => _unit = value),
                      validator: (value) => value == null ? 'Select unit' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Quantity',
                hint: 'Available quantity',
                keyboardType: TextInputType.number,
                onSaved: (value) => _quantity = double.tryParse(value ?? ''),
                validator: (value) => value == null || double.tryParse(value) == null ? 'Enter valid quantity' : null,
              ),
              const SizedBox(height: 16),

              // Location, District
              _buildTextField(
                label: 'Your Location',
                hint: 'e.g., Kathmandu, Thamel',
                onSaved: (value) => _location = value,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your location' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _district,
                decoration: const InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                hint: const Text('Select District'),
                items: MarketplaceConstants.nepaliDistricts.map((district) {
                  return DropdownMenuItem(value: district, child: Text(district));
                }).toList(),
                onChanged: (value) => setState(() => _district = value),
                validator: (value) => value == null ? 'Please select a district' : null,
              ),
              const SizedBox(height: 16),

              // Organic & Quality Grade
              SwitchListTile(
                title: const Text('Organic Product'),
                value: _isOrganic,
                onChanged: (value) => setState(() => _isOrganic = value),
                activeThumbColor: const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _qualityGrade,
                decoration: const InputDecoration(
                  labelText: 'Quality Grade',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                hint: const Text('Select Quality Grade'),
                items: MarketplaceConstants.qualityGrades.map((grade) {
                  return DropdownMenuItem(value: grade, child: Text(grade));
                }).toList(),
                onChanged: (value) => setState(() => _qualityGrade = value),
                validator: (value) => value == null ? 'Please select a quality grade' : null,
              ),
              const SizedBox(height: 16),

              // Product Images
              Text(
                'Product Images',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildImagePicker(),
              _buildImagePreviews(),
              const SizedBox(height: 32),

              // Submit Button
              marketplaceProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: 'Submit Product for Approval',
                      onPressed: () => _submitProduct(context, marketplaceProvider, authProvider),
                      isEnabled: true,
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    void Function(String?)? onSaved,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildImagePicker() {
    return CustomButton(
      text: 'Add Product Image',
      icon: Icons.camera_alt,
      onPressed: _pickImage,
      backgroundColor: Colors.blueGrey,
    );
  }

  Widget _buildImagePreviews() {
    if (_images.isEmpty) {
      return Container();
    }
    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _images.removeAt(index);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.remove_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  Future<void> _submitProduct(
    BuildContext context, 
    MarketplaceProvider marketplaceProvider, 
    AuthProvider authProvider,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to sell a product.')),
      );
      return;
    }

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one product image.')),
      );
      return;
    }

    List<String> imageUrls = _images.map((file) => file.path).toList(); // In a real app, upload to storage and get URLs

    final success = await marketplaceProvider.addProduct(
      sellerId: authProvider.currentUser!.id,
      title: _title!,
      description: _description!,
      category: _category!,
      subCategory: _subCategory!,
      imageUrls: imageUrls,
      price: _price!,
      unit: _unit!,
      quantity: _quantity!,
      location: _location!,
      district: _district!,
      qualityGrade: _qualityGrade!,
      isOrganic: _isOrganic,
      tags: [], // TODO: Add tag input
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product submitted for approval!')),
        );
        Navigator.of(context).pop(); // Go back to marketplace home
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit product: ${marketplaceProvider.error}')),
        );
      }
    }
  }
}
