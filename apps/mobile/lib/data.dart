import 'dart:convert';
import 'package:http/http.dart' as http;

double _d(dynamic v) => (v ?? 0).toDouble();

class Coin {
  final String id, name, symbol;
  final String? image;
  final double price, change, volume, marketCap, circulating;
  final double? maxSupply;
  final List<double> spark;
  Coin({required this.id, required this.name, required this.symbol, this.image, required this.price,
    required this.change, required this.volume, required this.marketCap, required this.circulating,
    this.maxSupply, required this.spark});

  factory Coin.fromJson(Map<String, dynamic> j) => Coin(
        id: j['id'],
        name: j['name'],
        symbol: (j['symbol'] as String).toUpperCase(),
        image: j['image'],
        price: _d(j['current_price']),
        change: _d(j['price_change_percentage_24h']),
        volume: _d(j['total_volume']),
        marketCap: _d(j['market_cap']),
        circulating: _d(j['circulating_supply']),
        maxSupply: j['max_supply'] == null ? null : _d(j['max_supply']),
        spark: ((j['sparkline_in_7d']?['price'] as List?) ?? []).map<double>(_d).toList(),
      );
}

class Api {
  // Direct CoinGecko API URL
  static const base = String.fromEnvironment('API', defaultValue: 'https://api.coingecko.com/api/v3');

  Future<dynamic> _get(String path) async {
    final r = await http.get(Uri.parse('$base$path')).timeout(const Duration(seconds: 12));
    if (r.statusCode != 200) throw Exception('Server error ${r.statusCode}');
    return jsonDecode(r.body);
  }

  Future<List<Coin>> coins() async =>
      ((await _get('/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=true')) as List)
          .map((j) => Coin.fromJson(j as Map<String, dynamic>))
          .toList();

  Future<Map<String, dynamic>> global() async {
    final r = await _get('/global');
    final g = r['data'];
    return {
      'marketCap': _d(g['total_market_cap']['usd']),
      'volume': _d(g['total_volume']['usd']),
      'btcDominance': _d(g['market_cap_percentage']['btc']),
      'change24h': _d(g['market_cap_change_percentage_24h_usd']),
    };
  }

  Future<List<List<double>>> chart(String id, String days) async {
    final r = await _get('/coins/$id/market_chart?vs_currency=usd&days=$days');
    return (r['prices'] as List).map<List<double>>((p) => [_d(p[0]), _d(p[1])]).toList();
  }

  // Without a backend, we just return an empty watchlist and save it in memory (AppState)
  Future<List<String>> watchlist() async => [];

  Future<void> setWatch(String id, bool on) async {
    // Simulate network delay for UI consistency
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
