import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'markets_provider.dart';

class MarketsScreen extends ConsumerWidget {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCoins = ref.watch(marketsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search coins...',
                filled: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).updateQuery(val);
              },
            ),
          ),
        ),
      ),
      body: asyncCoins.when(
        data: (coins) => RefreshIndicator(
          onRefresh: () => ref.refresh(marketsProvider.future),
          child: ListView.builder(
            itemCount: coins.length,
            itemBuilder: (context, index) {
              final coin = coins[index];
              return ListTile(
                leading: Image.network(coin.image, width: 40, height: 40, errorBuilder: (_,__,___)=>const Icon(Icons.error)),
                title: Text(coin.name),
                subtitle: Text(coin.symbol.toUpperCase()),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${coin.currentPrice.toStringAsFixed(2)}'),
                    Text(
                      '${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                      style: TextStyle(color: coin.priceChangePercentage24h >= 0 ? Colors.green : Colors.red),
                    ),
                  ],
                ),
                onTap: () => context.push('/detail/${coin.id}'),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
