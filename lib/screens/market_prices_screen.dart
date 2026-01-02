import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/market_service.dart';
import '../widgets/custom_button.dart';
import '../models/user.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  final MarketService _marketService = MarketService();
  
  List<MarketPrice> _prices = [];
  List<PriceAlert> _alerts = [];
  String _selectedCrop = 'All';
  String _selectedDistrict = 'All';
  bool _isLoading = true;
  bool _isRefreshing = false;

  final List<String> _crops = [
    'All', 'Rice', 'Wheat', 'Maize', 'Potato', 'Tomato', 'Onion', 'Carrot'
  ];
  
  final List<String> _districts = [
    'All', 'Kathmandu', 'Lalitpur', 'Bhaktapur', 'Chitwan', 'Pokhara',
    'Biratnagar', 'Birgunj', 'Hetauda', 'Janakpur', 'Dharan'
  ];

  @override
  void initState() {
    super.initState();
    _loadMarketData();
  }

  Future<void> _loadMarketData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prices = await _marketService.getCurrentPrices();
      final alerts = await _marketService.getPriceAlerts();
      
      if (mounted) {
        setState(() {
          _prices = prices;
          _alerts = alerts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Failed to load market data: $e');
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final prices = await _marketService.getCurrentPrices();
      
      if (mounted) {
        setState(() {
          _prices = prices;
          _isRefreshing = false;
        });
        _showInfo('Market prices updated');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
        _showError('Failed to refresh: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Prices / बजार मूल्य'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isRefreshing ? Icons.refresh : Icons.refresh_outlined),
            onPressed: _isRefreshing ? null : _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showPriceAlerts(),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return RefreshIndicator(
            onRefresh: _refreshData,
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildMainContent(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPriceAlertDialog(),
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add_alert, color: Colors.white),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with statistics
          _buildHeaderStats(),
          const SizedBox(height: 20),
          
          // Filters
          _buildFilters(),
          const SizedBox(height: 20),
          
          // Price List
          _buildPriceList(),
          const SizedBox(height: 20),
          
          // Recent Alerts
          if (_alerts.isNotEmpty) ...[
            _buildRecentAlerts(),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    final totalMarkets = _prices.length;
    final averageRicePrice = _prices
        .where((p) => p.cropName == 'Rice')
        .fold<double>(0.0, (sum, p) => sum + p.pricePerKg) /
        max(_prices.where((p) => p.cropName == 'Rice').length, 1);
    
    final risingPrices = _prices.where((p) => p.trend == PriceTrend.up).length;
    final fallingPrices = _prices.where((p) => p.trend == PriceTrend.down).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.store,
                  title: 'Markets',
                  value: '$totalMarkets',
                  subtitle: 'Total Markets',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.arrow_upward,
                  title: 'Rice Avg',
                  value: 'Rs. ${averageRicePrice.toStringAsFixed(0)}',
                  subtitle: 'Per kg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  title: '$risingPrices',
                  value: 'Rising',
                  subtitle: 'Price Trends',
                  color: Colors.green.shade300,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_down,
                  title: '$fallingPrices',
                  value: 'Falling',
                  subtitle: 'Price Trends',
                  color: Colors.red.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filters / फिल्टरहरू',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdownFilter(
                label: 'Crop',
                value: _selectedCrop,
                items: _crops,
                onChanged: (value) => setState(() => _selectedCrop = value!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownFilter(
                label: 'District',
                value: _selectedDistrict,
                items: _districts,
                onChanged: (value) => setState(() => _selectedDistrict = value!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPriceList() {
    final filteredPrices = _getFilteredPrices();

    if (filteredPrices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No prices found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredPrices.length,
      itemBuilder: (context, index) {
        final price = filteredPrices[index];
        return _buildPriceCard(price);
      },
    );
  }

  Widget _buildPriceCard(MarketPrice price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showPriceDetails(price),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price.cropName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${price.district} • ${price.marketName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: price.trendColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          price.trendIcon,
                          style: TextStyle(color: price.trendColor),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          price.trendText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: price.trendColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price.formattedPrice,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        Text(
                          'Updated: ${price.formattedDate}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomButton(
                    text: 'Alert',
                    onPressed: () => _showPriceAlertDialog(price.cropName),
                    icon: Icons.notifications,
                    height: 36,
                    width: 80,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Alerts / हालका अलर्टहरू',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _alerts.take(3).map((alert) => _buildAlertItem(alert)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertItem(PriceAlert alert) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF4CAF50),
        child: Text(
          alert.cropName[0],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        alert.message,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        '${alert.formattedPriceChange} • ${alert.district}',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Icon(
        alert.trend == PriceTrend.up ? Icons.trending_up : Icons.trending_down,
        color: alert.trendColor,
      ),
      onTap: () => _showAlertDetails(alert),
    );
  }

  List<MarketPrice> _getFilteredPrices() {
    return _prices.where((price) {
      final cropMatch = _selectedCrop == 'All' || price.cropName.contains(_selectedCrop);
      final districtMatch = _selectedDistrict == 'All' || price.district.contains(_selectedDistrict);
      return cropMatch && districtMatch;
    }).toList();
  }

  void _showPriceDetails(MarketPrice price) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPriceDetailsSheet(price),
    );
  }

  Widget _buildPriceDetailsSheet(MarketPrice price) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price.cropName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${price.district} • ${price.marketName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: price.trendColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(price.trendIcon),
                      const SizedBox(width: 4),
                      Text(
                        price.trendText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: price.trendColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Price
            Center(
              child: Column(
                children: [
                  Text(
                    price.formattedPrice,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  Text(
                    'Current Price',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Set Alert',
                    onPressed: () => _showPriceAlertDialog(price.cropName),
                    icon: Icons.notifications,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'History',
                    onPressed: () => _showPriceHistory(price.cropName),
                    icon: Icons.history,
                    backgroundColor: const Color(0xFFFFA726),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceAlertDialog([String? cropName]) {
    final cropController = TextEditingController(text: cropName ?? '');
    final priceController = TextEditingController();
    final districtController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Price Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cropController,
              decoration: const InputDecoration(
                labelText: 'Crop Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Price (Rs/kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: districtController,
              decoration: const InputDecoration(
                labelText: 'District (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (cropController.text.isNotEmpty && priceController.text.isNotEmpty) {
                await _marketService.savePriceAlertPreference(
                  cropName: cropController.text,
                  targetPrice: double.parse(priceController.text),
                  district: districtController.text.isNotEmpty ? districtController.text : 'All',
                );
                Navigator.of(context).pop();
                _showInfo('Price alert set successfully!');
              }
            },
            child: const Text('Set Alert'),
          ),
        ],
      ),
    );
  }

  void _showPriceAlerts() {
    // TODO: Implement full alerts screen
    _showInfo('Full alerts screen coming soon!');
  }

  void _showAlertDetails(PriceAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Price Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert.message,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Crop: ${alert.cropName}'),
            Text('District: ${alert.district}'),
            Text('Current Price: Rs. ${alert.currentPrice.toStringAsFixed(2)}'),
            Text('Change: ${alert.formattedPriceChange}'),
            Text('Created: ${alert.createdAt.day}/${alert.createdAt.month}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _showPriceHistory(String cropName) {
    // TODO: Implement price history chart
    _showInfo('Price history for $cropName coming soon!');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }
}
