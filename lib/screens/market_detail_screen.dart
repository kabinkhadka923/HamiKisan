import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_market_provider.dart';

class MarketDetailScreen extends StatelessWidget {
  const MarketDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Prices'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Consumer<WeatherMarketProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingMarketPrice) {
            return const Center(child: CircularProgressIndicator());
          }

          final prices = provider.marketPrices;
          if (prices == null || prices.isEmpty) {
            return const Center(child: Text('No market data available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prices.length,
            itemBuilder: (context, index) {
              final item = prices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF4CAF50),
                    child: Icon(Icons.shopping_basket, color: Colors.white),
                  ),
                  title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${item.location} • Min: Rs.${item.minPrice.toStringAsFixed(0)} • Max: Rs.${item.maxPrice.toStringAsFixed(0)}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs.${item.avgPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.priceChangePercent >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 14,
                            color: item.priceChangePercent >= 0 ? Colors.green : Colors.red,
                          ),
                          Text(
                            '${item.priceChangePercent.abs().toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: item.priceChangePercent >= 0 ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
