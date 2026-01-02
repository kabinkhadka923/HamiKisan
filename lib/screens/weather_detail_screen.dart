import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_market_provider.dart';

class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Details'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Consumer<WeatherMarketProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingWeather) {
            return const Center(child: CircularProgressIndicator());
          }

          final weather = provider.weatherData;
          if (weather == null) {
            return const Center(child: Text('No weather data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.wb_sunny, size: 80, color: Colors.orange),
                        const SizedBox(height: 16),
                        Text(
                          '${weather.temperature.round()}°C',
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                        Text(weather.weatherType, style: const TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailCard('Humidity', '${weather.humidity.round()}%', Icons.water_drop),
                _buildDetailCard('Wind Speed', '${weather.windSpeed.round()} km/h', Icons.air),
                _buildDetailCard('Location', weather.location, Icons.location_on),
                _buildDetailCard('Rain Chance', '${weather.rainChance}%', Icons.water),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Farming Tip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(provider.getFarmingTip()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4CAF50)),
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
