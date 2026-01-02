import 'package:flutter/material.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final TextEditingController _landAreaController = TextEditingController();
  final TextEditingController _cropTypeController = TextEditingController();
  final TextEditingController _groundWaterLevelController = TextEditingController();

  String _selectedCalcType = 'fertilizer';
  String _selectedSoilType = 'loam';
  String _selectedCropType = 'rice';
  String _irrigationType = 'flood';

  Map<String, dynamic> _calcResult = {};

  final List<Map<String, dynamic>> _tools = [
    {
      'icon': Icons.calculate,
      'title': 'Fertilizer Calculator',
      'subtitle': 'Calculate fertilizer needs',
      'color': Colors.green,
      'type': 'fertilizer',
    },
    {
      'icon': Icons.water_drop,
      'title': 'Irrigation Calculator',
      'subtitle': 'Water requirement calculation',
      'color': Colors.blue,
      'type': 'irrigation',
    },
    {
      'icon': Icons.terrain,
      'title': 'Soil Testing Guide',
      'subtitle': 'Soil health assessment',
      'color': Colors.brown,
      'type': 'soil',
    },
    {
      'icon': Icons.pest_control,
      'title': 'Pesticide Calculator',
      'subtitle': 'Chemical application rates',
      'color': Colors.red,
      'type': 'pesticide',
    },
    {
      'icon': Icons.agriculture,
      'title': 'Crop Calendar',
      'subtitle': 'Planting and harvesting schedule',
      'color': Colors.orange,
      'type': 'calendar',
    },
    {
      'icon': Icons.account_balance_wallet,
      'title': 'Profit Calculator',
      'subtitle': 'Cost and profit analysis',
      'color': Colors.purple,
      'type': 'profit',
    },
  ];

  final Map<String, List<String>> _cropData = {
    'rice': ['N: 120-150 kg/ha', 'P: 60-80 kg/ha', 'K: 40-60 kg/ha'],
    'wheat': ['N: 100-120 kg/ha', 'P: 50-60 kg/ha', 'K: 30-40 kg/ha'],
    'corn': ['N: 150-180 kg/ha', 'P: 70-90 kg/ha', 'K: 40-50 kg/ha'],
    'potato': ['N: 180-200 kg/ha', 'P: 90-100 kg/ha', 'K: 120-140 kg/ha'],
    'tomato': ['N: 100-120 kg/ha', 'P: 50-60 kg/ha', 'K: 100-120 kg/ha'],
  };

  @override
  void dispose() {
    _landAreaController.dispose();
    _cropTypeController.dispose();
    _groundWaterLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Tools'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showMessage('Calculation history'),
          ),
        ],
      ),
      body: _buildSelectedTool(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showToolSelector(),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        child: const Icon(Icons.swap_horiz),
      ),
    );
  }

  Widget _buildSelectedTool() {
    switch (_selectedCalcType) {
      case 'fertilizer':
        return _buildFertilizerCalculator();
      case 'irrigation':
        return _buildIrrigationCalculator();
      case 'soil':
        return _buildSoilTestingGuide();
      case 'pesticide':
        return _buildPesticideCalculator();
      case 'calendar':
        return _buildCropCalendar();
      case 'profit':
        return _buildProfitCalculator();
      default:
        return _buildToolSelectorGrid();
    }
  }

  Widget _buildFertilizerCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToolHeader('Fertilizer Calculator', Icons.calculate, Colors.green),
          const SizedBox(height: 20),

          TextField(
            controller: _landAreaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Land Area (hectares)',
              border: OutlineInputBorder(),
              suffixText: 'ha',
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _selectedCropType,
            decoration: const InputDecoration(
              labelText: 'Crop Type',
              border: OutlineInputBorder(),
            ),
            items: _cropData.keys.map((crop) {
              return DropdownMenuItem(
                value: crop,
                child: Text(crop.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedCropType = value!),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _selectedSoilType,
            decoration: const InputDecoration(
              labelText: 'Soil Type',
              border: OutlineInputBorder(),
            ),
            items: ['loam', 'sandy', 'clay', 'silt'].map((soil) {
              return DropdownMenuItem(
                value: soil,
                child: Text(soil.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedSoilType = value!),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _calculateFertilizer,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),

          if (_calcResult.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildResultsCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildIrrigationCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToolHeader('Irrigation Calculator', Icons.water_drop, Colors.blue),
          const SizedBox(height: 20),

          TextField(
            controller: _landAreaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Land Area (hectares)',
              border: OutlineInputBorder(),
              suffixText: 'ha',
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _groundWaterLevelController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Groundwater Level (meters)',
              border: OutlineInputBorder(),
              suffixText: 'm',
            ),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _irrigationType,
            decoration: const InputDecoration(
              labelText: 'Irrigation Method',
              border: OutlineInputBorder(),
            ),
            items: [
              'flood',
              'sprinkler',
              'drip',
              'rainfed',
            ].map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(method.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) => setState(() => _irrigationType = value!),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _calculateIrrigation,
            icon: const Icon(Icons.water_drop),
            label: const Text('Calculate Water Need'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),

          if (_calcResult.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildResultsCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildPesticideCalculator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Pesticide Calculator',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('Coming Soon - Pesticide dosage calculations'),
        ],
      ),
    );
  }

  Widget _buildCropCalendar() {
    final cropCalendar = {
      'Rice': {
        'Sowing Season': 'June - July',
        'Transplanting': 'July - August',
        'Harvesting': 'October - November',
        'Duration': '120-150 days',
      },
      'Wheat': {
        'Sowing Season': 'November - December',
        'Harvesting': 'March - April',
        'Duration': '90-120 days',
      },
      'Corn': {
        'Sowing Season': 'March - April',
        'Harvesting': 'July - August',
        'Duration': '80-100 days',
      },
      'Potato': {
        'Sowing Season': 'October - November',
        'Harvesting': 'January - February',
        'Duration': '100-120 days',
      },
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToolHeader('Crop Calendar', Icons.calendar_today, Colors.orange),
          const SizedBox(height: 20),
          ...cropCalendar.entries.map((entry) => Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...entry.value.entries.map((detail) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            detail.key,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          detail.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProfitCalculator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up, size: 64, color: Colors.purple),
          SizedBox(height: 16),
          Text(
            'Profit Calculator',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text('Coming Soon - Cost and profit analysis'),
        ],
      ),
    );
  }

  Widget _buildSoilTestingGuide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToolHeader('Soil Testing Guide', Icons.terrain, Colors.brown),
          const SizedBox(height: 20),

          _buildSoilTestInfo(),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Soil Test Results Interpretation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSoilParameterTable(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          _buildRecommendedLabTests(),
        ],
      ),
    );
  }

  Widget _buildToolHeader(String title, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolSelectorGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _tools.length,
      itemBuilder: (context, index) {
        final tool = _tools[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => setState(() => _selectedCalcType = tool['type']),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tool['icon'],
                    size: 32,
                    color: tool['color'],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tool['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tool['subtitle'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsCard() {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _calcResult.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSoilTestInfo() {
    final soilTests = [
      {
        'title': 'pH Level Test',
        'description': 'Check soil acidity/alkalinity',
        'method': 'Litmus paper or pH meter (optimal: 6.0-7.0)',
      },
      {
        'title': 'Nitrogen Content',
        'description': 'Essential for plant growth',
        'method': 'Soil sample analysis at lab',
      },
      {
        'title': 'Phosphorus Level',
        'description': 'Important for root development',
        'method': 'Colorimetric test or lab analysis',
      },
      {
        'title': 'Potassium Content',
        'description': 'Affects fruit quality',
        'method': 'Flame photometry or lab test',
      },
    ];

    return Column(
      children: soilTests.map((test) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test['title']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(test['description']!),
                const SizedBox(height: 8),
                Text(
                  test['method']!,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSoilParameterTable() {
    final soilParams = [
      ['Parameter', 'Low', 'Optimal', 'High', 'Action Required'],
      ['pH', '< 5.5', '6.0-7.0', '> 7.5', 'Lime/Acid additions'],
      ['Nitrogen', '< 10 ppm', '20-30 ppm', '> 40 ppm', 'Fertilizer adjustment'],
      ['Phosphorus', '< 5 ppm', '10-15 ppm', '> 20 ppm', 'Fertilizer adjustment'],
      ['Potassium', '< 50 ppm', '100-150 ppm', '> 200 ppm', 'Fertilizer adjustment'],
      ['Organic Matter', '< 1%', '2-3%', '> 4%', 'Compost/Manure addition'],
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: soilParams[0].map((header) => DataColumn(
          label: Text(header, style: const TextStyle(fontWeight: FontWeight.bold)),
        )).toList(),
        rows: soilParams.skip(1).map((row) => DataRow(
          cells: row.map((cell) => DataCell(Text(cell))).toList(),
        )).toList(),
      ),
    );
  }

  Widget _buildRecommendedLabTests() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommended Testing Labs in Nepal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please note: Actual soil testing should be done at accredited laboratories for accurate results.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            _buildLabInfo('National Soil Fertility Research Center', 'Rampur, Chitwan'),
            _buildLabInfo('Regional Agricultural Research Station', 'Tarahara, Sunsari'),
            _buildLabInfo('District Agriculture Offices', 'Your local district'),
          ],
        ),
      ),
    );
  }

  Widget _buildLabInfo(String name, String location) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.location_on, size: 16, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _calculateFertilizer() {
    final area = double.tryParse(_landAreaController.text) ?? 0;
    if (area <= 0) {
      _showMessage('Please enter valid land area');
      return;
    }

    final recommendations = _cropData[_selectedCropType]!;
    final adjustedRec = recommendations.map((rec) {
      final parts = rec.split(': ');
      final nutrient = parts[0];
      final amount = parts[1];

      // Apply soil type adjustments
      double adjustmentFactor = 1.0;
      switch (_selectedSoilType) {
        case 'sandy':
          adjustmentFactor = 0.8; // Sandy soil retains less nutrients
          break;
        case 'clay':
          adjustmentFactor = 1.2; // Clay soil retains more nutrients
          break;
        case 'silt':
          adjustmentFactor = 1.1; // Silt soil medium retention
          break;
        default: // loam
          adjustmentFactor = 1.0;
          break;
      }

      final baseAmount = double.parse(amount.split(' ')[0]);
      final adjustedAmount = (baseAmount * adjustmentFactor * area).round();
      return '$nutrient: ${adjustedAmount}kg for ${area}ha';
    }).toList();

    setState(() {
      _calcResult = {
        'Land Area': '$area hectares',
        'Crop Type': _selectedCropType.toUpperCase(),
        'Soil Type': _selectedSoilType.toUpperCase(),
        'NPK Recommendations': '',
        ...adjustedRec.asMap().map((i, rec) => MapEntry('Nutrient ${i + 1}', rec)),
      };
    });
  }

  void _calculateIrrigation() {
    final area = double.tryParse(_landAreaController.text) ?? 0;
    final groundwaterLevel = double.tryParse(_groundWaterLevelController.text) ?? 0;

    if (area <= 0) {
      _showMessage('Please enter valid land area');
      return;
    }

    // Calculate irrigation requirement based on method
    double waterRequirementM3 = 0;
    String irrigationAdvice = '';

    switch (_irrigationType) {
      case 'flood':
        waterRequirementM3 = area * 1000 * 0.08; // 8cm water depth
        irrigationAdvice = 'Traditional flood irrigation - good for rice';
        break;
      case 'sprinkler':
        waterRequirementM3 = area * 1000 * 0.06; // 6cm water depth
        irrigationAdvice = 'Efficient for field crops, reduces evaporation';
        break;
      case 'drip':
        waterRequirementM3 = area * 1000 * 0.04; // 4cm water depth
        irrigationAdvice = 'Most efficient method, use for high-value crops';
        break;
      default: // rainfed
        irrigationAdvice = 'Rainfed agriculture - monitor rainfall patterns';
        break;
    }

    // Consider groundwater level
    String groundwaterAdvice = '';
    if (groundwaterLevel > 10) {
      groundwaterAdvice = 'High groundwater table - monitor for salinity';
    } else if (groundwaterLevel < 5) {
      groundwaterAdvice = 'Low groundwater - conserve water, avoid deep tubewells';
    } else {
      groundwaterAdvice = 'Normal groundwater levels - sustainable use possible';
    }

    final litersNeeded = (waterRequirementM3 * 1000).round();
    final hoursNeeded = (litersNeeded / 1000).round(); // Assuming 1000 liters per hour pump

    setState(() {
      _calcResult = {
        'Land Area': '$area hectares',
        'Irrigation Method': _irrigationType.toUpperCase(),
        'Water Required': '${litersNeeded.toString()} liters',
        'Irrigation Time': '~$hoursNeeded hours',
        'Groundwater Advice': groundwaterAdvice,
        'Method Recommendation': irrigationAdvice,
      };
    });
  }

  void _showToolSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Tool',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _tools.map((tool) {
                return ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _selectedCalcType = tool['type']);
                    Navigator.pop(context);
                  },
                  icon: Icon(tool['icon']),
                  label: Text(tool['title']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tool['color'],
                    foregroundColor: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
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
