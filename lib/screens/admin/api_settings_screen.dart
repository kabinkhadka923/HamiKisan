import 'package:flutter/material.dart';
import '../../services/api_config_service.dart';

class ApiSettingsScreen extends StatefulWidget {
  const ApiSettingsScreen({super.key});

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  final _apiConfigService = ApiConfigService();
  final _kalimatiUrlController = TextEditingController();
  final _kalimatiKeyController = TextEditingController();
  final _weatherKeyController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    await _apiConfigService.initialize();
    setState(() {
      _kalimatiUrlController.text = _apiConfigService.getKalimatiApiUrl() ?? '';
      _kalimatiKeyController.text = _apiConfigService.getKalimatiApiKey() ?? '';
      _weatherKeyController.text = _apiConfigService.getWeatherApiKey() ?? '';
      _loading = false;
    });
  }

  Future<void> _saveKalimatiConfig() async {
    await _apiConfigService.setKalimatiApiUrl(_kalimatiUrlController.text);
    await _apiConfigService.setKalimatiApiKey(_kalimatiKeyController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kalimati API configuration saved')),
      );
    }
  }

  Future<void> _saveWeatherConfig() async {
    await _apiConfigService.setWeatherApiKey(_weatherKeyController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weather API configuration saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.store, color: Color(0xFF4CAF50)),
                      SizedBox(width: 8),
                      Text('Kalimati Market API',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _kalimatiUrlController,
                    decoration: const InputDecoration(
                      labelText: 'API URL',
                      hintText: 'https://kalimatimarket.gov.np/api/prices',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _kalimatiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'API Key (Optional)',
                      hintText: 'Enter API key if required',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save Kalimati Config'),
                      onPressed: _saveKalimatiConfig,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.wb_sunny, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Weather API',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _weatherKeyController,
                    decoration: const InputDecoration(
                      labelText: 'OpenWeatherMap API Key',
                      hintText: 'Enter your API key',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save Weather Config'),
                      onPressed: _saveWeatherConfig,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('API Information',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('Kalimati Market API:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('• Official: https://kalimatimarket.gov.np'),
                  Text('• Provides daily vegetable prices'),
                  Text('• Updates every morning'),
                  SizedBox(height: 12),
                  Text('Weather API:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('• Get free key: https://openweathermap.org/api'),
                  Text('• Provides weather forecasts'),
                  Text('• Updates every 3 hours'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _kalimatiUrlController.dispose();
    _kalimatiKeyController.dispose();
    _weatherKeyController.dispose();
    super.dispose();
  }
}
