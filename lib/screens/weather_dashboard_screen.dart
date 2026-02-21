import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_market_provider.dart';
import '../models/weather_models.dart';

class WeatherDashboardScreen extends StatelessWidget {
  const WeatherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Dashboard'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WeatherMarketProvider>().loadWeatherData();
            },
          ),
        ],
      ),
      body: Consumer<WeatherMarketProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingWeather) {
            return const Center(child: CircularProgressIndicator());
          }

          final weather = provider.weatherData;
          if (weather == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No weather data available'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => provider.loadWeatherData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Weather Overview
                _buildCurrentWeatherCard(weather),
                const SizedBox(height: 16),
                
                // Weather Details Grid
                _buildWeatherDetailsGrid(weather),
                const SizedBox(height: 16),
                
                // Farming Tips
                _buildFarmingTipsCard(provider.getFarmingTip()),
                const SizedBox(height: 16),
                
                // Weather Alerts
                _buildWeatherAlertsCard(weather),
                const SizedBox(height: 16),
                
                // Weather Forecast (Not Available)
                _buildForecastPlaceholder(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentWeatherCard(WeatherData weather) {
    IconData weatherIcon;
    Color iconColor;
    
    switch (weather.weatherType.toLowerCase()) {
      case 'sunny':
        weatherIcon = Icons.wb_sunny;
        iconColor = Colors.orange;
        break;
      case 'rainy':
        weatherIcon = Icons.water_drop;
        iconColor = Colors.blue;
        break;
      case 'cloudy':
      case 'partly cloudy':
        weatherIcon = Icons.cloud;
        iconColor = Colors.grey;
        break;
      default:
        weatherIcon = Icons.wb_cloudy;
        iconColor = Colors.blueGrey;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(weatherIcon, size: 64, color: iconColor),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.temperature.round()}°C',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        weather.weatherType,
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(weather.location, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(Icons.water_drop, '${weather.humidity.round()}%', 'Humidity'),
                _buildStatItem(Icons.air, '${weather.windSpeed.round()} km/h', 'Wind'),
                _buildStatItem(Icons.water, '${weather.rainChance}%', 'Rain'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: const Color(0xFF4CAF50)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildWeatherDetailsGrid(WeatherData weather) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weather Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDetailItem(Icons.thermostat, 'Temperature', '${weather.temperature.round()}°C'),
                _buildDetailItem(Icons.water_drop, 'Humidity', '${weather.humidity.round()}%'),
                _buildDetailItem(Icons.air, 'Wind Speed', '${weather.windSpeed.round()} km/h'),
                _buildDetailItem(Icons.water, 'Rain Chance', '${weather.rainChance}%'),
                _buildDetailItem(Icons.location_on, 'Location', weather.location),
                _buildDetailItem(Icons.calendar_today, 'Updated', _formatTime(weather.timestamp)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF4CAF50)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFarmingTipsCard(String farmingTip) {
    return Card(
      color: const Color(0xFFE8F5E9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Color(0xFF4CAF50), size: 24),
                SizedBox(width: 8),
                Text('Farming Tip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              farmingTip,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherAlertsCard(WeatherData weather) {
    List<String> alerts = [];
    List<Color> alertColors = [];
    List<IconData> alertIcons = [];

    // Generate weather alerts based on conditions
    if (weather.temperature > 35) {
      alerts.add('Heat wave alert: Temperature is very high. Ensure proper hydration for crops.');
      alertColors.add(Colors.orange);
      alertIcons.add(Icons.thermostat);
    }
    
    if (weather.temperature < 5) {
      alerts.add('Frost warning: Low temperature may damage sensitive crops.');
      alertColors.add(Colors.blue);
      alertIcons.add(Icons.ac_unit);
    }
    
    if (weather.rainChance > 70) {
      alerts.add('Heavy rain expected: Consider drainage and protect sensitive crops.');
      alertColors.add(Colors.blue);
      alertIcons.add(Icons.water_drop);
    }
    
    if (weather.windSpeed > 20) {
      alerts.add('Strong winds: Secure loose items and consider windbreaks.');
      alertColors.add(Colors.green);
      alertIcons.add(Icons.air);
    }

    if (alerts.isEmpty) {
      return const Card(
        color: Color(0xFFF1F8E9),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24),
              SizedBox(width: 8),
              Text('No weather alerts at this time', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 24),
                SizedBox(width: 8),
                Text('Weather Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(alertIcons[index], color: alertColors[index], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          alerts[index],
                          style: TextStyle(color: alertColors[index]),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  Widget _buildForecastPlaceholder() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
                SizedBox(width: 8),
                Text('7-Day Forecast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            Text('Forecast data is not currently available in this version.'),
            SizedBox(height: 8),
            Text('The forecast feature will be available in future updates.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
