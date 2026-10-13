import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:math';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../models/market_price_models.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen>
    with SingleTickerProviderStateMixin {
  // final MarketService _marketService = MarketService();

  List<MarketPrice> _prices = [];
  List<MarketPrice> _filteredPrices = [];
  List<PriceAlert> _alerts = [];
  String _selectedCrop = 'All';
  String _selectedDistrict = 'All';
  String _selectedMarket = 'All';
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _showAdvancedFilters = false;
  String _searchQuery = '';
  bool _sortByPriceHighToLow = true;
  MarketChartType _chartType = MarketChartType.line;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _allCrops = [
    'All',
    'Rice',
    'Wheat',
    'Maize',
    'Potato',
    'Tomato',
    'Onion',
    'Carrot',
    'Cabbage',
    'Cauliflower',
    'Peas',
    'Lentils',
    'Mustard',
    'Sugarcane',
    'Tea',
    'Coffee'
  ];

  final List<String> _allDistricts = [
    'All',
    'Kathmandu',
    'Lalitpur',
    'Bhaktapur',
    'Chitwan',
    'Pokhara',
    'Biratnagar',
    'Birgunj',
    'Hetauda',
    'Janakpur',
    'Dharan',
    'Butwal',
    'Dhankuta',
    'Ilam',
    'Kavre',
    'Makwanpur',
    'Nawalparasi'
  ];

  List<String> _markets = ['All'];
  List<String> _filteredCrops = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _loadMarketData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketData() async {
    setState(() => _isLoading = true);

    try {
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate loading

      final mockPrices = _generateMockMarketData();
      final alerts = _generatePriceAlerts(mockPrices);
      final markets = mockPrices.map((p) => p.marketName).toSet().toList();

      if (mounted) {
        setState(() {
          _prices = mockPrices;
          _filteredPrices = mockPrices;
          _alerts = alerts;
          _markets = ['All', ...markets];
          _filteredCrops = _allCrops;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to load market data: $e');
      }
    }
  }

  List<MarketPrice> _generateMockMarketData() {
    final districts = _allDistricts.where((d) => d != 'All').toList();
    final crops = _allCrops.where((c) => c != 'All').toList();
    final markets = [
      'Kalimati Fruits and Vegetables Market',
      'Birgunj Agriculture Market',
      'Hetauda Wholesale Market',
      'Pokhara Retail Market',
      'Kathmandu Super Market'
    ];

    final random = Random();
    final now = DateTime.now();
    final List<MarketPrice> prices = [];

    for (final market in markets) {
      for (final crop in crops.take(8)) {
        final basePrice = random.nextInt(200) + 50; // Rs 50-250 per kg
        final trend = random.nextBool() ? PriceTrend.up : PriceTrend.down;
        final changePercent = random.nextDouble() * 15 - 7.5; // -7.5% to +7.5%

        prices.add(MarketPrice(
          id: '${market}_$crop',
          cropName: crop,
          marketName: market,
          district: districts[random.nextInt(districts.length)],
          pricePerKg: basePrice.toDouble(),
          priceChangePercent: changePercent,
          trend: trend,
          updatedAt: now.subtract(Duration(hours: random.nextInt(24))),
          demandIndex: random.nextDouble(),
          scarcityIndex: random.nextDouble(),
          qualityGrade: ['A', 'B', 'C'][random.nextInt(3)],
          transportationCost: random.nextInt(20) + 5,
        ));
      }
    }

    return prices;
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        setState(() {
          _prices = _generateMockMarketData();
          _applyFilters();
          _isRefreshing = false;
        });
        _showSuccess('Market prices updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRefreshing = false);
        _showError('Failed to refresh: $e');
      }
    }
  }

  void _applyFilters() {
    List<MarketPrice> result = _prices;

    // Apply crop filter
    if (_selectedCrop != 'All') {
      result = result.where((p) => p.cropName == _selectedCrop).toList();
    }

    // Apply district filter
    if (_selectedDistrict != 'All') {
      result = result.where((p) => p.district == _selectedDistrict).toList();
    }

    // Apply market filter
    if (_selectedMarket != 'All') {
      result = result.where((p) => p.marketName == _selectedMarket).toList();
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where((p) =>
              p.cropName.toLowerCase().contains(query) ||
              p.marketName.toLowerCase().contains(query) ||
              p.district.toLowerCase().contains(query))
          .toList();
    }

    // Apply sorting
    result.sort((a, b) {
      if (_sortByPriceHighToLow) {
        return b.pricePerKg.compareTo(a.pricePerKg);
      } else {
        return a.pricePerKg.compareTo(b.pricePerKg);
      }
    });

    // Update filtered crops
    final availableCrops = result.map((p) => p.cropName).toSet().toList();
    setState(() {
      _filteredPrices = result;
      _filteredCrops = ['All', ...availableCrops];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Prices'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: const Color(0xFF4CAF50).withValues(alpha: 0.3),
        actions: [
          IconButton(
            icon: Icon(
              _isRefreshing ? Icons.refresh : Icons.refresh_outlined,
              color: Colors.white,
            ),
            onPressed: _isRefreshing ? null : _refreshData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                if (_alerts.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_alerts.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _showPriceAlerts(),
            tooltip: 'Price Alerts',
          ),
          IconButton(
            icon: Icon(
              _showAdvancedFilters
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
              color: Colors.white,
            ),
            onPressed: () =>
                setState(() => _showAdvancedFilters = !_showAdvancedFilters),
            tooltip: 'Advanced Filters',
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _isLoading
                ? const _LoadingWidget()
                : RefreshIndicator(
                    onRefresh: _refreshData,
                    color: const Color(0xFF4CAF50),
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search and Stats
                          _buildSearchAndStats(),
                          const SizedBox(height: 16),

                          // Advanced Filters
                          if (_showAdvancedFilters) _buildAdvancedFilters(),

                          // Price Trends Chart
                          _buildPriceChart(),
                          const SizedBox(height: 20),

                          // Filters
                          _buildQuickFilters(),
                          const SizedBox(height: 20),

                          // Price List Header
                          _buildListHeader(),
                          const SizedBox(height: 12),

                          // Price List
                          _buildPriceList(),

                          // No Results
                          if (_filteredPrices.isEmpty) _buildNoResults(),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPriceAlertDialog(),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_alert),
        label: const Text('Set Alert'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildSearchAndStats() {
    final avgPrice = _filteredPrices.isNotEmpty
        ? _filteredPrices.map((p) => p.pricePerKg).reduce((a, b) => a + b) /
            _filteredPrices.length
        : 0.0;
    final risingCount =
        _filteredPrices.where((p) => p.trend == PriceTrend.up).length;
    final marketCount = _filteredPrices.map((p) => p.marketName).toSet().length;

    return Column(
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search crops, markets, or districts...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() => _searchQuery = '');
                        _applyFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _applyFilters();
            },
          ),
        ),
        const SizedBox(height: 16),

        // Stats Cards
        Row(
          children: [
            _buildStatCard(
              title: 'Avg Price',
              value: 'Rs. ${avgPrice.toStringAsFixed(0)}',
              icon: Icons.attach_money,
              color: const Color(0xFF4CAF50),
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              title: 'Rising',
              value: '$risingCount',
              icon: Icons.trending_up,
              color: Colors.green,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              title: 'Markets',
              value: '$marketCount',
              icon: Icons.store,
              color: Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Advanced Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _showAdvancedFilters = false),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildFilterChip(
                label:
                    'Sort: ${_sortByPriceHighToLow ? 'High to Low' : 'Low to High'}',
                icon: Icons.sort,
                onTap: () {
                  setState(
                      () => _sortByPriceHighToLow = !_sortByPriceHighToLow);
                  _applyFilters();
                },
              ),
              _buildFilterChip(
                label:
                    'Show: ${_chartType == MarketChartType.line ? 'Line Chart' : 'Bar Chart'}',
                icon: _chartType == MarketChartType.line
                    ? Icons.show_chart
                    : Icons.bar_chart,
                onTap: () {
                  setState(() {
                    _chartType = _chartType == MarketChartType.line
                        ? MarketChartType.bar
                        : MarketChartType.line;
                  });
                },
              ),
              _buildFilterChip(
                label: 'Only Rising Prices',
                icon: Icons.trending_up,
                onTap: () {
                  // Implement filter
                },
              ),
              _buildFilterChip(
                label: 'Quality: Grade A',
                icon: Icons.grade,
                onTap: () {
                  // Implement filter
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade700),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceChart() {
    if (_filteredPrices.isEmpty) return const SizedBox();

    final chartData = _filteredPrices.take(5).map((price) {
      return ChartData(price.cropName, price.pricePerKg);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price Trends',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _selectedCrop == 'All' ? 'Top 5 Crops' : _selectedCrop,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: _chartType == MarketChartType.line
                ? _buildLineChart(chartData)
                : _buildBarChart(chartData),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<ChartData> data) {
    if (data.isEmpty) return const SizedBox();

    final maxValue = data.map((d) => d.y).reduce(math.max);
    final minValue = data.map((d) => d.y).reduce(math.min);
    final range = maxValue - minValue;
    final padding = range * 0.1;
    final chartMax = maxValue + padding;
    final chartMin = math.max(0.0, minValue - padding).toDouble();

    return CustomPaint(
      painter: LineChartPainter(
        data: data,
        maxValue: chartMax,
        minValue: chartMin,
      ),
    );
  }

  Widget _buildBarChart(List<ChartData> data) {
    if (data.isEmpty) return const SizedBox();

    final maxValue = data.map((d) => d.y).reduce(math.max).toDouble();
    final minValue = data.map((d) => d.y).reduce(math.min).toDouble();
    final range = maxValue - minValue;
    final padding = range * 0.1;
    final chartMax = maxValue + padding;
    final chartMin = math.max(0.0, minValue - padding).toDouble();

    return CustomPaint(
      painter: BarChartPainter(
        data: data,
        maxValue: chartMax,
        minValue: chartMin,
      ),
    );
  }

  Widget _buildQuickFilters() {
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
                items: _filteredCrops,
                onChanged: (value) {
                  setState(() => _selectedCrop = value!);
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownFilter(
                label: 'District',
                value: _selectedDistrict,
                items: _allDistricts,
                onChanged: (value) {
                  setState(() => _selectedDistrict = value!);
                  _applyFilters();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdownFilter(
                label: 'Market',
                value: _selectedMarket,
                items: _markets,
                onChanged: (value) {
                  setState(() => _selectedMarket = value!);
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownFilter(
                label: 'Trend',
                value: 'All',
                items: ['All', 'Rising', 'Falling'],
                onChanged: (value) {
                  // Implement trend filter
                },
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: InputBorder.none,
            ),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Market Prices (${_filteredPrices.length} items)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: () => _showExportOptions(),
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Export'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceList() {
    if (_filteredPrices.isEmpty) return const SizedBox();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredPrices.length,
      itemBuilder: (context, index) {
        final price = _filteredPrices[index];
        return _MarketPriceCard(
          price: price,
          onTap: () => _showPriceDetails(price),
          onAlertTap: () => _showPriceAlertDialog(price.cropName),
        );
      },
    );
  }

  Widget _buildNoResults() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No matching prices found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters or search term',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showPriceDetails(MarketPrice price) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _PriceDetailsBottomSheet(price: price),
    );
  }

  void _showPriceAlertDialog([String? cropName]) {
    showDialog(
      context: context,
      builder: (context) => _PriceAlertDialog(
        cropName: cropName,
        onSave: () => _showSuccess('Price alert set successfully!'),
      ),
    );
  }

  void _showPriceAlerts() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Price Alerts'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
          body: ListView.builder(
            itemCount: _alerts.length,
            itemBuilder: (context, index) => _AlertListItem(
              alert: _alerts[index],
              onDismiss: () {
                setState(() => _alerts.removeAt(index));
                _showInfo('Alert dismissed');
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export as PDF'),
              onTap: () => _exportAsPDF(),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export as CSV'),
              onTap: () => _exportAsCSV(),
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Share via Email'),
              onTap: () => _shareViaEmail(),
            ),
          ],
        ),
      ),
    );
  }

  void _exportAsPDF() => _showInfo('PDF export coming soon!');
  void _exportAsCSV() => _showInfo('CSV export coming soon!');
  void _shareViaEmail() => _showInfo('Email sharing coming soon!');

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  List<PriceAlert> _generatePriceAlerts(List<MarketPrice> prices) {
    final random = Random();
    return prices
        .where((price) => random.nextDouble() > 0.7)
        .map((price) => PriceAlert(
              cropName: price.cropName,
              district: price.district,
              currentPrice: price.pricePerKg,
              priceChange: price.priceChangePercent,
              trend: price.trend,
              message:
                  '${price.cropName} price ${price.trend == PriceTrend.up ? 'increased' : 'decreased'} by ${price.priceChangePercent.abs().toStringAsFixed(1)}%',
              createdAt:
                  DateTime.now().subtract(Duration(hours: random.nextInt(24))),
            ))
        .toList();
  }
}

// Loading Widget
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading market data...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Market Price Card
class _MarketPriceCard extends StatelessWidget {
  final MarketPrice price;
  final VoidCallback onTap;
  final VoidCallback onAlertTap;

  const _MarketPriceCard({
    required this.price,
    required this.onTap,
    required this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price.cropName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${price.marketName}, ${price.district}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: price.trendColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: price.trendColor.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          price.trendIcon,
                          style: TextStyle(
                            color: price.trendColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${price.priceChangePercent.abs().toStringAsFixed(1)}%',
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rs. ${price.pricePerKg.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      Text(
                        'per kg • Grade: ${price.qualityGrade}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  CustomButton(
                    text: 'Alert',
                    onPressed: onAlertTap,
                    icon: Icons.notifications_outlined,
                    height: 36,
                    width: 80,
                    backgroundColor: Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Price Details Bottom Sheet
class _PriceDetailsBottomSheet extends StatelessWidget {
  final MarketPrice price;

  const _PriceDetailsBottomSheet({required this.price});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.store,
                                size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${price.marketName}, ${price.district}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          price.trendColor.withValues(alpha: 0.1),
                          price.trendColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${price.trendIcon} ${price.priceChangePercent > 0 ? '+' : ''}${price.priceChangePercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: price.trendColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Price Highlight
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Current Market Price',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rs. ${price.pricePerKg.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'per kilogram',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Details Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildDetailItem(
                      'Quality Grade', price.qualityGrade, Icons.grade),
                  _buildDetailItem(
                      'Demand Index',
                      '${(price.demandIndex * 100).toInt()}%',
                      Icons.trending_up),
                  _buildDetailItem(
                      'Supply Scarcity',
                      '${(price.scarcityIndex * 100).toInt()}%',
                      Icons.inventory),
                  _buildDetailItem('Transport Cost',
                      'Rs. ${price.transportationCost}', Icons.local_shipping),
                ],
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Set Price Alert',
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => _PriceAlertDialog(
                            cropName: price.cropName,
                            onSave: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Price alert set successfully!'),
                                  backgroundColor: Color(0xFF4CAF50),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      icon: Icons.notifications_active,
                      backgroundColor: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'View History',
                      onPressed: () => _showHistoryChart(context),
                      icon: Icons.timeline,
                      backgroundColor: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CustomButton(
                text: 'Compare with Other Markets',
                onPressed: () => _showMarketComparison(context),
                icon: Icons.compare,
                backgroundColor: Colors.blue,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: Colors.blue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHistoryChart(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Price History'),
        content: SizedBox(
          height: 300,
          child: _buildStaticLineChart([
            ChartData('Jan', 45),
            ChartData('Feb', 52),
            ChartData('Mar', 48),
            ChartData('Apr', 55),
            ChartData('May', 60),
            ChartData('Jun', 58),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildStaticLineChart(List<ChartData> data) {
    if (data.isEmpty) return const SizedBox();

    final maxValue = data.map((d) => d.y).reduce(max).toDouble();
    final minValue = data.map((d) => d.y).reduce(min).toDouble();
    final range = maxValue - minValue;
    final padding = range * 0.1;
    final chartMax = maxValue + padding;
    final chartMin = math.max(0.0, minValue - padding).toDouble();

    return CustomPaint(
      painter: LineChartPainter(
        data: data,
        maxValue: chartMax,
        minValue: chartMin,
      ),
    );
  }

  void _showMarketComparison(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Market Comparison'),
        content: SizedBox(
          height: 400,
          width: double.maxFinite,
          child: Column(
            children: [
              Text(
                  'Price comparison for ${price.cropName} across major markets:'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildComparisonItem('Kalimati Market', 'Kathmandu', 65.5),
                    _buildComparisonItem('Birgunj Market', 'Parsa', 62.0),
                    _buildComparisonItem('Hetauda Market', 'Makwanpur', 63.2),
                    _buildComparisonItem('Pokhara Market', 'Kaski', 67.8),
                    _buildComparisonItem('Biratnagar Market', 'Morang', 61.5),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(
      String market, String location, double priceValue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                market,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                location,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs. $priceValue',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              Text(
                'per kg',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Price Alert Dialog
class _PriceAlertDialog extends StatefulWidget {
  final String? cropName;
  final VoidCallback onSave;

  const _PriceAlertDialog({this.cropName, required this.onSave});

  @override
  __PriceAlertDialogState createState() => __PriceAlertDialogState();
}

class __PriceAlertDialogState extends State<_PriceAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cropController = TextEditingController();
  final _targetPriceController = TextEditingController();
  final _districtController = TextEditingController();
  AlertType _selectedAlertType = AlertType.above;
  NotificationMethod _selectedNotificationMethod = NotificationMethod.push;

  @override
  void initState() {
    super.initState();
    _cropController.text = widget.cropName ?? '';
  }

  @override
  void dispose() {
    _cropController.dispose();
    _targetPriceController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Price Alert'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _cropController,
                decoration: const InputDecoration(
                  labelText: 'Crop Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.agriculture),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter crop name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Price (Rs/kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter target price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(
                  labelText: 'District (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alert When Price Is:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Above Target'),
                          selected: _selectedAlertType == AlertType.above,
                          onSelected: (selected) {
                            setState(
                                () => _selectedAlertType = AlertType.above);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Below Target'),
                          selected: _selectedAlertType == AlertType.below,
                          onSelected: (selected) {
                            setState(
                                () => _selectedAlertType = AlertType.below);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Method:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<NotificationMethod>(
                    initialValue: _selectedNotificationMethod,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: NotificationMethod.push,
                        child: Row(
                          children: [
                            Icon(Icons.notifications, size: 16),
                            SizedBox(width: 8),
                            Text('Push Notification'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: NotificationMethod.email,
                        child: Row(
                          children: [
                            Icon(Icons.email, size: 16),
                            SizedBox(width: 8),
                            Text('Email'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: NotificationMethod.both,
                        child: Row(
                          children: [
                            Icon(Icons.notifications_active, size: 16),
                            SizedBox(width: 8),
                            Text('Both'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedNotificationMethod = value!);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave();
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
          ),
          child: const Text('Set Alert'),
        ),
      ],
    );
  }
}

// Alert List Item
class _AlertListItem extends StatelessWidget {
  final PriceAlert alert;
  final VoidCallback onDismiss;

  const _AlertListItem({
    required this.alert,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: alert.trendColor.withValues(alpha: 0.1),
          child: Icon(
            alert.trend == PriceTrend.up
                ? Icons.trending_up
                : Icons.trending_down,
            color: alert.trendColor,
          ),
        ),
        title: Text(
          alert.cropName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(alert.message),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  alert.district,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 12),
                Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${DateTime.now().difference(alert.createdAt).inHours}h ago',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDismiss,
        ),
      ),
    );
  }
}


// Custom Chart Painters
class LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double maxValue;
  final double minValue;

  LineChartPainter(
      {required this.data, required this.maxValue, required this.minValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Text painting setup

    // Draw grid lines
    const gridCount = 4;
    for (int i = 0; i <= gridCount; i++) {
      final y = size.height * (i / gridCount);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw data points and line
    if (data.length < 2) return;

    final points = <Offset>[];
    final pointPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = size.width * (i / (data.length - 1));
      final valueRange = maxValue - minValue;
      final y = size.height * (1.0 - (data[i].y - minValue) / valueRange);

      points.add(Offset(x, y));
      canvas.drawCircle(Offset(x, y), 3.0, pointPaint);
    }

    final path = Path();
    path.addPolygon(points, false);
    canvas.drawPath(path, paint);

    // Draw labels
    for (int i = 0; i < data.length; i++) {
      final x = size.width * (i / (data.length - 1));
      canvas.drawLine(
          Offset(x, size.height - 10), Offset(x, size.height), gridPaint);

      final textSpan = TextSpan(
        text: data[i].x,
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(x - textPainter.width / 2, size.height - 15));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BarChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double maxValue;
  final double minValue;

  BarChartPainter(
      {required this.data, required this.maxValue, required this.minValue});

  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    if (data.isEmpty) return;

    final barWidth = size.width / data.length * 0.6;
    final spacing = size.width / data.length * 0.4;

    // Draw grid lines
    const gridCount = 4;
    for (int i = 0; i <= gridCount; i++) {
      final y = size.height * (i / gridCount);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 0; i < data.length; i++) {
      final valueRange = maxValue - minValue;
      final barHeight = size.height * ((data[i].y - minValue) / valueRange);
      final x = i * (barWidth + spacing) + spacing / 2;
      final y = size.height - barHeight;

      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        barPaint,
      );

      // Draw labels
      final textSpan = TextSpan(
        text: data[i].x,
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas,
          Offset(x + barWidth / 2 - textPainter.width / 2, size.height - 15));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
