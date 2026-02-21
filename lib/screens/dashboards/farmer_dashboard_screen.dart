import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../services/weather_service.dart';
import '../../services/market_service.dart';
import '../../services/farmer_listing_service.dart';
import '../../models/weather_models.dart';
import '../../models/post_model.dart';
import '../../screens/post_detail_screen.dart';
import '../../screens/profile_screen.dart';
import '../consultation_contacts_screen.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  int _selectedIndex = 0;
  bool _isVisible = true;
  final ScrollController _scrollController = ScrollController();

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      _HomeContent(scrollController: _scrollController),
      _MarketContent(scrollController: _scrollController),
      _AddContent(),
      _CommunityContent(scrollController: _scrollController),
      const ProfileScreen(hasScaffold: false),
    ];
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isVisible) setState(() => _isVisible = false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isVisible) setState(() => _isVisible = true);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications,
                      color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Text('Notifications',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Price Alerts',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildNotificationItem(
                      'Price Surge',
                      'Tomato price increased by 15%',
                      Icons.trending_up,
                      Colors.orange,
                      'Now'),
                  _buildNotificationItem('High Demand', 'Ginger in high demand',
                      Icons.trending_up, Colors.orange, 'Now'),
                  const SizedBox(height: 16),
                  const Text('Recent Activity',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildNotificationItem(
                      'Dr. Sharma replied',
                      'Your crop query has been answered',
                      Icons.message,
                      Colors.blue,
                      '2h ago'),
                  _buildNotificationItem(
                      'New Order',
                      '50kg Rice order received',
                      Icons.shopping_cart,
                      Colors.green,
                      '5h ago'),
                  _buildNotificationItem(
                      'Community Post',
                      '3 new posts in Organic Farming',
                      Icons.forum,
                      Colors.purple,
                      '1d ago'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
      String title, String message, IconData icon, Color color, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(message,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }

  void _showFarmingCalendar(BuildContext context) {
    final homeState = context.findAncestorStateOfType<_HomeContentState>();
    final forecast = homeState?._forecast ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      const Text('Farming Calendar',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  if (forecast.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: forecast.length,
                        itemBuilder: (context, index) {
                          final day = forecast[index];
                          final dayName = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ][index % 7];
                          return Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(dayName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 11)),
                                const SizedBox(height: 4),
                                Icon(_getWeatherIcon(day.weatherType),
                                    size: 20, color: Colors.white),
                                const SizedBox(height: 4),
                                Text('${day.temperature.toStringAsFixed(0)}°C',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.white)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  _buildCalendarTask(Icons.water_drop, 'Water tomatoes',
                      'Today, 6:00 AM', Colors.blue),
                  _buildCalendarTask(Icons.science, 'Apply fertilizer',
                      'Tomorrow', Colors.green),
                  _buildCalendarTask(
                      Icons.cut, 'Harvest wheat', 'In 3 days', Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String type) {
    switch (type.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'rainy':
        return Icons.water_drop;
      case 'cloudy':
        return Icons.cloud;
      case 'partly cloudy':
        return Icons.wb_cloudy;
      default:
        return Icons.wb_cloudy;
    }
  }

  Widget _buildCalendarTask(
      IconData icon, String task, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(time,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Checkbox(value: false, onChanged: (v) {}),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isVisible
          ? AppBar(
              title: Row(
                children: [
                  Image.asset(
                    'assets/logo/logo.png',
                    height: 80,
                    width: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.agriculture,
                          color: Colors.white, size: 28);
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text('HamiKisan',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
              backgroundColor: const Color(0xFF4CAF50),
              actions: [
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () => _showFarmingCalendar(context),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () => _showNotifications(context),
                ),
              ],
            )
          : null,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: _isVisible
          ? BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'Market',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline),
                  label: 'Add',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Community',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFF4CAF50),
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
            )
          : null,
    );
  }
}

class _HomeContent extends StatefulWidget {
  final ScrollController scrollController;
  const _HomeContent({required this.scrollController});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
    with SingleTickerProviderStateMixin {
  final _weatherService = WeatherService();
  final _marketService = MarketService();
  WeatherData? _weather;
  List<WeatherData> _forecast = [];
  List<MarketPrice> _marketPrices = [];
  bool _loading = true;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _weatherService.initialize();
    await _marketService.initialize();
    final location = await LocationService().getCurrentLocation();
    final weather =
        await _weatherService.getCurrentWeather(location.$1, location.$2);
    final forecast =
        await _weatherService.getWeeklyForecast(location.$1, location.$2);
    final prices = await _marketService.getDailyMarketPrices();
    setState(() {
      _weather = weather;
      _forecast = forecast;
      _marketPrices = prices;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final kalimatiItems = _marketPrices
        .where((item) =>
            item.location == 'Kathmandu' && item.priceChangePercent > 0)
        .toList()
      ..sort((a, b) => b.priceChangePercent.compareTo(a.priceChangePercent));

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/background/bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withValues(alpha: 0.3),
            BlendMode.darken,
          ),
          onError: (exception, stackTrace) {},
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_weather != null)
                _buildWeatherWithStatsAndMarket(_weather!, kalimatiItems),
              const SizedBox(height: 16),
              _buildPostsAndNews(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherWithStatsAndMarket(
      WeatherData weather, List<MarketPrice> kalimatiItems) {
    IconData weatherIcon;
    switch (weather.weatherType.toLowerCase()) {
      case 'sunny':
        weatherIcon = Icons.wb_sunny;
        break;
      case 'rainy':
        weatherIcon = Icons.water_drop;
        break;
      case 'cloudy':
      case 'partly cloudy':
        weatherIcon = Icons.cloud;
        break;
      default:
        weatherIcon = Icons.wb_cloudy;
    }

    return Card(
      elevation: 4,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Icon(weatherIcon, color: Colors.white, size: 48),
                      const SizedBox(height: 8),
                      Text('${weather.temperature.toStringAsFixed(0)}°C',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(weather.weatherType,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 2),
                          Text(weather.location,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.water_drop,
                                  size: 16, color: Colors.white),
                              Text('${weather.humidity.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white)),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.air,
                                  size: 16, color: Colors.white),
                              Text(
                                  '${weather.windSpeed.toStringAsFixed(0)}km/h',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white)),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.umbrella,
                                  size: 16, color: Colors.white),
                              Text('${weather.rainChance}%',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildFarmingSuitability(weather),
                    ],
                  ),
                ),
                Container(
                    width: 1,
                    height: 160,
                    color: Colors.white.withValues(alpha: 0.3)),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      children: [
                        _buildStatItem(Icons.grass, '5', 'Crops', Colors.white),
                        const SizedBox(height: 8),
                        _buildStatItem(
                            Icons.shopping_bag, '12', 'Sales', Colors.white),
                        const SizedBox(height: 8),
                        _buildStatItem(Icons.currency_rupee, '45K', 'Earnings',
                            Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (kalimatiItems.isNotEmpty) ...[
              const Divider(height: 24),
              const Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Hot Kalimati Items',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
              const SizedBox(height: 8),
              ...kalimatiItems.take(3).map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(item.productName,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white)),
                        ),
                        Text('Rs.${item.avgPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.white)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.priceChangePercent > 0
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.priceChangePercent > 0 ? '+' : ''}${item.priceChangePercent.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 10,
                              color: item.priceChangePercent > 0
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
      ],
    );
  }

  Widget _buildFarmingSuitability(WeatherData weather) {
    String suitability;
    Color suitabilityColor;
    IconData suitabilityIcon;

    if (weather.temperature > 30 || weather.rainChance > 70) {
      suitability = 'Poor';
      suitabilityColor = Colors.red;
      suitabilityIcon = Icons.warning;
    } else if (weather.temperature < 15 || weather.rainChance > 50) {
      suitability = 'Fair';
      suitabilityColor = Colors.orange;
      suitabilityIcon = Icons.info;
    } else {
      suitability = 'Excellent';
      suitabilityColor = Colors.green;
      suitabilityIcon = Icons.check_circle;
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: suitabilityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: suitabilityColor, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(suitabilityIcon, size: 14, color: suitabilityColor),
                const SizedBox(width: 4),
                Text(
                  suitability,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: suitabilityColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostsAndNews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.article, color: Color(0xFF4CAF50), size: 24),
            SizedBox(width: 8),
            Text('Posts & News',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        _buildFacebookStylePost(
          'Ministry of Agriculture',
          'Government',
          'New subsidy program for organic farming announced. Farmers can now apply for up to Rs. 50,000 in subsidies for organic certification and equipment.',
          '2h ago',
          Icons.account_balance,
          Colors.blue,
          45,
          12,
        ),
        const SizedBox(height: 12),
        _buildFacebookStylePost(
          'Ram Bahadur',
          'Farmer',
          'Just harvested my first organic tomato crop! The yield is amazing. Thanks to HamiKisan community for all the support and tips. 🍅',
          '5h ago',
          Icons.person,
          Colors.green,
          28,
          8,
        ),
        const SizedBox(height: 12),
        _buildFacebookStylePost(
          'Dr. Sharma',
          'Kisan Doctor',
          'Monsoon season tips: Make sure to check your crops for fungal diseases. Early detection is key! Apply neem oil spray as a preventive measure.',
          '1d ago',
          Icons.medical_services,
          Colors.orange,
          67,
          15,
        ),
      ],
    );
  }

  Widget _buildFacebookStylePost(
    String name,
    String role,
    String content,
    String time,
    IconData icon,
    Color iconColor,
    int likes,
    int comments,
  ) {
    return Card(
      elevation: 2,
      color: Colors.white.withValues(alpha: 0.85),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withValues(alpha: 0.1),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(role,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Text(time,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.thumb_up_outlined,
                    size: 18, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('$likes',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(width: 20),
                Icon(Icons.comment_outlined, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('$comments',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(width: 20),
                Icon(Icons.share_outlined, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Share',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketContent extends StatefulWidget {
  final ScrollController scrollController;
  const _MarketContent({required this.scrollController});

  @override
  State<_MarketContent> createState() => _MarketContentState();
}

class _MarketContentState extends State<_MarketContent> {
  final _marketService = MarketService();
  List<MarketPrice> _allPrices = [];
  List<MarketPrice> _filteredPrices = [];
  String _searchQuery = '';
  String _selectedLocation = 'All';
  String _selectedCategory = 'All';
  String _sortBy = 'name';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMarketData();
  }

  Future<void> _loadMarketData() async {
    await _marketService.initialize();
    final prices = await _marketService.getDailyMarketPrices();
    setState(() {
      _allPrices = prices;
      _filteredPrices = prices;
      _loading = false;
    });
  }

  String _getCategory(String productName) {
    final vegetables = [
      'Tomato',
      'Potato',
      'Onion',
      'Cauliflower',
      'Cabbage',
      'Carrot',
      'Spinach',
      'Pumpkin'
    ];
    final fruits = ['Apple', 'Banana', 'Orange', 'Mango'];
    final grains = ['Rice', 'Wheat', 'Maize', 'Lentils'];
    final spices = ['Ginger', 'Garlic', 'Chili'];

    if (vegetables.contains(productName)) return 'Vegetables';
    if (fruits.contains(productName)) return 'Fruits';
    if (grains.contains(productName)) return 'Grains';
    if (spices.contains(productName)) return 'Spices';
    return 'Other';
  }

  void _filterPrices() {
    setState(() {
      _filteredPrices = _allPrices.where((item) {
        final matchesSearch =
            item.productName.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesLocation =
            _selectedLocation == 'All' || item.location == _selectedLocation;
        final matchesCategory = _selectedCategory == 'All' ||
            _getCategory(item.productName) == _selectedCategory;
        return matchesSearch && matchesLocation && matchesCategory;
      }).toList();

      if (_sortBy == 'price_high') {
        _filteredPrices.sort((a, b) => b.avgPrice.compareTo(a.avgPrice));
      } else if (_sortBy == 'price_low') {
        _filteredPrices.sort((a, b) => a.avgPrice.compareTo(b.avgPrice));
      } else if (_sortBy == 'change') {
        _filteredPrices.sort(
            (a, b) => b.priceChangePercent.compareTo(a.priceChangePercent));
      } else {
        _filteredPrices.sort((a, b) => a.productName.compareTo(b.productName));
      }
    });
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final productController = TextEditingController();
    final priceController = TextEditingController();
    final phoneController = TextEditingController();
    String unit = 'केजी';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Sell Your Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Your Name')),
                const SizedBox(height: 12),
                TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Location')),
                const SizedBox(height: 12),
                TextField(
                    controller: productController,
                    decoration:
                        const InputDecoration(labelText: 'Product Name')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: unit,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  items: const [
                    DropdownMenuItem(value: 'केजी', child: Text('केजी (KG)')),
                    DropdownMenuItem(
                        value: 'के.जी.', child: Text('के.जी. (KG)')),
                    DropdownMenuItem(
                        value: 'दर्जन', child: Text('दर्जन (Dozen)')),
                    DropdownMenuItem(
                        value: 'प्रति गोटा',
                        child: Text('प्रति गोटा (Per Piece)')),
                  ],
                  onChanged: (v) => setState(() => unit = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price (Rs.)'),
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(
                    controller: phoneController,
                    decoration:
                        const InputDecoration(labelText: 'Contact Number'),
                    keyboardType: TextInputType.phone),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    locationController.text.isEmpty ||
                    productController.text.isEmpty ||
                    priceController.text.isEmpty ||
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')));
                  return;
                }
                final service = FarmerListingService();
                await service.initialize();
                await service.addListing(FarmerListing(
                  farmerName: nameController.text,
                  location: locationController.text,
                  productName: productController.text,
                  price: double.parse(priceController.text),
                  unit: unit,
                  phone: phoneController.text,
                  timestamp: DateTime.now(),
                ));
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Product listed successfully!')));
                _loadMarketData();
              },
              child: const Text('List Product'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final locations = [
      'All',
      ...{..._allPrices.map((e) => e.location)}
    ];
    final categories = ['All', 'Vegetables', 'Fruits', 'Grains', 'Spices'];
    final hotDeals = _allPrices.where((e) => e.priceChangePercent > 10).toList()
      ..sort((a, b) => b.priceChangePercent.compareTo(a.priceChangePercent));

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/background/bg.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white.withValues(alpha: 0.3),
                BlendMode.darken,
              ),
              onError: (exception, stackTrace) {},
            ),
          ),
          child: Column(
            children: [
              Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onChanged: (value) {
                              _searchQuery = value;
                              _filterPrices();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.sort),
                          onSelected: (value) {
                            setState(() {
                              _sortBy = value;
                              _filterPrices();
                            });
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'name', child: Text('Name')),
                            const PopupMenuItem(
                                value: 'price_high',
                                child: Text('Price: High to Low')),
                            const PopupMenuItem(
                                value: 'price_low',
                                child: Text('Price: Low to High')),
                            const PopupMenuItem(
                                value: 'change', child: Text('Price Change')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = _selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category,
                                  style: const TextStyle(fontSize: 12)),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                  _filterPrices();
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          final location = locations[index];
                          final isSelected = _selectedLocation == location;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(location,
                                  style: const TextStyle(fontSize: 12)),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedLocation = location;
                                  _filterPrices();
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadMarketData,
                  child: ListView(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.all(12),
                    children: [
                      if (_filteredPrices.isEmpty) ...[
                        Card(
                          color: Colors.white.withValues(alpha: 0.9),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const Icon(Icons.shopping_basket_outlined,
                                    size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text('No Market Data Available',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(
                                    'Admin needs to add Kalimati items or configure API',
                                    style: TextStyle(color: Colors.grey[600]),
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (hotDeals.isNotEmpty) ...[
                        Card(
                          color: Colors.orange.withValues(alpha: 0.9),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.local_fire_department,
                                        color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Hot Deals',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...hotDeals.take(3).map((item) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Text(item.productName,
                                                  style: const TextStyle(
                                                      color: Colors.white))),
                                          Text(
                                              'Rs.${item.avgPrice.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                                '+${item.priceChangePercent.toStringAsFixed(1)}%',
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.orange,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      ..._filteredPrices.map((item) {
                        final isFarmerListing =
                            item.productName.contains('(by ');
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Colors.white.withValues(alpha: 0.95),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isFarmerListing
                                  ? Colors.blue.withValues(alpha: 0.1)
                                  : const Color(0xFF4CAF50)
                                      .withValues(alpha: 0.1),
                              child: Icon(
                                isFarmerListing
                                    ? Icons.person
                                    : Icons.shopping_basket,
                                color: isFarmerListing
                                    ? Colors.blue
                                    : const Color(0xFF4CAF50),
                                size: 20,
                              ),
                            ),
                            title: Text(item.productName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(item.location,
                                    style: const TextStyle(fontSize: 11)),
                                const SizedBox(width: 8),
                                if (isFarmerListing)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: const Text('Farmer',
                                        style: TextStyle(
                                            fontSize: 9, color: Colors.blue)),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(_getCategory(item.productName),
                                        style: const TextStyle(fontSize: 9)),
                                  ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Rs.${item.avgPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                if (!isFarmerListing)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: item.priceChangePercent > 0
                                          ? Colors.green.shade50
                                          : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${item.priceChangePercent > 0 ? '+' : ''}${item.priceChangePercent.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: item.priceChangePercent > 0
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: _showAddProductDialog,
            backgroundColor: const Color(0xFF4CAF50),
            icon: const Icon(Icons.add),
            label: const Text('Sell'),
          ),
        ),
      ],
    );
  }
}

class _CommunityContent extends StatefulWidget {
  final ScrollController scrollController;
  const _CommunityContent({required this.scrollController});

  @override
  State<_CommunityContent> createState() => _CommunityContentState();
}

class _CommunityContentState extends State<_CommunityContent> {
  String? _selectedDistrict;
  List<String> _districts = [];

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to access the provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      postProvider.loadPosts().then((_) {
        if (mounted) {
          _updateDistricts(postProvider.posts);
        }
      });
    });
  }

  void _updateDistricts(List<Post> posts) {
    final districts = posts
        .map((p) => p.district) // Get all districts (String?)
        .whereType<String>() // Filter out nulls and cast to Iterable<String>
        .where((d) => d.isNotEmpty) // Filter out empty strings
        .toSet() // Get unique districts
        .toList();
    districts.sort();
    setState(() {
      _districts = ['All', ...districts];
      if (_selectedDistrict == null && districts.isNotEmpty) {
        _selectedDistrict = 'All';
      }
    });
  }

  void _createPost() {
    final contentController = TextEditingController();
    String postType = 'General';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: postType,
                  decoration: const InputDecoration(labelText: 'Post Type'),
                  items: const [
                    DropdownMenuItem(value: 'General', child: Text('General')),
                    DropdownMenuItem(
                        value: 'Question', child: Text('Question')),
                  ],
                  onChanged: (v) => setState(() => postType = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'What\'s on your mind?',
                    border: OutlineInputBorder(),
                  ),
                ),
                // Image selection can be added here if needed
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.isEmpty) return;

                final auth = context.read<AuthProvider>();
                final district =
                    auth.currentUser?.address ?? _selectedDistrict ?? 'Unknown';

                final success = await context.read<PostProvider>().createPost(
                      auth.currentUser!.id,
                      auth.currentUser!.name,
                      auth.currentUser!.role.name,
                      contentController.text,
                      null, // No image for now
                      postType: postType,
                      district: district,
                    );

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(success
                          ? 'Post created successfully!'
                          : 'Failed to create post')),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50)),
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  void _showComments(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.comment, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('${post.comments} Comments',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller:
                    scrollController, // This should be a real comment list
                padding: const EdgeInsets.all(16),
                children: const [
                  Center(child: Text('Comments will be shown here.'))
                ], // Placeholder
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.person, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF4CAF50)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/background/bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withValues(alpha: 0.3),
            BlendMode.darken,
          ),
          onError: (exception, stackTrace) {},
        ),
      ),
      child: Column(
        children: [
          if (_districts.isNotEmpty)
            Container(
              color: const Color(0xFF4CAF50),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedDistrict,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF4CAF50),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          underline: Container(),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.white),
                          items: _districts
                              .map<DropdownMenuItem<String>>(
                                  (d) => DropdownMenuItem<String>(
                                        value: d,
                                        child: Text(d),
                                      ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedDistrict = value!);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(Icons.people, 'N/A', 'Farmers'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(Icons.store, 'N/A', 'Markets'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(Icons.map, 'N/A', 'Province'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Container(
            color: Colors.white.withValues(alpha: 0.95),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const CircleAvatar(
                    radius: 18, child: Icon(Icons.person, size: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _createPost,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                          'Share with ${_selectedDistrict ?? "all"} farmers...',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: postProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => postProvider.loadPosts(),
                    child: Builder(builder: (context) {
                      final filteredPosts = (_selectedDistrict == null ||
                              _selectedDistrict == 'All')
                          ? postProvider.posts
                          : postProvider.posts
                              .where((p) => p.district == _selectedDistrict)
                              .toList();

                      if (filteredPosts.isEmpty) {
                        return const Center(
                            child: Text('No posts in this community yet.'));
                      }

                      return ListView.builder(
                        controller: widget.scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: filteredPosts.length,
                        itemBuilder: (context, index) {
                          final post = filteredPosts[index];
                          final iconColor = post.authorRole == 'farmer'
                              ? Colors.green
                              : Colors.orange;
                          final icon = post.authorRole == 'farmer'
                              ? Icons.agriculture
                              : Icons.medical_services;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            color: Colors.white.withValues(alpha: 0.95),
                            child: InkWell(
                              onTap: () =>
                                  Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    PostDetailScreen(post: post),
                              )),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              iconColor.withValues(alpha: 0.1),
                                          child: Icon(icon,
                                              color: iconColor, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(post.authorName,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14)),
                                              Text(post.authorRole,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600])),
                                            ],
                                          ),
                                        ),
                                        Text(_formatTimeAgo(post.timestamp),
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[500])),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(post.content,
                                        style: const TextStyle(fontSize: 13)),
                                    const SizedBox(height: 12),
                                    const Divider(height: 1),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => postProvider.toggleLike(
                                              post.id,
                                              authProvider.currentUser!.id),
                                          child: Row(
                                            children: [
                                              Icon(
                                                post.isLiked
                                                    ? Icons.thumb_up
                                                    : Icons.thumb_up_outlined,
                                                size: 18,
                                                color: post.isLiked
                                                    ? const Color(0xFF4CAF50)
                                                    : Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text('${post.likes}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: post.isLiked
                                                        ? const Color(
                                                            0xFF4CAF50)
                                                        : Colors.grey[600],
                                                    fontWeight: post.isLiked
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  )),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        InkWell(
                                          onTap: () => _showComments(post),
                                          child: Row(
                                            children: [
                                              Icon(Icons.comment_outlined,
                                                  size: 18,
                                                  color: Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Text('${post.comments}',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600])),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Row(
                                          children: [
                                            Icon(Icons.share_outlined,
                                                size: 18,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text('${post.shares}',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600])),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${(difference.inDays / 7).floor()}w ago';
  }
}

class _AddContent extends StatefulWidget {
  @override
  State<_AddContent> createState() => _AddContentState();
}

class _AddContentState extends State<_AddContent> {
  void _showCreatePostDialog() {
    final contentController = TextEditingController();
    String postType = 'General';
    File? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: postType,
                  decoration: const InputDecoration(labelText: 'Post Type'),
                  items: const [
                    DropdownMenuItem(value: 'General', child: Text('General')),
                    DropdownMenuItem(
                        value: 'Question', child: Text('Question')),
                    DropdownMenuItem(
                        value: 'Farming Tip', child: Text('Farming Tip')),
                    DropdownMenuItem(
                        value: 'Success Story', child: Text('Success Story')),
                    DropdownMenuItem(value: 'Events', child: Text('Events')),
                    DropdownMenuItem(
                        value: 'Weather Alert', child: Text('Weather Alert')),
                  ],
                  onChanged: (v) => setState(() => postType = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'What\'s on your mind?',
                    border: OutlineInputBorder(),
                    hintText:
                        'Share your thoughts, questions, or farming tips...',
                  ),
                ),
                if (selectedImage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            setState(() => selectedImage = File(image.path));
                          }
                        },
                        icon: const Icon(Icons.photo),
                        label: const Text('Photo'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera);
                          if (image != null) {
                            setState(() => selectedImage = File(image.path));
                          }
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please write something')),
                  );
                  return;
                }

                // Get user district from auth provider (assuming it has this field)
                final auth = context.read<AuthProvider>();
                final district = auth.currentUser?.address ??
                    'Kathmandu'; // Default to Kathmandu if no district

                final success = await context.read<PostProvider>().createPost(
                      auth.currentUser?.id ?? '',
                      auth.currentUser?.name ?? 'Farmer',
                      auth.currentUser?.role.name ?? 'farmer',
                      contentController.text,
                      selectedImage?.path,
                      postType: postType,
                      district: district,
                    );

                if (!context.mounted) return;
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post created successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to create post')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSellProductDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final productController = TextEditingController();
    final priceController = TextEditingController();
    final phoneController = TextEditingController();
    String unit = 'केजी';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Sell Your Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Your Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: productController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: unit,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  items: const [
                    DropdownMenuItem(value: 'केजी', child: Text('केजी (KG)')),
                    DropdownMenuItem(
                        value: 'के.जी.', child: Text('के.जी. (KG)')),
                    DropdownMenuItem(
                        value: 'दर्जन', child: Text('दर्जन (Dozen)')),
                    DropdownMenuItem(
                        value: 'प्रति गोटा',
                        child: Text('प्रति गोटा (Per Piece)')),
                  ],
                  onChanged: (v) => setState(() => unit = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price (Rs.)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration:
                      const InputDecoration(labelText: 'Contact Number'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    locationController.text.isEmpty ||
                    productController.text.isEmpty ||
                    priceController.text.isEmpty ||
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                final service = FarmerListingService();
                await service.initialize();
                await service.addListing(FarmerListing(
                  farmerName: nameController.text,
                  location: locationController.text,
                  productName: productController.text,
                  price: double.parse(priceController.text),
                  unit: unit,
                  phone: phoneController.text,
                  timestamp: DateTime.now(),
                ));

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product listed successfully!')),
                );
              },
              child: const Text('List Product'),
            ),
          ],
        ),
      ),
    );
  }

  // Duplicate method removed

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/background/bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withValues(alpha: 0.3),
            BlendMode.darken,
          ),
          onError: (exception, stackTrace) {},
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline,
                  size: 64, color: Color(0xFF4CAF50)),
              const SizedBox(height: 16),
              const Text('What would you like to add?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              _buildActionCard(
                icon: Icons.post_add,
                title: 'Create Post',
                subtitle: 'Share updates, tips, or questions',
                color: Colors.blue,
                onTap: _showCreatePostDialog,
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                icon: Icons.sell,
                title: 'Sell Product',
                subtitle: 'List your products in marketplace',
                color: const Color(0xFF4CAF50),
                onTap: _showSellProductDialog,
              ),
              const SizedBox(height: 16),
              _buildActionCard(
                icon: Icons.question_answer,
                title: 'Ask Doctor',
                subtitle: 'Get expert advice on crop issues',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConsultationContactsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      color: Colors.white.withValues(alpha: 0.95),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
