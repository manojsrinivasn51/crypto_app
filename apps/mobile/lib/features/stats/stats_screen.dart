import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';
import '../markets/markets_provider.dart';

final statsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.read(apiServiceProvider).getGlobalStats();
});

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Global Stats')),
      body: statsAsync.when(
        data: (stats) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text('Active Cryptocurrencies'),
                trailing: Text('${stats['active_cryptocurrencies'] ?? 0}'),
              ),
              ListTile(
                title: const Text('BTC Dominance'),
                trailing: Text('${stats['market_cap_percentage']?['btc']?.toStringAsFixed(2)}%'),
              ),
              ListTile(
                title: const Text('ETH Dominance'),
                trailing: Text('${stats['market_cap_percentage']?['eth']?.toStringAsFixed(2)}%'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
