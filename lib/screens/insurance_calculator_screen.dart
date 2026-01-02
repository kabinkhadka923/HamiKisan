import 'package:flutter/material.dart';

class InsuranceCalculatorScreen extends StatefulWidget {
  const InsuranceCalculatorScreen({super.key});

  @override
  State<InsuranceCalculatorScreen> createState() => _InsuranceCalculatorScreenState();
}

class _InsuranceCalculatorScreenState extends State<InsuranceCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropValueController = TextEditingController();
  final _landAreaController = TextEditingController();
  final _productionCostController = TextEditingController();
  
  String _selectedCrop = 'Rice';
  double _premiumRate = 2.0;
  final double _subsidyPercentage = 50.0;
  double? _estimatedPremium;
  double? _farmerShare;
  double? _governmentSubsidy;
  double? _coverageAmount;

  final List<String> _crops = [
    'Rice', 'Wheat', 'Maize', 'Potato', 'Tomato', 'Onion', 'Cabbage', 'Lentils'
  ];

  void _calculateInsurance() {
    if (_formKey.currentState?.validate() ?? false) {
      final cropValue = double.parse(_cropValueController.text);
      final landArea = double.parse(_landAreaController.text);
      final productionCost = double.parse(_productionCostController.text);

      setState(() {
        _coverageAmount = cropValue * landArea;
        _estimatedPremium = (_coverageAmount! * _premiumRate) / 100;
        _governmentSubsidy = (_estimatedPremium! * _subsidyPercentage) / 100;
        _farmerShare = _estimatedPremium! - _governmentSubsidy!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Insurance Calculator'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Crop Insurance Calculator',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCrop,
                        decoration: const InputDecoration(
                          labelText: 'Select Crop',
                          border: OutlineInputBorder(),
                        ),
                        items: _crops.map((crop) {
                          return DropdownMenuItem(value: crop, child: Text(crop));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCrop = value!;
                            // Update premium rate based on crop
                            switch (value) {
                              case 'Rice':
                                _premiumRate = 2.0;
                                break;
                              case 'Wheat':
                                _premiumRate = 1.5;
                                break;
                              case 'Maize':
                                _premiumRate = 2.5;
                                break;
                              case 'Potato':
                                _premiumRate = 3.0;
                                break;
                              default:
                                _premiumRate = 2.0;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _cropValueController,
                        decoration: const InputDecoration(
                          labelText: 'Crop Value per Unit (Rs.)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter crop value';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _landAreaController,
                        decoration: const InputDecoration(
                          labelText: 'Land Area (in hectares)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter land area';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _productionCostController,
                        decoration: const InputDecoration(
                          labelText: 'Production Cost (Rs.)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter production cost';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _calculateInsurance,
                          child: const Text('Calculate Insurance'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            if (_estimatedPremium != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Insurance Calculation Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildResultRow('Coverage Amount', 'Rs. ${_coverageAmount!.toStringAsFixed(0)}'),
                      _buildResultRow('Premium Rate', '${_premiumRate.toStringAsFixed(1)}%'),
                      _buildResultRow('Total Premium', 'Rs. ${_estimatedPremium!.toStringAsFixed(0)}'),
                      _buildResultRow('Government Subsidy ($_subsidyPercentage%)', 'Rs. ${_governmentSubsidy!.toStringAsFixed(0)}'),
                      _buildResultRow('Farmer\'s Share', 'Rs. ${_farmerShare!.toStringAsFixed(0)}', isHighlighted: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insurance Benefits',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('Natural calamities coverage'),
                    ),
                    ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('Pest and disease protection'),
                    ),
                    ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('Price fluctuation protection'),
                    ),
                    ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('Quick claim settlement'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}
