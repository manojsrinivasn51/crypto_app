import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'watchlist_provider.dart';
import '../markets/markets_provider.dart';
import '../../data/models/coin.dart';

final watchlistCoinsProvider = FutureProvider<List<Coin>>((ref) async {
  final ids = ref.watch(watchlistProvider);
  if (ids.isEmpty) return [];
  final api = ref.read(apiServiceProvider);
  return api.getCoins(ids: ids.join(','));
});

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCoins = ref.watch(watchlistCoinsProvider);
    final watchlist = ref.watch(watchlistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: watchlist.isEmpty
        ? const Center(child: Text('Watchlist is empty'))
        : asyncCoins.when(
            data: (coins) => RefreshIndicator(
              onRefresh: () => ref.refresh(watchlistCoinsProvider.future),
              child: ListView.builder(
                itemCount: coins.length,
                itemBuilder: (context, index) {
                  final coin = coins[index];
                  return ListTile(
                    leading: Image.network(coin.image, width: 40, height: 40, errorBuilder: (_,__,___)=>const Icon(Icons.error)),
                    title: Text(coin.name),
                    subtitle: Text(coin.symbol.toUpperCase()),
                    trailing: Text('\$${coin.currentPrice.toStringAsFixed(2)}'),
                    onTap: () => context.push('/detail/${coin.id}'),
                  );
                },
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
    );
  }
}
