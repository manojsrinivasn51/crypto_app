import os

files = {
    "lib/core/api_client.dart": """
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiClient {
  static final Dio dio = Dio(BaseOptions(
    // Use 10.0.2.2 for Android emulator, localhost for others
    baseUrl: !kIsWeb && Platform.isAndroid ? 'http://10.0.2.2:3000/api' : 'http://localhost:3000/api',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
}
""",
    "lib/data/models/coin.dart": """
class Coin {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double marketCap;
  final int marketCapRank;
  final double priceChangePercentage24h;

  Coin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.priceChangePercentage24h,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? json['thumb'] ?? '',
      currentPrice: (json['current_price'] ?? 0).toDouble(),
      marketCap: (json['market_cap'] ?? 0).toDouble(),
      marketCapRank: json['market_cap_rank'] ?? 0,
      priceChangePercentage24h: (json['price_change_percentage_24h'] ?? 0).toDouble(),
    );
  }
}
""",
    "lib/data/services/api_service.dart": """
import '../models/coin.dart';
import '../../core/api_client.dart';

class ApiService {
  Future<List<Coin>> getCoins({int page = 1, String? ids}) async {
    final response = await ApiClient.dio.get('/coins', queryParameters: {
      'page': page,
      if (ids != null) 'ids': ids,
    });
    final List data = response.data['data'] ?? [];
    return data.map((json) => Coin.fromJson(json)).toList();
  }

  Future<List<Coin>> search(String query) async {
    final response = await ApiClient.dio.get('/search', queryParameters: {'q': query});
    final List data = response.data['data']?['coins'] ?? [];
    return data.map((json) => Coin.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> getGlobalStats() async {
    final response = await ApiClient.dio.get('/market/global');
    return response.data['data'] ?? {};
  }
  
  Future<List<List<num>>> getChartData(String id, int days) async {
    final response = await ApiClient.dio.get('/coins/$id/chart', queryParameters: {'days': days});
    final List prices = response.data['data']?['prices'] ?? [];
    return prices.map((e) => [e[0] as num, e[1] as num]).toList();
  }
  
  Future<Map<String, dynamic>> getCoinDetail(String id) async {
    final response = await ApiClient.dio.get('/coins/$id');
    return response.data['data'] ?? {};
  }
}
""",
    "lib/features/markets/markets_provider.dart": """
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/coin.dart';
import '../../data/services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final searchQueryProvider = StateProvider<String>((ref) => '');

final marketsProvider = FutureProvider<List<Coin>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final api = ref.read(apiServiceProvider);
  if (query.isNotEmpty) {
    return api.search(query);
  }
  return api.getCoins();
});
""",
    "lib/features/markets/markets_screen.dart": """
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'markets_provider.dart';

class MarketsScreen extends ConsumerWidget {
  const MarketsScreen({Key? key}) : super(key: key);

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
                ref.read(searchQueryProvider.notifier).state = val;
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
""",
    "lib/features/detail/detail_screen.dart": """
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/services/api_service.dart';
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
  const DetailScreen({Key? key, required this.id}) : super(key: key);

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
                  Image.network(detail['image'] ?? '', width: 50, errorBuilder: (_,__,___)=>const Icon(Icons.error)),
                  const SizedBox(width: 16),
                  Text('\$${detail['current_price']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
              Text('Market Cap: \$${detail['market_cap']}'),
              Text('Rank: ${detail['market_cap_rank']}'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
""",
    "lib/features/stats/stats_screen.dart": """
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';
import '../markets/markets_provider.dart';

final statsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.read(apiServiceProvider).getGlobalStats();
});

class StatsScreen extends ConsumerWidget {
  const StatsScreen({Key? key}) : super(key: key);

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
""",
    "lib/features/watchlist/watchlist_provider.dart": """
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

class WatchlistNotifier extends StateNotifier<List<String>> {
  final SharedPreferences prefs;
  WatchlistNotifier(this.prefs) : super(prefs.getStringList('watchlist') ?? []);

  void toggle(String id) {
    if (state.contains(id)) {
      state = state.where((e) => e != id).toList();
    } else {
      state = [...state, id];
    }
    prefs.setStringList('watchlist', state);
  }
}

final watchlistProvider = StateNotifierProvider<WatchlistNotifier, List<String>>((ref) {
  return WatchlistNotifier(ref.watch(sharedPrefsProvider));
});
""",
    "lib/features/watchlist/watchlist_screen.dart": """
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
  const WatchlistScreen({Key? key}) : super(key: key);

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
""",
    "lib/main.dart": """
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import 'features/markets/markets_screen.dart';
import 'features/detail/detail_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/watchlist/watchlist_screen.dart';
import 'features/watchlist/watchlist_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const CryptoApp(),
    ),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/markets',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _calculateSelectedIndex(context),
              onTap: (int idx) => _onItemTapped(idx, context),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Markets'),
                BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Watchlist'),
                BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Stats'),
              ],
            ),
          );
        },
        routes: [
          GoRoute(path: '/markets', builder: (context, state) => const MarketsScreen()),
          GoRoute(path: '/watchlist', builder: (context, state) => const WatchlistScreen()),
          GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),
        ]
      ),
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) => DetailScreen(id: state.pathParameters['id']!),
      ),
    ],
  );
});

int _calculateSelectedIndex(BuildContext context) {
  final String location = GoRouterState.of(context).uri.toString();
  if (location.startsWith('/markets')) return 0;
  if (location.startsWith('/watchlist')) return 1;
  if (location.startsWith('/stats')) return 2;
  return 0;
}

void _onItemTapped(int index, BuildContext context) {
  switch (index) {
    case 0:
      context.go('/markets');
      break;
    case 1:
      context.go('/watchlist');
      break;
    case 2:
      context.go('/stats');
      break;
  }
}

class CryptoApp extends ConsumerWidget {
  const CryptoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Crypto App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
"""
}

for path, content in files.items():
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(content.strip() + "\\n")
print("Flutter files scaffolded.")
