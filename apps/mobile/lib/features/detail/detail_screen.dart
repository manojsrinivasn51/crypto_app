import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../markets/markets_provider.dart';
import '../watchlist/watchlist_provider.dart';

final detailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) {
  return ref.read(apiServiceProvider).getCoinDetail(id);
});

final chartProvider = FutureProvider.family<List<List<num>>, String>((ref, id) {
  return ref.read(apiServiceProvider).getChartData(id, 7);
});

class DetailScreen extends ConsumerWidget {
  final String id;
  const DetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(detailProvider(id));
    final chartAsync = ref.watch(chartProvider(id));
    final isWatchlisted = ref.watch(watchlistProvider).contains(id);

    return Scaffold(
      appBar: AppBar(
        title: Text(id.toUpperCase()),
        actions: [
          IconButton(
            icon: Icon(isWatchlisted ? Icons.star : Icons.star_border),
            onPressed: () {
              ref.read(watchlistProvider.notifier).toggle(id);
            },
          )
        ],
      ),
      body: detailAsync.when(
        data: (detail) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Image.network(
                    (detail['image'] is Map) ? detail['image']['small'] ?? '' : detail['image'] ?? '', 
                    width: 50, 
                    errorBuilder: (_,__,___)=>const Icon(Icons.error)
                  ),
                  const SizedBox(width: 16),
                  Text('\$${detail['market_data']?['current_price']?['usd'] ?? detail['current_price'] ?? 'N/A'}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('7-Day Price Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: chartAsync.when(
                  data: (prices) {
                    if (prices.isEmpty) return const Text('No chart data');
                    final minPrice = prices.map((e) => e[1]).reduce((a, b) => a < b ? a : b).toDouble();
                    final spots = prices.map((e) => FlSpot(e[0].toDouble(), e[1].toDouble())).toList();
                    return LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        minY: minPrice * 0.95,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: Colors.blue,
                            dotData: FlDotData(show: false),
                          )
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Chart error: $e'),
                ),
              ),
              const SizedBox(height: 24),
              Text('Market Cap: \$${detail['market_data']?['market_cap']?['usd'] ?? detail['market_cap'] ?? 'N/A'}'),
              Text('Rank: ${detail['market_cap_rank'] ?? 'N/A'}'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
